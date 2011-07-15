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

  def invitation(user, email)
    @user = user
    mail :to => email, :subject => "#{@user.name} has invited you to Qwiqq!"
  end
  
  def password_reset(user, email)
    @user = user
    mail :to => email, :subject => "Your password reset instructions for Qwiqq"
  end
  
  def new_follower(user, email)
    @user = user
    mail :to => email, :subject => "#{user.name} is now following you."
  end
  
  def new_friend(user, email)
    @user = user
    mail :to => email, :subject => "You and #{user.name} are now friends."
  end
end

