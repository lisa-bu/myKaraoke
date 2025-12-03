# app/services/karaoke_availability_service.rb
#
# Service to check song availability on DAM and Joysound karaoke libraries
# Uses the manana.kr API (https://api.manana.kr/)
#
# Usage:
#   service = KaraokeAvailabilityService.new
#   result = service.check_availability(song_name: "Dynamite", artist_name: "BTS")
#   # => { dam: { available: true, song_id: "6786-45", ... }, joysound: { available: true, song_id: "486065", ... } }

require "net/http"
require "json"
require "uri"
require "openssl"

class KaraokeAvailabilityService
  BASE_URL = "https://api.manana.kr/karaoke"

  def initialize(timeout: 10)
    @timeout = timeout
  end

  # Check availability on both platforms
  #
  # @param song_name [String] The song title to search for
  # @param artist_name [String, nil] Optional artist name for better matching
  # @return [Hash] Results from both DAM and Joysound
  def check_availability(song_name:, artist_name: nil)
    results = search_song(song_name: song_name, artist_name: artist_name)

    dam_result = extract_brand_result(results, "dam", song_name, artist_name)
    joysound_result = extract_brand_result(results, "joysound", song_name, artist_name)

    {
      dam: dam_result,
      joysound: joysound_result,
      available_on: [
        dam_result[:available] ? "DAM" : nil,
        joysound_result[:available] ? "Joysound" : nil
      ].compact
    }
  end

  # Check availability on DAM only
  def check_dam(song_name:, artist_name: nil)
    results = search_song(song_name: song_name, artist_name: artist_name)
    extract_brand_result(results, "dam", song_name, artist_name)
  end

  # Check availability on Joysound only
  def check_joysound(song_name:, artist_name: nil)
    results = search_song(song_name: song_name, artist_name: artist_name)
    extract_brand_result(results, "joysound", song_name, artist_name)
  end

  private

  def search_song(song_name:, artist_name: nil)
    # Try searching by song name first
    results = fetch_results("song", song_name)

    # If no results and artist provided, try searching by artist
    if results.empty? && artist_name.present?
      results = fetch_results("singer", artist_name)
    end

    results
  rescue StandardError => e
    log_error("Manana API error: #{e.message}")
    []
  end

  def fetch_results(search_type, query)
    encoded_query = URI.encode_www_form_component(query)
    url = "#{BASE_URL}/#{search_type}/#{encoded_query}.json"

    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = @timeout
    http.read_timeout = @timeout
    # Skip SSL verification to work around CRL check issues with this API
    # This is acceptable for this non-sensitive read-only API
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "MyKaraoke/1.0"

    response = http.request(request)

    if response.code == "200"
      JSON.parse(response.body)
    else
      []
    end
  rescue StandardError => e
    log_error("Failed to fetch from #{url}: #{e.message}")
    []
  end

  def extract_brand_result(results, brand, song_name, artist_name)
    # Filter results by brand
    brand_results = results.select { |r| r["brand"] == brand }

    return { available: false, source: brand.to_sym } if brand_results.empty?

    # Try to find best match
    match = find_best_match(brand_results, song_name, artist_name)

    if match
      {
        available: true,
        source: brand.to_sym,
        song_id: match["no"],
        song_name: match["title"],
        artist_name: match["singer"],
        composer: match["composer"],
        release_date: match["release"]
      }
    else
      # No match found - don't return false positive
      { available: false, source: brand.to_sym }
    end
  end

  def find_best_match(results, song_name, artist_name)
    # Normalize for comparison
    normalized_song = normalize_string(song_name)
    normalized_artist = artist_name ? normalize_string(artist_name) : nil

    # First, try exact title + artist match
    if normalized_artist
      exact_match = results.find do |r|
        normalize_string(r["title"]) == normalized_song &&
          normalize_string(r["singer"] || "").include?(normalized_artist)
      end
      return exact_match if exact_match

      # Try artist match with partial title
      artist_match = results.find do |r|
        singer = normalize_string(r["singer"] || "")
        title = normalize_string(r["title"])
        singer.include?(normalized_artist) &&
          (title.include?(normalized_song) || normalized_song.include?(title))
      end
      return artist_match if artist_match
    end

    # Fall back to title-only match
    results.find do |r|
      normalize_string(r["title"]) == normalized_song
    end
  end

  def normalize_string(str)
    str.to_s.downcase.gsub(/[^\w\s]/, "").strip
  end

  def log_error(message)
    if defined?(Rails) && Rails.respond_to?(:logger)
      Rails.logger.error(message)
    else
      puts "[ERROR] #{message}"
    end
  end
end
