class TestingController < ApplicationController
  def deal_purchased
    @deal ||= Deal.find(11047)
    
    @transaction = Transaction.create(:deal => @deal, :paypal_transaction_id => 11234);
    
    #@transaction = Transaction.find()
    mail :to => target_email, 
         :tag => "voucher",
         :subject => "You just bought something on Qwiqq!",
         :template_name => 'deal_purchased' 
    render layout: 'deal_purchased'
  end
end
