require 'test_helper'

class DealTest < ActiveSupport::TestCase
  
  test "valid deal" do
    assert_nothing_raised(){
      @deal = Factory(:deal, :name => 'deal name here')         
    }
    assert_equal true, @deal.valid?
  end
  
  test "invalid deal" do
    invalid_name = (0..80).map{ "a"}.join  
    assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:deal, :name => invalid_name)    
    }
  end
end