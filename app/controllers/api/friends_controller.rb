class Api::FriendsController < Api::ApiController
  def find
    collection = 
      case params[:service]
        when "email"
          params[:emails] ? find_friends_by_email(current_user, params[:emails]) : []
        when "twitter"
          find_friends_on_twitter(current_user)
        when "facebook"
          find_friends_on_facebook(current_user)
        else
          head :not_acceptable and return
      end

    render :json => collection.as_json
  end

  private
    def find_friends_by_email(user, emails)
      # make sure current user isn't in the list of emails
      emails.delete(user.email)
      friends = User.sorted.where(:email => emails)
      friends.map! do |friend|
        # friend found, remove email and check if the user is following them
        emails.delete(friend.email)
        friend.as_json(:current_user => current_user).merge({
          :state => user.following?(friend) ? 
            :following : 
            :not_following })
      end

      # any remaining emails were not users, check if invitations were sent
      emails.each do |email|
        friends << { 
          :email => email,
          :state => user.email_invitation_sent?(email) ? 
            :invited : 
            :not_invited }
      end

      friends.sort_by {|f| f[:username] }
    end

    def find_friends_on_twitter(user)
      # find twitter friends 
      puts "find_friends_on_twitter called"
      twitter_ids = user.twitter_friend_ids
      puts "Twitter ids - #{twitter_ids}"
      #friends = User.sorted.where(:twitter_id => twitter_ids).order("first_name, last_name DESC")
      friends = User.where("twitter_id.to_i IN (?)", twitter_ids).to_a
      json = Array.new
      friends.map do |friend|
        puts "Friends id:#{friend.twitter_id}"
        twitter_ids.delete(friend.twitter_id) 
        json << friend.as_json(:current_user => current_user).merge({
          :state => user.following?(friend) ? :following : :not_following })
      end
      json << twitter_ids
      render :json => json
    end
    
    def find_friends_on_facebook(user)
      user.facebook_friends.map do |friend|
        friend.as_json(:current_user => current_user).merge({
          :state => user.following?(friend) ? 
            :following : 
            :not_following })
      end
    end
end
