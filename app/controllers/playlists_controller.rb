class PlaylistsController < ApplicationController
  before_action :set_playlist, only: [:show, :update, :destroy]

  def index
    authorize Playlist
    @scoped_playlists = policy_scope(Playlist).joins(:playlist_songs)
    @playlists = @scoped_playlists.to_a.uniq { |p| p.id }
    @playlist = Playlist.new

    return unless params[:query].present?

    # query   = params[:query].strip
    # pattern = "%#{query}%"
    # @playlists = Playlist.where("name ILIKE ?", pattern)
    query = params[:query].strip
    @playlists = @scoped_playlists.search_by_name(query).to_a.uniq { |p| p.id }
  end

  def show
    @playlist = Playlist.find(params[:id])
    @songs = []
    authorize @playlist

    return unless params[:query].present?

    # query   = params[:query].strip
    # pattern = "%#{query}%"
    # @songs = Song.where("name ILIKE ? OR artist ILIKE ?", pattern, pattern)
    query = params[:query].strip
    @songs = Song.search_by_name_and_artist(query)
  end

  def create
    @playlist = Playlist.new(playlist_params)
    @playlist.user = current_user
    authorize @playlist
    if @playlist.save
      redirect_to playlist_path(@playlist)
    else
      @playlists = policy_scope(Playlist)
      render :index, status: :unprocessable_entity
    end

  end

  def update
    @playlist = Playlist.find(params[:id])
    authorize @playlist
    if @playlist.update(playlist_params)
      redirect_to playlist_path(@playlist)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @playlist
    User.where(current_playlist_id: @playlist.id).update_all(current_playlist_id: nil)
    @playlist.destroy
    redirect_to playlists_path, notice: "Playlist deleted."
  end

  def import_spotify_playlists
    authorize Playlist

    unless current_user.spotify_access_token
      redirect_to playlists_path, alert: "Please connect your Spotify account first."
      return
    end

    spotify_playlists = SpotifyClient.instance.user_playlists(current_user)

    if spotify_playlists.empty?
      redirect_to playlists_path, notice: "No Spotify playlists found."
      return
    end

    imported_count = 0
    spotify_playlists.each do |spotify_playlist|
      playlist = current_user.playlists.create(name: spotify_playlist.name)
      next unless playlist.persisted?

      tracks = SpotifyClient.instance.playlist_tracks(spotify_playlist.id, current_user)
      tracks.each_with_index do |track, index|
        next unless track&.external_ids && track.external_ids["isrc"]

        song = Song.find_or_create_by(ISRC: track.external_ids["isrc"]) do |s|
          s.name = track.name
          s.artist = track.artists.map(&:name).join(", ")
          s.spotify_id = track.id
          s.image_url = track.album&.images&.first&.dig("url")
          s.availability = {}
        end

        # Queue job to check karaoke availability for new songs
        if song.availability.blank?
          CheckKaraokeAvailabilityJob.perform_later(song.id)
        end

        if song.persisted?
          playlist.playlist_songs.create(song: song, position: index + 1)
        end
      end

      imported_count += 1
    end

    redirect_to playlists_path, notice: "Imported #{imported_count} playlist(s) from Spotify!"
  end

  private

  def set_playlist
    @playlist = Playlist.find(params[:id])
  end

  def playlist_params
    params.require(:playlist).permit(:name, :photo)
  end
end
