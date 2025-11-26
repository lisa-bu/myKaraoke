class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # include Pundit::Authorization

  # Pundit: allow-list approach
  # after_action :verify_authorized, except: :index, unless: :skip_pundit?
  # after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # # Uncomment when you *really understand* Pundit!
  # # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # # def user_not_authorized
  # #   flash[:alert] = "You are not authorized to perform this action."
  # #   redirect_to(root_path)
  # # end

  # private

  # def skip_pundit?
  #   devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  # end

  def home
    @current_playlist = current_user.playlists.find_by(id: current_user.current_playlist_id)
    if @current_playlist.nil?
      @current_playlist = current_user.playlists.create!( name: "Playlist #{current_user.playlists.count + 1}"
    )
      current_user.update!(current_playlist_id: @current_playlist.id)
    end
  end
end
