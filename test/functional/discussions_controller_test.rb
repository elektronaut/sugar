require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase

	context "When not logged in" do
		context "and public browsing is off" do
			setup do
				Sugar.config(:public_browsing, false)
			end
			should "any action redirect to the login page" do
				[:index, :search, :new, :show, :edit, :update, :create, :favorites, :following, :follow, :unfollow, :favorite, :unfavorite].each do |a|
					get a
					assert_response :redirect
					assert_redirected_to login_users_path
				end
			end
		end
	end

	context "When logged in" do 
		setup do
			@current_user = User.make
			session[:user_id] = @current_user.id
			session[:hashed_password] = @current_user.hashed_password
			session[:ips] = ['0.0.0.0']
		end
		should "a GET on index retrieve a list of discussions" do
			get :index
			assert_response :success
			assert assigns(:discussions).kind_of?(Enumerable)
		end
	end
end
