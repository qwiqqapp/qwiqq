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
    
    puts 'params: '
    puts params
    
    if paypal_response.completed?
      if paypal_response.valid?
        # mark your payment as complete and make them unicorns happy!
        puts "TRANSACTION VERIFIED"
        
        @deal = Deal.find(params[:deal_id])
        @deal.num_left_for_sale=@deal.num_left_for_sale-1
        @deal.save!
        
        @transaction = @deal.transactions.build
        @transaction.user = User.find(params[:buyer_id])
  
  
        if params[:sandbox] == 'true'
          @transaction.paypal_transaction_id = params[:txn_id] if params[:txn_id]
        else
          trans = params[:transaction]
          
          
          puts 'trans: '
          puts trans
          
          firstReceiver = trans['0']
          theID = firstReceiver['.id']
          puts "RECEVIER ID:#{theID}"
          
          if Transaction.exists?(:transaction => theID)
            puts 'the transaction already exists...therefore we dont send an email'
          else
            Mailer.deal_purchased(@transaction.user, @deal, @transaction).deliver
            puts 'transaction doesnt look like a repeat so we emailed the user'
          end
          
          @transaction.paypal_transaction_id = theID if theID != nil
        end
        
        
        
        @transaction.save!
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
