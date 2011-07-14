class Api::SessionsController < Api::ApiController

  skip_before_filter :require_user

  # will render 401 if users creds dont authenticate
  def create    
    user = User.authenticate(params[:user][:email], params[:user][:password])
    if user
      session[:user_id] = user.id
      render :json => user
    else
      render :json => {:message  => 'Wrong email or password'}, :status => 401
    end
  end
  
  def destroy
    reset_session
    render :json => {}
  end
end