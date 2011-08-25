module ApplicationHelper
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

  def price_string(deal)
    if (deal.price && deal.price == 0) || (deal.percent && deal.percent == 0)
      "FREE"
    elsif deal.price
      deal.price_as_string
    else
      "#{deal.percent}% OFF"
    end
  end
end
