require 'adaptive_pay'

class Api::TransactionsController < Api::ApiController

  skip_before_filter :require_user
  skip_before_filter :verify_authenticity_token, :only => [:ipn]
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
    puts "TEST TRANSACTION"
    paypal_response = AdaptivePay::Callback.new(params, request.raw_post)

    if paypal_response.completed? && paypal_response.valid?
      # mark your payment as complete and make them unicorns happy!
      puts "TRANSACTION VERIFIED"
      puts "MARK deal_id: #{params[:deal_id]} buyerid: #{params[:buyer_id]} paypal_transaction_id: #{params[:txn_id]}  payment_status: #{params[:payment_status]}"
      @deal = Deal.find(params[:deal_id])
      @transaction = @deal.transactions.build
      @transaction.user = User.find(params[:buyer_id])
      @transaction.paypal_transaction_id = params[:txn_id]
      @transaction.save!
    else
      puts "TRANSACTION NOT VERIFIED"
    end
    render :nothing => true
  end

  
  def ipn
    puts "TEST TRANSACTION IN IPN"
    puts "MARK deal_id: #{params[:deal_id]} buyerid: #{params[:buyer_id]} paypal_transaction_id: #{params[:txn_id]}  payment_status: #{params[:payment_status]} IN IPN"
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
