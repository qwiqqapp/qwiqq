require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  # ---------------
  #  push device tests
  
  test "should create push_device when push_token provided" do
    push_token = "AAAAAAAADB6FAD5F4E924598541073516F0C032F3C0179181C9CD79EA2EC144G"
    @user = Factory.build(:user)    
    @user.push_token = push_token

    Urbanairship.expects(:register_device).once.returns(true)
    @user.save
    
    assert_equal 1, @user.push_devices.size
    assert_equal push_token, @user.push_devices.first.token
  end
  
  test "should create 2nd push_device for user if new push_token provided" do
    new_push_token    = "AAAAAAAADB6FAD5F4E924598541073516F0C032F3C0179181C9CD79EA2EC144G"
    @user             = Factory(:user)
    @push_device      = Factory(:push_device, :user => @user)
    @user.push_token  = new_push_token
  
    Urbanairship.expects(:register_device).once.returns(true)
    @user.save
  
    assert_equal 2,               @user.push_devices.size
    assert_equal new_push_token,  @user.push_devices.last.token
  end

  test "should register existing push device on update" do
    @user             = Factory(:user)
    @push_device      = Factory(:push_device, :user => @user)
    @user.push_token  = @push_device.token
  
    Urbanairship.expects(:register_device).once.returns(true)
    @user.save
  
    assert_equal 1, @user.push_devices.size
  end
  
  test "should raise exception if username taken (ignore case)" do
    Factory(:user, :username => 'Adam')
    exception = assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:user, :username => 'adam')
    }
    assert_match(/username/i, exception.message)
  end
  
  test "should raise expection if usename is not alphanumeric" do
    exception = assert_raise(ActiveRecord::RecordInvalid) {
      Factory(:user, :username => 'a b c')
    }
    assert_match(/username/i, exception.message)
  end
  
  test "#authenticate" do
    @password   = 'tester'
    @user       = Factory(:user, :password => @password, :password_confirmation => @password)
    @auth_user  = User.authenticate(@user.email, @password)
    
    assert_equal @user, @auth_user
  end
  
  test "#following" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    
    @user0.follow!(@user1)

    assert_equal 1, @user0.following.count
    assert_equal 0, @user0.followers.count
    assert_equal 0, @user1.following.count
    assert_equal 1, @user1.followers.count
  end

  test "#following?" do
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    
    @user0.follow!(@user1)

    assert @user0.following?(@user1)
  end

  test "#feed_deals" do
    @category = Factory(:category)
    
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    @user2 = Factory(:user)
    @user3 = Factory(:user)

    @user0.follow!(@user1)
    @user0.follow!(@user2)

    @deal0 = Factory(:deal, :user => @user1, :category => @category, :created_at => 1.hour.ago)
    @deal1 = Factory(:deal, :user => @user2, :category => @category, :created_at => 2.hours.ago)
    @deal2 = Factory(:deal, :user => @user0, :category => @category, :created_at => 3.hours.ago)
    @deal3 = Factory(:deal, :user => @user3, :category => @category, :created_at => 4.hours.ago)

    assert_equal 3, @user0.feed_deals.count
    assert_equal [@deal0, @deal1, @deal2], @user0.feed_deals.sorted
  end
  
  
  test "#follow! & #unfollow!" do
    @category = Factory(:category)
    
    @user0 = Factory(:user)
    @user1 = Factory(:user)
    @user2 = Factory(:user)
    @user3 = Factory(:user)

    @user0.follow!(@user1)
    @user0.follow!(@user2)

    @deal0 = Factory(:deal, :user => @user1, :category => @category, :created_at => 1.hour.ago)
    @deal1 = Factory(:deal, :user => @user2, :category => @category, :created_at => 2.hours.ago)
    @deal2 = Factory(:deal, :user => @user0, :category => @category, :created_at => 3.hours.ago)
    @deal3 = Factory(:deal, :user => @user3, :category => @category, :created_at => 4.hours.ago)
    
    assert_equal 3, @user0.feed_deals.count
    
    @user0.unfollow!(@user1)
    assert_equal 2, @user0.feed_deals.count
    assert_equal [@deal1, @deal2], @user0.feed_deals.sorted
    
    @user0.unfollow!(@user2)
    assert_equal 1, @user0.feed_deals.count
    assert_equal [@deal2], @user0.feed_deals.sorted
  end
  

  
  test "should strip text attributes before saving" do
    @user = Factory(:user,
      :email => "    eoin@gastownlabs.com     ",
      :city => "     Vancouver    ",
      :country => "     Canada    ",
      :first_name => " Eoin    ",
      :last_name => "    Hennessy   ",
      :username => "     eoin    ",
      :bio => "          ")

    assert_equal "eoin@gastownlabs.com", @user.email
    assert_equal "Vancouver", @user.city
    assert_equal "Canada", @user.country
    assert_equal "Eoin", @user.first_name
    assert_equal "Hennessy", @user.last_name
    assert_equal "eoin", @user.username
    assert_equal "", @user.bio
  end
  
  test "should update #twitter_id when #twitter_access_token changes" do
    @user = Factory(:user)

    twitter_user = mock(:id => 1)
    twitter_client = mock(:user => twitter_user)
    @user.stubs(:twitter_client).returns(twitter_client)
    
    @user.update_attributes(
      :twitter_access_token => "token",
      :twitter_access_secret => "secret")
      
    assert_equal "1", @user.twitter_id
  end
  
  test "should update #facebook_id when #facebook_access_token changes" do
    @user = Factory(:user)
    
    facebook_client = mock()
    facebook_client.expects(:me).returns({ "id" => "1"})
    
    @user.stubs(:facebook_client).returns(facebook_client)
    @user.update_attributes(:facebook_access_token => "token")
    
    assert_equal "1", @user.facebook_id
  end

  test "should update #foursquare_id when #foursquare_access_token changes" do
    @user = Factory(:user)
    
    foursquare_response = { "id" => "1" }
    foursquare_client = mock()
    foursquare_client.expects(:user).with("self").returns(foursquare_response)
    @user.stubs(:foursquare_client).returns(foursquare_client)
    @user.update_attributes(:foursquare_access_token => "token")
    
    assert_equal "1", @user.foursquare_id
  end
  
  test "should update user even if FB token is changed and invalid" do    
    @user = Factory(:user, :first_name => 'jack', :last_name => 'w')

    facebook_client = mock
    facebook_client.expects(:me).raises(Facebook::InvalidAccessTokenError)
    @user.stubs(:facebook_client).returns(facebook_client)    
    
    assert_nothing_raised do
      @user.update_attributes(:first_name => 'john', :last_name => 'phan', :facebook_access_token => 'invalid')
    end
    
    @user.reload
    assert_equal 'john', @user.first_name
    assert_equal 'phan', @user.last_name
  end
  
  test "should fetch the users image from facebook when #photo_service == 'facebook'" do
    @user = Factory(:user)
    @user.expects(:update_photo_from_facebook)
    @user.update_attributes(:photo_service => "facebook")
  end
  
  test "should raise if FB token is invalid when #photo_service == 'facebook'" do
    @user = Factory(:user)
    
    facebook_client = mock
    facebook_client.expects(:photo).raises(Facebook::InvalidAccessTokenError)
    @user.stubs(:facebook_client).returns(facebook_client)
    
    assert_raises Facebook::InvalidAccessTokenError do 
      @user.update_attributes(:photo_service => "facebook")
    end
  end
  
  test "should fetch the users image from twitter when #photo_service == 'twitter'" do
    @user = Factory(:user)
    @user.expects(:update_photo_from_twitter)
    @user.update_attributes(:photo_service => "twitter")
  end
  
  # TODO check order
  test "#facebook_friends" do
    @user1 = Factory(:user, :facebook_id => "1", :first_name => "a", :last_name => "a", :username => 'a')
    @user2 = Factory(:user, :facebook_id => "2", :first_name => "b", :last_name => "b", :username => 'b')
    @user3 = Factory(:user, :facebook_id => "3", :first_name => "c", :last_name => "c", :username => 'c')
    @user  = Factory(:user)

    client = mock
    client.expects(:friends).returns([{'id' => 3}, {'id' => 1}, {'id' => 4}])
    @user.expects(:facebook_client).returns(client)
    
    assert_equal ['a', 'c'], @user.facebook_friends.map(&:first_name)
  end
  
end

