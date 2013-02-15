class Api::ConstantcontactController < Api::ApiController

  def create
    @user = current_user
    return unless current_user.send_notifications    # only send if user has notifications enabled
    Mailer.constant_contact(@user).deliver
    respond_with @user
  end
  
  def email
    puts "create email to send"
    #render layout: 'share_post'
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
