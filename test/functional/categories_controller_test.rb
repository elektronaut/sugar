require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class CategoriesControllerTest < ActionController::TestCase

	context "When logged in" do 
		setup { login_session(User.make(:trusted)) }

		context "a GET on :index" do
			setup { get :index }
			
			should "render successfully" do
				assert_response :success
				assert_template 'categories/index'
			end
			
			should "retrieve a list of categories" do
				assert_not_nil assigns(:categories)
				assert assigns(:categories).kind_of?(Enumerable)
			end
			
			context "with categories created" do
				setup do 
					5.times {Category.make}
					2.times {Category.make(:trusted)}
					get :index
				end
				
				should "load them" do
					assert assigns(:categories).length > 0
				end
				
				should "output labels on trusted categories" do
					assert_select 'div.category' do
						assert_select 'h3.name' do
							assert_select 'span.labels', '[Trusted]'
						end
					end
				end
			end
		end
	end
end
