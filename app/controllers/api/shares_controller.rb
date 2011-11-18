class Api::SharesController < Api::ApiController
  def create
    deal = Deal.find(params[:deal_id])

    # facebook
    facebook_token_invalid =
      begin
        if params[:facebook]
          current_user.shares.create(:deal => deal, :service => "facebook", :message => params[:message])
        end
        false
      rescue Koala::Facebook::APIError => e
        e.message =~ /Error validating access token/
      end 

    # twitter
    if params[:twitter]
      current_user.shares.create(:deal => deal, :service => "twitter", :message => params[:message])
    end

    # foursquare
    if params[:foursquare]
      current_user.shared.create(:deal => deal, :service => "foursquare", :message => params[:message])
    end

    # sms
    numbers = params[:sms_numbers] || []
    numbers.each do |number|
      current_user.shares.create(:deal => deal, :service => "sms", :number => number, :message => params[:message])
    end

    # email
    emails = params[:emails] || []
    emails.each do |email|
      current_user.shares.create(:deal => deal, :service => "email", :email => email, :message => params[:message])
    end

    if facebook_token_invalid
      logger.info "#{current_user.email} has an invalid Facebook token."
      render :status => 422, :json => { :error => "Invalid Facebook access token." }
    else
      head :ok
    end
  end
end

