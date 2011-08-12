require 'test_helper'

class DealTest < ActiveSupport::TestCase
  
  test "valid deal" do
    Qwiqq::Indextank::Document.any_instance.expects(:add).once.returns(true)
    
    assert_nothing_raised(){
      @deal = Factory(:deal, :name => 'deal name here')         
    }
    assert_equal true, @deal.valid?
  end
  
  test "invalid deal" do
    Qwiqq::Indextank::Document.any_instance.expects(:add).never
    
    invalid_name = (0..80).map{"a"}.join
    assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:deal, :name => invalid_name)
    }
  end

  test "validates percent is a percentage" do
    Qwiqq::Indextank::Document.any_instance.expects(:add).never

    assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:deal, :percent => 101)
    }
  end

  test "validates price" do
    Qwiqq::Indextank::Document.any_instance.expects(:add).never
    
    assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:deal, :price => "", :percent => nil)
    }
  end
  
  
  test "unique token added to new deal" do
    Qwiqq::Indextank::Document.any_instance.expects(:add).once.returns(true)
    
    assert_nothing_raised(){
      @deal = Factory(:deal, :name => 'deal name here')         
    }
    assert_not_nil @deal.unique_token
  end
  
  test "validate unique token" do
    Qwiqq::Indextank::Document.any_instance.expects(:add).once.returns(true)

    @user = Factory(:user)
    @category = Factory(:category)
    params = {:name => 'test', :price => 5, :category_id => @category.id, :user_id => @user.id, :percent => nil}
    
    @deal0 = Factory(:deal, params)       
    assert_raise(ActiveRecord::RecordInvalid) {
      @deal1 = Factory(:deal, params)
    }
  end
end