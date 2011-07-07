class Api::InvitationsController < Api::ApiController
  def index
    @user = find_user(params[:user_id])
    @invitations = @user.invitations_sent
    respond_with(@invitations, :location => false)
  end

  def create
    @user = find_user(params[:user_id])
    @invitation = 
      case params[:service]
      when "email"
        @user.invitations_sent.create(
          :service => "email", 
          :email => params[:email])
      end

    head @invitation.try(:valid?) ? :created : :not_acceptable
  end
end
