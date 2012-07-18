class Api::WelcomeEmailsController < Api::ApiController
    
  def mail
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_welcome_email!
      render :json => {:message  => "We've sent an welcome email to #{params[:email]}. Thanks for joining!"}, 
             :status => 201
    else  
      render :json => {:message  => "Unable to find email(#{params[:email]}) for user, sorry."}, 
             :status => 404
    end
  end
  
end