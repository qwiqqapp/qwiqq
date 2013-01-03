ActiveAdmin.register Transaction do
  #ActiveAdmin.register Deal, :as => "Deals" do
  menu :label => "Transactions"
  actions :index, :destroy
  
  scope :all, :default => true
  
  csv do
    column("ID"){|transaction| transaction.id.try(:to_s)}
    column("Paypal Transaction ID"){ |transaction| transaction.paypal_transaction_id }
    column("Buyer ID"){ |transaction| transaction.user.id }
    column("Buyer Username"){ |transaction| transaction.user.username }
    column("Seller ID"){ |transaction| transaction.deal.user.id }
    column("Seller Username"){ |transaction| transaction.deal.user.username }
    column("Deal ID") {|transaction| transaction.deal.id.try(:to_s)}
  end
    
  index do
    column("Buyer", :sortable => :user.name) do |transaction|  
      link_to(transaction.user.name, [ :admin, transaction.user ]) if transaction.user
    end
    
    column("Seller", :sortable => :deal.user.name) do |transaction|  
      link_to(transaction.deal.user.name, [ :admin, transaction.deal.user ]) if transaction.deal.user
    end
    
    column("Deal", :sortable => :deal.name) do |transaction|  
      link_to(transaction.deal.name, [ :admin, transaction.deal ]) if transaction.deal
    end

    column("Paypal Transaction ID"){ |transaction| transaction.paypal_transaction_id }
    
    default_actions
  end
end
