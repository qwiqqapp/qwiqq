task :reset_user_counts => :environment do
  User.find_each do |user|
    followers = user.followers.count
    following = user.following.count
    
    puts "updating #{user.email} - followers: #{followers}, following: #{following}"

    user.update_attribute(:followers_count, followers)
    user.update_attribute(:following_count, following)
  end
end
