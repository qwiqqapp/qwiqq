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

  def city
    puts "CITY:#{params[:city]}"
    @users = User.where("lower(city) = ?", params[:city].downcase)
    puts "CITY USERS:#{@users}"
    render :json => @users.as_json
  end

  def nearby_cities
    puts "LAT:#{params[:lat]}, LON:#{params[:lon]}"
    # @users = User.all(:conditions => ["lat IN (?) AND lon IN (?)", (params[:lat] - 0.35)..(params[:lat] + 0.35)], (params[:lon] - 0.35)..(params[:lon] + 0.35)])
    @users = User.all(:conditions => ["lat IN (?)", (params[:lat] - 0.35)..(params[:lat] + 0.35)])
    puts "LAT USERS:#{@users}"
    render :json => @users.as_json
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
      twitter_ids = user.twitter_follower_ids
      puts "find_friends_on_twitter called count:#{twitter_ids.count}"
      twitter_ids = twitter_ids[0, 500]
      puts "NOW TWITTER COUNT:#{twitter_ids.count}"
      friends = User.sorted.where(:twitter_id => twitter_ids).order("first_name, last_name DESC")
      #friends = User.where("twitter_id.to_i IN (?)", twitter_ids).to_a
      json = []
      json << friends.map.each do |friend|
        twitter_ids.delete(friend.twitter_id) 
        friend.as_json(:current_user => current_user).merge({:state => user.following?(friend) ? :following : :not_following })
      end
      json << twitter_ids
      json
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
