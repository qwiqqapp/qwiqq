class Api::UsersController < Api::ApiController

  skip_before_filter :require_user

  # will raise RecordNotFound if user not found
  # will render 401 if email does not match
  def create
    user = User.new(params[:user])
    if user.save
      session[:user_id] = user.id
    end
    respond_with :api, user
  end
  
end
