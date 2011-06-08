class Notifications < ActionMailer::Base
  default :from => "hello@qwiqq.me"
  default_url_options[:host] = "qwiqq.gastownlabs.com"

  def deal_liked(like)
    @deal = like.deal
    @user = like.user
    mail :to => @deal.user.email
  end

  def deal_commented(comment)
    @comment = comment
    @deal = comment.deal
    @user = comment.user
    mail :to => @deal.user.email
  end
end

