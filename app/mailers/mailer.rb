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
         :subject => "#{@user.best_name} shared a post with you on Qwiqq!"
  end
  
  def invitation(target_email, from)
    @user = from
    mail :to => target_email, 
         :tag => "invitation",
         :subject => "#{@user.best_name} has invited you to Qwiqq!"
    
  end
  
  # has target
  def password_reset(target)
    @user = target
    mail :to => target.email, 
         :tag => "password",
         :subject => "Your password reset instructions for Qwiqq"
  end
  
  def welcome_email(target)
    @user = target
    mail :to => target.email, 
         :tag => "welcome",
         :subject => "Welcome to Qwiqq!!!"
  end
  
  def create_post(target)
    @user = target
    mail :to => target.email, 
         :tag => "post",
         :subject => "You haven't created a post yet..."
  end
  def share_post(target)
    @user = target
    mail :to => target.email, 
         :tag => "share",
         :subject => "You haven't shared a post yet..."
  end
  def missed_email(target)
    @user = target
    mail :to => target.email, 
         :tag => "missed",
         :subject => "You haven't posted in awhile..."
  end
  
  def weekly_update(target, deals)
    @user = target
    @deal = deals
    mail :to => target.email, 
         :tag => "update",
         :subject => "What's been going on in Qwiqq!"
  end
  
  # send if recipient notification settings allows
  def deal_liked(target, like)
    @target = target
    @user = like.user
    @deal = like.deal
    @like = like
    mail :to => target.email, 
         :tag => "like",
         :subject => "Someone loved your Qwiqq post!"
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
         :subject => "#{@user.best_name} is now following you."
  end
end

