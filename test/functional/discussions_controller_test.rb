require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class DiscussionsControllerTest < ActionController::TestCase

	context "When not logged in" do

		context "and public browsing is off" do
			setup do
				Sugar.config(:public_browsing, false)
				@discussion = Factory(:discussion)
			end
			should "any action redirect to the login page" do
				[:index, :search, :new, :create, :favorites, :following].each do |a|
					get a
					assert_response :redirect
					assert_redirected_to login_users_path
				end
				[:show, :edit, :update, :follow, :unfollow, :favorite, :unfavorite].each do |a|
					get a, :id => @discussion
					assert_response :redirect
					assert_redirected_to login_users_path
				end
			end
		end

		context "and public browsing is on" do
			setup do
				Sugar.config(:public_browsing, true)
				@discussion = Factory(:discussion)
			end
			should "browsing work" do
				[:index].each do |a|
					get a
					assert_response :success
				end
				[:show].each do |a|
					get a, :id => @discussion
					assert_response :success
				end
			end
			should "some things require login" do
				[:new, :create, :favorites, :following].each do |a|
					get a
					assert_response :redirect
					assert_redirected_to login_users_path
				end
				[:edit, :update, :follow, :unfollow, :favorite, :unfavorite].each do |a|
					get a, :id => @discussion
					assert_response :redirect
					assert_redirected_to login_users_path
				end
			end
		end
	end

	context "When logged in" do 
		setup do
			login_session
		end
		should "a GET on index retrieve a list of discussions" do
			get :index
			assert_response :success
			assert assigns(:discussions).kind_of?(Enumerable)
		end
	end
end
