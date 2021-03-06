module ApplicationHelper
  
  #def link_to(*args, &block)
  #  
  #  puts 'block-given#{args.first}'
  #  
  #  if block_given?
  #    args = [(args.first || {}), (args.second || {})]
  #  else
  #    args = [(args.first || {}), (args.second || {}), (args.third || {})]
  #  end
  #  super(args, block)
  #end
  
  def pinterest_url_for(deal)
    url = "http://pinterest.com/pin/create/button/"
    url << "?url=#{deal_url(deal)}"
    url << "&media=#{deal.photo.url(:iphone_zoom_2x)}"
    #url << "&description=shop#small"
    url << "&description=#{CGI::escape(deal.name.titleize)} #{CGI::escape('#shopsmall')}"
    if deal.for_sale_on_paypal 
      if deal.num_left_for_sale > 0
        url << " BUY NOW" 
      elsif deal.num_left_for_sale == 0
        url << " SOLD OUT" 
      end
    end
    url << " #{deal.price_as_string}" if deal.price
    url
  end
  
  def pinterest_url_for_sold(deal)
    url = "http://pinterest.com/pin/create/button/"
    url << "?url=#{deal_url(deal)}"
    url << "&media=#{deal.photo.url(:iphone_zoom_2x)}"
    url << "&description=I just sold this on @Qwiqq! #{CGI::escape(deal.name.titleize)} #{CGI::escape('#shopsmall')}"
    if deal.for_sale_on_paypal 
      if deal.num_left_for_sale > 0
        url << " BUY NOW" 
      elsif deal.num_left_for_sale == 0
        url << " SOLD OUT" 
      end
    end
    
    url << " #{deal.price_as_string}" if deal.price
      url
    end
  
    def pinterest_url_for_bought(deal)
    url = "http://pinterest.com/pin/create/button/"
    url << "?url=#{deal_url(deal)}"
    url << "&media=#{deal.photo.url(:iphone_zoom_2x)}"
    url << "&description=I just bought this on @Qwiqq! #{CGI::escape(deal.name.titleize)} #{CGI::escape('#shopsmall')}"
    if deal.for_sale_on_paypal 
      if deal.num_left_for_sale > 0
        url << " BUY NOW" 
      elsif deal.num_left_for_sale == 0
        url << " SOLD OUT" 
      end
    end
    url << " #{deal.price_as_string}" if deal.price
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
    "http://get.qwiqq.me"
  end

  def event_body(event)
    linked_name = "@#{event.created_by.username}"
    user = User.find(:first, :conditions => [ "lower(username) = ?", event.created_by.username.downcase ])
    if !user.nil?
      linked_name = "<a href='http://www.qwiqq.me/users/#{user.id}'>@#{user.username}</a>"
    else 
      linked_name = "Somebody"
    end
    case event.event_type
    when "like"
      "#{linked_name} loved this"
    when "comment"
      "#{linked_name} said #{event.metadata[:body]}"
    when "sold"
      "Yeah! Sold another one!"
    when "share"
      case event.metadata[:service]
      when "sms"
      "#{linked_name} shared on SMS"
      when "constantcontact"
      "#{linked_name} shared on Constant Contact"
      else
      "#{linked_name} shared on #{event.metadata[:service].titleize}"
      end
    end
  end

  def event_icon(event)
    case event.event_type
    when "like"
      "buzz-love-icon.png"
    when "comment"
      "buzz-comment-icon.png"
    when "sold"
      "buzz-paypal-icon.png"
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

