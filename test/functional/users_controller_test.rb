require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class UsersControllerTest < ActionController::TestCase
	
	{
		'off' => Proc.new { Sugar.config(:public_browsing, false) },
		'on'  => Proc.new { Sugar.config(:public_browsing, true) },
	}.each do |state, proc|

		context "With an existing invite and public browsing #{state}" do
			setup do
				proc.call
				@invite = Factory(:invite)
			end

			context 'signing up normally with the invite' do
				setup do
					attributes = FactoryGirl.attributes_for(:user)
					params = {
						:username         => attributes[:username],
						:email            => attributes[:email],
						:password         => 'randompassword',
						:confirm_password => 'randompassword',
						:realname         => attributes[:realname]
					}
					post :create, :token => @invite.token, :user => params
				end
				should assign_to(:invite)
				should assign_to(:user)
				should respond_with(:redirect)
				should 'redirect to the users page' do
					assert_redirected_to(user_url(:id => assigns(:user).username))
				end
			end
		end

	end
end
