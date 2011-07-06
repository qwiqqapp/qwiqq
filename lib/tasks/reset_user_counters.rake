task :reset_user_counts => :environment do
  User.all.each do |user|
    user.update_attributes(
      :followers_count => user.followers.size,
      :following_count => user.following.size,
      :friends_count => user.friends.size)
  end
end