require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class UserTest < ActiveSupport::TestCase
	context "A regular user" do
		setup { @user = Factory(:user) }

		should "not be trusted or an admin" do
			assert !@user.admin?
			assert !@user.moderator?
			assert !@user.user_admin?
			assert !@user.trusted?
		end
	end
end
