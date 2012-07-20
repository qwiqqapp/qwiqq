class Api::SharesController < Api::ApiController


  def create
    deal = Deal.find(params[:deal_id])
    
    # facebook
    # share created with current_facebook_page_id
    if params[:facebook]
      current_user.shares.create( deal: deal, 
                                  service: "facebook", 
                                  message: params[:message],
                                  facebook_page_id: current_user.current_facebook_page_id)
    end
    
    # twitter
    if params[:twitter]
      current_user.shares.create(:deal => deal, :service => "twitter", :message => params[:message])
    end
    
    # foursquare
    if params[:foursquare]
      current_user.shares.create(:deal => deal, :service => "foursquare", :message => params[:message])
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
    
    # constantcontact
    current_user.shares.create(:service => "constantcontact")
    # return 200
    head :ok
  end
end

