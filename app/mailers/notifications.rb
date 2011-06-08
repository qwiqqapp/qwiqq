class Notifications < ActionMailer::Base
  default :from => "hello@qwiqq.me"

  def deal_liked(like)
    @deal = like.deal
    @user = like.user
    mail :to => @deal.user.email, :subject => "Someone liked your Qwiqq deal!"
  end

  def deal_commented(comment)
    @comment = comment
    @deal = comment.deal
    @user = comment.user
    mail :to => @deal.user.email, :subject => "Someone commented on your Qwiqq deal!"
  end
end

