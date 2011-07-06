task :reset_user_counts => :environment do
  User.all.each do |user|
    followers = user.followers.size
    following = user.following.size
    friends = user.friends.size

    puts "updating #{user.email} - friends: #{friends}, followers: #{followers}, following: #{following}"

    user.update_attribute(:followers_count, followers)
    user.update_attribute(:following_count, following)
    user.update_attribute(:friends_count,   friends)
  end
end
