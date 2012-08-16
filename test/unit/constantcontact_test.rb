require 'test_helper'

class ConstantcontactTest < ActiveSupport::TestCase
  
  test "should deliver an constantcontact email" do
    @email  = 'michael@test.com'
    @user = Factory(:user)
    @constant_contact = Constantcontact.new(:user => @user, :service => 'email', :email => @email)
    
    Mailer.expects(:constant_contact).once.with(@email, @user).returns(mock(:deliver => true))
    @constant_contact.save
  end
  
end
