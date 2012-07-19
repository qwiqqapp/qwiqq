class Api::CreatePostsController < Api::ApiController
    
  def index
    @user = User.find_by_email(params[:email])
    if @user
    Mailer.create_post(@user).deliver
      render :json => {:message  => "We've sent an email to #{params[:email]}!!!"}, 
             :status => 201
    else  
      render :json => {:message  => "Unable to find email(#{params[:email]}) for user, sorry."}, 
             :status => 404
    end
  end
  
end