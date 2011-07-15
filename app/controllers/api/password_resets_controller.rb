class Api::PasswordResetsController < Api::ApiController
  
  skip_before_filter :require_user
  
  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset!
      render :json => {:message  => "We've sent an email to #{params[:email]} containing password reset directions."}, 
             :status => 201
    else  
      render :json => {:message  => "Unable to find user with email #{params[:email]} sorry."}, 
             :status => 404
    end
  end
  
  def show
    @user = User.validate_password_reset(params[:id])
    if @user
      respond_with(@user)
    else  
      render :json => {:message  => "That password reset token is no longer valid, please request another."}, 
             :status => 404
    end
    
  end
  
  
end