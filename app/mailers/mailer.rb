class Mailer < ActionMailer::Base
  layout "mailer"
  default :from => "notifications@qwiqq.me"

  helper :application
  
  # always send if direct to mail
  def share_deal(target_email, share)
    @deal = share.deal
    @user = share.user
    @share = share
    mail :to => target_email, 
         :tag => "share",
         :subject => "#{@user.name} shared a post with your on Qwiqq!"
  end
  
  def invitation(target_email, from)
    @user = from
    mail :to => target_email, 
         :tag => "invitation",
         :subject => "#{@user.name} has invited you to Qwiqq!"
    
  end
  
  # has target
  def password_reset(target)
    @user = target
    mail :to => target.email, 
         :tag => "password",
         :subject => "Your password reset instructions for Qwiqq"
  end

  # send if recipient notification settings allows
  def deal_liked(target, like)
    @target = target
    @user = like.user
    @deal = like.deal
    @like = like
    mail :to => target.email, 
         :tag => "like",
         :subject => "Someone liked your Qwiqq post!"
  end
  
  def deal_commented(target, comment)
    @target   = target
    @comment  = comment
    @deal     = comment.deal
    @user     = comment.user
    mail :to => target.email, 
         :tag => "comment",
         :subject => "Someone commented on your Qwiqq post!"
  end
  
  def new_follower(target, follower)
    @target = target
    @user = follower
    mail :to => target.email, 
         :tag => "follower",
         :subject => "#{@user.name} is now following you."
  end
end

