require 'test_helper'

class InvitationTest < ActiveSupport::TestCase
  
  test "should deliver an email invitation" do
    @email  = 'adam@test.com'
    @user = Factory(:user)
    @invitation = Invitation.new(:user => @user, :service => 'email', :email => @email)
    
    Mailer.expects(:invitation).once.with(@email, @user).returns(mock(:deliver => true))
    @invitation.save
  end
  
end
