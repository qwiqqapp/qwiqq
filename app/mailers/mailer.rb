class Mailer < ActionMailer::Base
  layout 'mailer'
  default :from => "notifications@qwiqq.me"
  
  # always send if direct to mail
  def share_deal(target_email, share)
    @deal = share.deal
    @user = share.user
    mail :to => target_email, :subject => "#{@user.name} shared a Qwiqq deal with you!"
  end
  
  def invitation(target_email, from)
    @user = from
    mail :to => target_email, :subject => "#{@user.name} has invited you to Qwiqq!"
  end
  
  # has target
  def password_reset(target)
    @user = target
    mail :to => target.email, :subject => "Your password reset instructions for Qwiqq"
  end

  # send if recipient notification settings allows
  def deal_liked(target, like)
    attachments["logo.png"] = File.read("#{Rails.root}/public/images/email/email-logo.png") 
    
    @user = target
    @deal = like.deal
    mail :to => target.email, :subject => "Someone liked your Qwiqq deal!"
  end
  
  def deal_commented(target, comment)
    @comment  = comment
    @deal     = comment.deal
    @user     = comment.user
    mail :to => target.email, :subject => "Someone commented on your Qwiqq deal!"
  end
  
  def new_follower(target, follower)
    @user = follower
    mail :to => target.email, :subject => "#{@user.name} is now following you."
  end
  
  def new_friend(target, friend)
    @user = friend
    mail :to => target.email, :subject => "You and #{@user.name} are now friends."
  end
end

