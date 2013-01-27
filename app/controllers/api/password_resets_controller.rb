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
  
  def update
    @user = User.validate_password_reset(params[:id])
    
    if @user
      puts "updating user for password reset: #{@user.id}"
      @user.update_attributes(:password => params[:password]) #update with posted password
      session[:user_id] = @user.id if @user.valid?            #login if @user is valid
      respond_with(:api, @user) do
        render :json => @user.as_json and return if @user.valid?
      end
    else
      render :json => {:message  => "That password reset token is no longer valid, please request another."}, :status => 404
    end
    
  end
  
  
end