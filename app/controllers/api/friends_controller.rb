class Api::FriendsController < Api::ApiController
  def find
    user = find_user(params[:user_id])
    collection = 
      case params[:service]
        when "email"
          find_friends_by_email(user, params[:emails])
      end

    render :json => collection.as_json
  end

  private
    def find_friends_by_email(user, emails)
      emails.map do |email|
        friend = User.find_by_email(email)
        if friend
          # user found, check if the user is following them
          { :email => email,
            :user_id => friend.id,
            :state => user.following?(friend) ? 
              :following : 
              :not_following }
        else
          # user not found, check if they've been invited
          { :email => email,
            :state => user.email_invitation_sent?(email) ? 
              :invited : 
              :not_invited }
        end
      end
    end
end
