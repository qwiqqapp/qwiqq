class CreateCouponJob
  @queue = :coupons
  
  def self.perform(id)
    deal = Deal.find(id) rescue nil
    deal.create_coupon if deal.present?
  end
end
