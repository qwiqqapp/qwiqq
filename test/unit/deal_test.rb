require 'test_helper'

class DealTest < ActiveSupport::TestCase
  
  # --------------
  #  validation
  
  test "valid deal" do
    assert_nothing_raised(){
      @deal = Factory(:deal, :name => 'deal name here')
    }
    assert_equal true, @deal.valid?
  end
  
  test "invalid deal" do
    invalid_name = (0..80).map{"a"}.join
    assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:deal, :name => invalid_name)
    }
  end

  test "validates percent is a percentage" do
    assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:deal, :percent => 101)
    }
  end

  test "validates price" do
    assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:deal, :price => "", :percent => nil)
    }
  end
  
  
  test "unique token added to new deal" do
    assert_nothing_raised(){
      @deal = Factory(:deal, :name => 'deal name here')
    }
    assert_not_nil @deal.unique_token
  end
  
  test "validate unique token" do
    @user = Factory(:user)
    @category = Factory(:category)
    params = {:name => 'test', :price => 5, :category_id => @category.id, :user_id => @user.id, :percent => nil}
    
    @deal0 = Factory(:deal, params)       
    assert_raise(ActiveRecord::RecordInvalid) {
      @deal1 = Factory(:deal, params)
    }
  end
end