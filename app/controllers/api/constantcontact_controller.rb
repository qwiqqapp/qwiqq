class Api::ConstantcontactController < Api::ApiController

  def create
    @user = current_user
    return unless current_user.send_notifications    # only send if user has notifications enabled
    Mailer.constant_contact(@user).deliver
    respond_with @user
  end
  
  def email
    puts "create email to send"
    render layout: 'share_post'
  end
end
