class Api::SharesController < Api::ApiController
  def create
    @user = current_user
    @deal = Deal.find(params[:deal_id])

    # facebook
    facebook_token_invalid =
      begin
        @user.shares.create(:deal => @deal, :service => "facebook") if params[:facebook]
        false
      rescue Koala::Facebook::APIError => e
        e.message =~ /Error validating access token/
      end 

    # twitter
    @user.shares.create(:deal => @deal, :service => "twitter")  if params[:twitter]

    # sms
    numbers = params[:sms_numbers] || []
    numbers.each do |number|
      @user.shares.create(:deal => @deal, :service => "sms", :number => number)
    end

    # email
    emails = params[:emails] || []
    emails.each do |email|
      @user.shares.create(:deal => @deal, :service => "email", :email => email)
    end

    if facebook_token_invalid
      logger.info "#{current_user.email} has an invalid Facebook token."
      render :status => 422, :json => { :error => "Invalid Facebook access token." }
    else
      head :ok
    end
  end
end

