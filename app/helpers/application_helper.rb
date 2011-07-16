module ApplicationHelper
  def update_user_notifications_url(user)
    update_notifications_url(:token => user.notifications_token)
  end
end
