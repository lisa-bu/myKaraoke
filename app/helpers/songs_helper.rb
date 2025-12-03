module SongsHelper
  def karaoke_availability_badges(song)
    badges = []

    if song.available_on_dam?
      badges << content_tag(:span, "DAM", class: "karaoke-badge karaoke-badge-dam", title: "Available on DAM")
    end

    if song.available_on_joysound?
      badges << content_tag(:span, "JOY", class: "karaoke-badge karaoke-badge-joysound", title: "Available on Joysound")
    end

    return "" if badges.empty?

    content_tag(:div, safe_join(badges, ""), class: "karaoke-badges")
  end
end
