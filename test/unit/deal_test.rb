require 'test_helper'

class DealTest < ActiveSupport::TestCase
  
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
  

end