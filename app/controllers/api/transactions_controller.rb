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
    puts "BEGIN TRANSACTION AUTH PARAMS:#{params}"
    trans = params[:transaction]
    firstReceiver = trans[0]
    puts "TRANSACTION AT [0]#{trans}"
    theID = firstReceiver[:id_for_sender_txn]
    puts "RECEVIER ID:#{theID}"
    puts "PARAMS[TRANSACTION]:#{params[:transaction]}"
    paypal_response = AdaptivePay::Callback.new(params, request.raw_post)

    if paypal_response.completed? && paypal_response.valid?
      # mark your payment as complete and make them unicorns happy!
      puts "TRANSACTION VERIFIED"
      puts "MARK deal_id: #{params[:deal_id]} buyerid: #{params[:buyer_id]} paypal_transaction_id: #{params[:txn_id]}  payment_status: #{params[:payment_status]}"
      @deal = Deal.find(params[:deal_id])
      @transaction = @deal.transactions.build
      @transaction.user = User.find(params[:buyer_id])
      
      if @params[:sandbox] == 'true'
        @transaction.paypal_transaction_id = params[:txn_id]
      else
        #puts "TRANSACTION ID FOR LIVE:#{params[:transaction[0].id_for_sender_txn]}"
        #@transaction.paypal_transaction_id = params[:transaction[0].id_for_sender_txn]
      end
      
      @transaction.save!
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
