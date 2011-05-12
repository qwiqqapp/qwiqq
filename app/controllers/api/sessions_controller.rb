class Api::SessionsController < Api::ApiController

  skip_before_filter :require_user

  # will raise RecordNotFound if user not found
  # will render 401 if email does not match
  def create
    user = User.authenticate!(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      render :json => user
    else
      render :json => {:message  => 'Not Authorized'}, :status => 401
    end
  end
  
  def destroy
    reset_session
    render :json => {}
  end
end