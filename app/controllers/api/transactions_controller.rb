require 'adaptive_pay'

class Api::TransactionsController < Api::ApiController

  skip_before_filter :require_user 
  caches_action :index, :cache_path => lambda {|c| "#{c.find_parent.cache_key}/transactions" },
    :unless => lambda {|c| c.params[:page] }

  # return list of transaction for deal or user:
  # - api/users/:user_id/transaction => returns transactions
  # - api/deals/:deal_id/transaction => returns transactions
  # - return 404 if neither deal_id or user_id provided
  
  def index
    @transaction = find_parent.transactions.includes(:user, :deal)
    respond_with(paginate(@transactions), :include => [:user])
  end

  # auth not required
  def create
    #puts "BEGIN TRANSACTION AUTH PARAMS:#{params}"
    
    puts 'trying to create transaction'
    
    #michael's way
    paypal_response = AdaptivePay::Callback.new(params, request.raw_post)
    
    #notes from here...https://github.com/derfred/adaptive_pay
    #paypal_response = AdaptivePay::Callback.new params
    
    if paypal_response.completed?
      
      puts 'params';
      puts params;
      
      if paypal_response.valid?
        # mark your payment as complete and make them unicorns happy!
        puts "TRANSACTION VERIFIED"
        
        @deal = Deal.find(params[:deal_id])
        
        puts 'deal'
        puts @deal
        
  
        if params[:sandbox] == 'true'
          puts "well we are in the sandbox...deal.event:#{@deal.events.count}"
          u = User.find(params[:buyer_id])
          @deal.events.create(
               :event_type => "sold", 
               :user => @deal.user,
               :created_by => u,
               :is_web_event => true)


         u.events.create(
                :event_type => "purchase", 
                :deal => @deal,
                :is_web_event => true)
               
          puts "created sandbox web sold test:#{@deal.events.count}"
          #puts "created sandbox web event"
        else
          trans = params[:transaction]
          
          
          puts 'params: '
          puts params
          
          firstReceiver = trans['0']
          theID = firstReceiver['.id']
          puts "RECEVIER ID:#{theID}"
          
          if Transaction.exists?(:paypal_transaction_id => theID)
            puts 'the transaction already exists...therefore we dont send an email'
          else
            
            @transaction = Transaction.create(:deal => @deal, :paypal_transaction_id => theID)
            if params[:buyer_id]
              @transaction.user = User.find(params[:buyer_id])
              @transaction.email = @transaction.user.email;
            else
              #web purchase
              email = params[:sender_email]
              @transaction.email = email;
            end
            #@transaction.deal = @deal
            puts 'saving transaction...'
            @transaction.save!
            puts "number BEFORE sale:#{@deal.num_left_for_sale}"
            @deal.num_left_for_sale=@deal.num_left_for_sale-1
            @deal.save!
            puts "number LEFT after sale:#{@deal.num_left_for_sale}"
            #email = string...
            
            if(@transaction.user.nil?)
              puts "user should be nil"
              Mailer.deal_purchased(@transaction.email, @deal, @transaction).deliver
              Mailer.deal_sold(@deal.user.email, @deal, @transaction).deliver
              puts "create websold event"
              #send a push notification to seller and create generic event for seller's deal
              @deal.events.create(
                :event_type => "sold",
                :user => @deal.user,
                :is_web_event => true)

            else
              Mailer.deal_purchased(@transaction.user.email, @deal, @transaction).deliver
              Mailer.deal_sold(@deal.user.email, @deal, @transaction).deliver
              
              puts "create sold event"
              #send a push notification to seller and create event for seller's deal
              @deal.events.create(
               :event_type => "sold", 
               :user => @deal.user,
               :created_by => @transaction.user,
               :is_web_event => true)
         
                        
              puts "create purchased event"
              #create user event for buyer

              @transaction.user.events.create(
                :event_type => "purchase", 
                :deal => @deal,
                :is_web_event => true)
              
              puts "create event successful"
            end
            
            #Mailer.deal_purchased(email, @deal, @transaction).deliver
            puts 'transaction doesnt look like a repeat so we emailed the user'

            
          end
          
          @transaction.paypal_transaction_id = theID if theID != nil
        end
        
      else
        puts 'Well this is a huge security issue, someone is trying to steal from us!!, or we are testing things...'
      end
    else
      puts "TRANSACTION NOT VERIFIED"
    end
    
    render :nothing => true
  end
  
  def destroy
    @transaction = current_user.transactions.find(params[:id])
    @transaction.destroy
    respond_with(@transaction, :location => false)
  end
  
  def find_parent
    @parent ||= 
      if params[:deal_id]
        Deal.find(params[:deal_id])
      elsif params[:user_id]
        find_user(params[:user_id])
      else
        raise RecordNotFound
      end
  end
end
