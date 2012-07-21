module ApplicationHelper
  
  def pinterest_url_for(deal)
    url = "http://pinterest.com/pin/create/button/"
    url << "?url=#{deal_url(deal)}"
    url << "&media=#{deal.photo.url(:iphone_zoom_2x)}"
    url << "&description=#{CGI::escape(deal.name.titleize)} #{deal.price_as_string}"
    url << " @ #{deal.foursquare_venue_name}" if deal.foursquare_venue_name
    url << " via Qwiqq.me"
    url
  end
  
  def update_user_notifications_url(user)
    update_notifications_url(:token => user.notifications_token)
  end

  def emojify(string)
    string = HTMLEntities.new.encode(string, :hexadecimal)
    string = string.gsub(/&#xe([^;]+);/m) do
      "<span id=\"char\" class=\"emoji emoji_e#{$1}\"> </span>"
    end
    string.html_safe
  end

  def strip_emoji(string)
    string = HTMLEntities.new.encode(string, :hexadecimal)
    string.gsub(/&#xe([^;]+);/m, " ").html_safe
  end

  def download_url
    "http://download.qwiqq.me"
  end

  def event_body(event)
    case event.event_type
    when "like"
      "#{event.created_by.username} loved this"
    when "comment"
      emojify "#{event.created_by.username} said \"#{event.metadata[:body]}\""
    when "share"
      if "#{event.metadata[:service]}" == "sms"
        "#{event.created_by_username} shared on SMS}"
      end
      "#{event.created_by_username} shared on #{event.metadata[:service].titleize}"
    end
  end

  def event_icon(event)
    case event.event_type
    when "like"
      "buzz-love-icon.png"
    when "comment"
      "buzz-comment-icon.png"
    when "share"
      case event.metadata[:service]
      when "facebook"
        "buzz-facebook-icon.png"
      when "twitter"
        "buzz-twitter-icon.png"
      when "foursquare"
        "buzz-4sq-icon.png"
      when "email"
        "buzz-email-icon.png"
      when "constantcontact"
        "buzz-constantcontact-icon.png"
      when "sms"
        "buzz-sms-icon.png"
      else 
        "buzz-comment-icon.png"
      end
    end
  end
end

