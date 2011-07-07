class Mailer < ActionMailer::Base
  default :from => "notifications@qwiqq.me"

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
  
  def share_deal(deal, email)
    @deal = deal
    @user = deal.user
    mail :to => email, :subject => "#{@user.name} shared a Qwiqq deal with you!"
  end
end

