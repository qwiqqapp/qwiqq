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
  
  def category_test(target, deal)
    @user = target
    @deal = deal
    mail :to => target.email, 
         :tag => "category",
         :subject => "Because I wanted to test something",
         :template_name => 'sell_deal'
  end
  
  # has target
  def password_reset(target)
    @user = target
    mail :to => target.email, 
         :tag => "password",
         :subject => "Your password reset instructions for Qwiqq"
  end
  
  def welcome_email(target)
    @target = target
    @user = target
    mail :to => target.email, 
         :tag => "welcome",
         :subject => "Welcome to Qwiqq!!!"
  end
  
  def facebook_push(target, follower, share)
    @target = target
    @user = follower
    @share = share
    mail :to => target.email, 
         :tag => "facebook",
         :subject => "Your Facebook friend #{@share} just joined Qwiqq as @#{@user.username}"
  end
  
  def create_post(target)
    @target = target
    @user = target
    mail :to => target.email, 
         :tag => "post",
         :subject => "You haven't created a post yet..."
  end
  
  def share_post(target)
    @target = target
    @user = target
    mail :to => target.email, 
         :tag => "share",
         :subject => "You haven't shared a post yet..."
  end
  
  def missed_email(target)
    @target = target
    @user = target
    mail :to => target.email, 
         :tag => "missed",
         :subject => "You haven't posted in awhile..."
  end
  
  def update_profile(target)
    @target = target
    @user = target
    mail :to => target.email, 
         :tag => "update",
         :subject => "You haven't updated your profile!!!"
  end
  
  def weekly_update(target, deal)
    @target = target
    @user = target
    @deal = deal
    mail :to => target.email, 
         :tag => "update",
         :subject => "What's the community sharing on Qwiqq!"
  end
  
  def constant_contact(target)
    @target = target
    @user = target
    mail :to => target.email, 
         :tag => "Constant Contact",
         :subject => "Thanks for using Constant Contact email integration!"
  end
  
  def constant_contact_trial(target)
    @target = target
    mail :to => target.email, 
         :tag => "Constant Contact Trial",
         :subject => "Free Constant Contact Trial"
  end
  
  # send if recipient notification settings allows
  def deal_liked(target, like)
    @target = target
    @user = like.user
    @deal = like.deal
    @like = like
    mail :to => target.email, 
         :tag => "like",
         :subject => "#{@user.best_name} loved your Qwiqq post!"
  end
  
  def deal_commented(target, comment)
    @target   = target
    @comment  = comment
    @deal     = comment.deal
    @user     = comment.user
    mail :to => target.email, 
         :tag => "comment",
         :subject => "#{@user.best_name} commented on your Qwiqq post!"
  end
  
  def new_follower(target, follower)
    @target = target
    @user = follower
    mail :to => target.email, 
         :tag => "follower",
         :subject => "#{@user.best_name} is now following you."
  end
end

