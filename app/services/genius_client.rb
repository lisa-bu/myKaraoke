class GeniusClient
  include Singleton
  include HTTParty

  BASE_URL = "https://api.genius.com"

  def initialize
    @access_token = ENV["GENIUS_CLIENT_ACCESS_TOKEN"]
  end

  # Search for a song and return the Genius URL
  def search(title, artist)
    query = "#{title} #{artist}".strip
    response = self.class.get(
      "#{BASE_URL}/search",
      headers: auth_headers,
      query: { q: query }
    )

    return nil unless response.success?

    hits = response.dig("response", "hits")
    return nil if hits.blank?

    # Find the best match - prioritize exact artist matches
    best_hit = hits.find do |hit|
      hit_artist = hit.dig("result", "primary_artist", "name")&.downcase
      artist.downcase.include?(hit_artist&.split&.first || "") ||
        hit_artist&.include?(artist.downcase.split.first)
    end

    best_hit ||= hits.first
    best_hit&.dig("result", "url")
  end

  # Fetch and scrape lyrics from a Genius URL
  def fetch_lyrics(genius_url)
    return nil if genius_url.blank?

    response = self.class.get(genius_url, headers: browser_headers)
    return nil unless response.success?

    parse_lyrics(response.body)
  end

  # Convenience method: search and fetch lyrics in one call
  def lyrics_for(title, artist)
    url = search(title, artist)
    return nil unless url

    fetch_lyrics(url)
  end

  private

  def auth_headers
    {
      "Authorization" => "Bearer #{@access_token}"
    }
  end

  def browser_headers
    {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    }
  end

  def parse_lyrics(html)
    doc = Nokogiri::HTML(html)

    # Genius uses data-lyrics-container="true" for lyrics sections
    lyrics_containers = doc.css('[data-lyrics-container="true"]')

    if lyrics_containers.any?
      lyrics = lyrics_containers.map do |container|
        # Clone the container to avoid modifying the original
        container_clone = container.dup

        # Remove header/metadata elements (Contributors, Translations, etc.)
        container_clone.css('[data-exclude-from-selection]').remove

        # Remove annotation links but keep their text content
        container_clone.css("a").each { |a| a.replace(a.text) }

        # Replace <br> tags with newlines before extracting text
        container_clone.inner_html.gsub(/<br\s*\/?>/, "\n")
      end.join("\n\n")

      # Clean up HTML tags and normalize whitespace
      clean_lyrics = Nokogiri::HTML(lyrics).text
      clean_lyrics.gsub(/\n{3,}/, "\n\n").strip
    else
      # Fallback: try older Genius page structure
      lyrics_div = doc.css(".lyrics").first
      lyrics_div&.text&.strip
    end
  end
end
