ActiveAdmin.register Transaction do
 
  controller do
    def scoped_collection
      Transaction.includes(:deal)
    end
  end
 
  
  
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
    column("Buyer Email"){ |transaction| transaction.email }
    column("Seller ID"){ |transaction| transaction.deal.user.id }
    column("Seller Username"){ |transaction| transaction.deal.user.username }
    column("Deal ID") {|transaction| transaction.deal.id.try(:to_s)}
    column("Amount") {|transaction| transaction.deal.price}
    column(:created_at)
  end
  
  index do
    column("ID"){|transaction| transaction.id.try(:to_s)}
    column("Buyer", :sortable => :user) do |transaction|  
      link_to(transaction.user.name, [ :admin, transaction.user ]) if transaction.user
    end
    
    column("Buyer Email", :sortable => :email) {|transaction| transaction.email}
    
    column("Seller", :sortable => false) do |transaction|  
      link_to(transaction.deal.user.username, [ :admin, transaction.deal.user ]) if transaction.deal.user
    end
    
    column("Deal", :sortable => "deals.name") do |transaction|  
      link_to(transaction.deal.name, [ :admin, transaction.deal ]) if transaction.deal
    end

    column("Paypal Transaction ID"){ |transaction| transaction.paypal_transaction_id }
    
    column("Amount", :sortable => "deals.price") {|transaction| transaction.deal.price_as_string}
    
    column(:created_at)
    #default_actions
  end
end
