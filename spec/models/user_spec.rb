require 'spec_helper'

describe User do
	context 'with no special privileges' do
		before do
			@user = create(:user)
		end

		it "shouldn't be marked as admin" do
			@user.admin?.should be_false
			@user.moderator?.should be_false
			@user.user_admin?.should be_false
			@user.trusted?.should be_false
		end
	end
end