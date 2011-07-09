class Api::FriendsController < Api::ApiController
  def find
    user = find_user(params[:user_id])
    collection = 
      case params[:service]
        when "email"
          find_friends_by_email(user, params[:emails])
        when "twitter"
          find_friends_on_twitter(user)
        when "facebook"
          find_friends_on_facebook(user)
        else
          head :not_acceptable and return
      end

    render :json => collection.as_json
  end

  private
    def find_friends_by_email(user, emails)
      # TODO use SELECT ... WHERE IN ( ... )
      emails.map do |email|
        if friend = User.find_by_email(email)
          # friend found, check if the user is following them
          { :email => email,
            :user_id => friend.id,
            :state => user.following?(friend) ? 
              :following : 
              :not_following }
        else
          # friend not found, check if they've been invited
          { :email => email,
            :state => user.email_invitation_sent?(email) ? 
              :invited : 
              :not_invited }
        end
      end
    end

    def find_friends_on_twitter(user)
      twitter_friends = user.twitter_client.friends
      twitter_friends.map do |twitter_friend|
        if friend = User.find_by_twitter_id(twitter_friend["id"])
          # friend found, check if the user is following them
          { :email => friend.email,
            :user_id => friend.id,
            :state => user.following?(friend) ? 
              :following : 
              :not_following }
        end
      end
    end
end
