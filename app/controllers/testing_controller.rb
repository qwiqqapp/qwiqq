class TestingController < ApplicationController
  def deal_purchased
    @deal ||= Deal.find(11049)
    
    @transaction = Transaction.create(:deal => @deal, :paypal_transaction_id => rand(10000000));
    
    @transaction.user = User.find(12998)
    @transaction.email = @transaction.user.email;
    
    #@transaction = Transaction.find()
    #mail :to => 'copley.brandon@gmail.com', 
    #     :tag => "voucher",
    #     :subject => "You just bought something on Qwiqq!",
    #     :template_name => 'deal_purchased' 
    render layout: 'deal_purchased'
  end
  
  def deal_sold
    @deal ||= Deal.find(11049)
    
    @transaction = Transaction.create(:deal => @deal, :paypal_transaction_id => rand(10000000));
    
    @transaction.user = User.find(12998)
    @transaction.email = @transaction.user.email;
    
    #@transaction = Transaction.find()
    #mail :to => 'copley.brandon@gmail.com', 
    #     :tag => "voucher",
    #     :subject => "You just bought something on Qwiqq!",
    #     :template_name => 'deal_purchased' 
    render layout: 'deal_sold'
  end
  
end