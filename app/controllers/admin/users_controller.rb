class Admin::UsersController < Admin::AdminController
  
  def index
    @users = User.all
    @title = "#{@users.size} Users"
  end
  
  
end