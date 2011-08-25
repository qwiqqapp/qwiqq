require 'test_helper'

class DealTest < ActiveSupport::TestCase
  
  self.use_transactional_fixtures = false
  
  setup do
    Resque.reset!
  end
  
  # ----------------
  # async indextank
  
  # test queue is populated
  test "should queue indextank add" do    
    @deal = Factory(:deal)
    assert_queued(IndextankAddJob, [@deal.id])
  end
  
  test "should queue indextank remove" do    
    @deal = Factory(:deal)
    @deal.destroy
    assert_queued(IndextankRemoveJob, [@deal.id])
  end
  
  test "should NOT queue on update" do
    @deal = Factory(:deal)
    assert_equal 1, Resque.queue(:indextank).length
    
    @deal.name = 'new deal name'
    @deal.save
    assert_equal 1, Resque.queue(:indextank).length
  end
  
  # TODO update tests to check for actual instance of deal being indexed
  test "should add deal to indextank" do
    Qwiqq::Indextank::Document.any_instance.expects(:add).once
    @deal   = Factory(:deal)
    Resque.run!
  end
  
  
  
  # TODO update tests to check for actual instance of deal being indexed
  test "should remove deal from indextank" do
    Deal.any_instance.stubs(:async_indextank_add).returns(:true)
    @deal = Factory(:deal, :indexed_at => Time.now)

    Qwiqq::Indextank::Document.expects(:remove_doc).with(@deal.id).once
    @deal.destroy    
    Resque.run!
  end  
  
  test "should update indexed_at for deal on success" do
    Qwiqq::Indextank::Document.any_instance.stubs(:add).returns(true)
    @deal = Factory(:deal)
    Resque.run!
    
    @deal.reload
    assert_not_nil @deal.indexed_at
  end
  
  test "should NOT add indextank deal twice" do
    @deal   = Factory(:deal)

    # another worker addes deal
    @deal.update_attribute(:indexed_at, Time.now)
    
    Qwiqq::Indextank::Document.any_instance.expects(:add).never
    Resque.run!
  end
  
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