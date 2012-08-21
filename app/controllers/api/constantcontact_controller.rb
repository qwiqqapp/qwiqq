class Api::ConstantcontactController < Api::ApiController
  def index
    @user = current_user
    Mailer.constant_contact(@user).deliver
  end

  def create
    @user = current_user
    Mailer.constant_contact(@user).deliver
    respond_with @user
  end
end
