ActiveAdmin.register Transaction do
  #ActiveAdmin.register Deal, :as => "Deals" do
  menu :label => "Transactions"
  actions :index, :destroy
  
  scope :all, :default => true
  filter :created_at 
  
  csv do
    column("ID"){|transaction| transaction.id.try(:to_s)}
    column("Paypal Transaction ID"){ |transaction| transaction.paypal_transaction_id }
    column("Buyer ID"){ |transaction| transaction.user.id }
    column("Buyer Username"){ |transaction| transaction.user.username }
    column("Seller ID"){ |transaction| transaction.deal.user.id }
    column("Seller Username"){ |transaction| transaction.deal.user.username }
    column("Deal ID") {|transaction| transaction.deal.id.try(:to_s)}
    column(:created_at)
  end
    
 
  index do
    column("ID"){|transaction| transaction.id.try(:to_s)}
    column("Buyer", :sortable => :user) do |transaction|  
      link_to(transaction.user.name, [ :admin, transaction.user ]) if transaction.user
    end
    
    column("Seller", :sortable => :deal) do |transaction|  
      link_to(transaction.deal.user.name, [ :admin, transaction.deal.user ]) if transaction.deal.user
    end
    
    column("Deal", :sortable => :deal) do |transaction|  
      link_to(transaction.deal.name, [ :admin, transaction.deal ]) if transaction.deal
    end

    column("Paypal Transaction ID"){ |transaction| transaction.paypal_transaction_id }
    column(:created_at)
    default_actions
  end
end
