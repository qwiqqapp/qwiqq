class Api::SharesController < Api::ApiController
  def create
    @user = find_user(params[:user_id])
    @deal = Deal.find(params[:deal_id])

    # facebook and twitter   
    @user.shares.create(:deal => @deal, :service => "facebook") if params[:facebook]
    @user.shares.create(:deal => @deal, :service => "twitter") if params[:twitter]

    # email
    emails = params[:emails] || []
    emails.each do |email|
      @user.shares.create(:deal => @deal, :service => "email", :email => email)
    end

    head :ok
  end
end

