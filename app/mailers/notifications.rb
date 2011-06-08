class Notifications < ActionMailer::Base
  default :from => "hello@qwiqq.me"

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

