class UsersController < ApplicationController
  def update_notifications
    @user = User.find_by_notifications_token(params[:token])
    redirect_to root_url if @user.nil?
    @user.update_attributes(:send_notifications => params[:enable] || false)
    render :notifications_disabled, layout: 'basic'
  end

  def show
    @user = User.find(params[:id])
    # TODO pagination
    @deals = @user.deals.sorted.first(5)
  end
end
