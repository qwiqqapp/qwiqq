class Api::SharesController < Api::ApiController

  def socialyze
    
  end

  def create
    puts '/shares - start'
    deal = Deal.find(params[:deal_id])
    
    message = params[:message].slice(0,255)
    # facebook
    # share created with current_facebook_page_id
    if params[:facebook]
      current_user.shares.create( deal: deal, 
                                  service: "facebook", 
                                  message: message,
                                  facebook_page_id: current_user.current_facebook_page_id)
    end
    
    # twitter
    if params[:twitter]
      
      current_user.shares.create(:deal => deal, :service => "twitter", :message => message)
    end
    
    # foursquare
    if params[:foursquare]
      current_user.shares.create(:deal => deal, :service => "foursquare", :message => message)
    end
    
    # sms
    numbers = params[:sms_numbers] || []
    numbers.each do |number|
      current_user.shares.create(:deal => deal, :service => "sms", :number => number, :message => message)
    end
    
    # email
    emails = params[:emails] || []
    emails.each do |email|
      current_user.shares.create(:deal => deal, :service => "email", :email => email, :message => message)
    end
    
    # constantcontact
    if params[:constantcontact]
      puts 'CREATED CC IN SHARE CONT'
      current_user.shares.create(:deal => deal, :service => "constantcontact", :message => message)
    end

    # return 200
    render :json => {}
    puts '/shares - fini'
  end
end

