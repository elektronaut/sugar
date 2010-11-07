require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class CategoriesControllerTest < ActionController::TestCase

	context "When logged in as a trusted user" do 
		setup do 
			populate_application
			login_session(Factory(:user, :trusted => true)) 
		end

		context "a GET on :index" do
			setup { get :index }
			
			should assign_to(:categories)
			should respond_with(:success)
			should render_template(:index)
			should_not set_the_flash
	
			should "retrieve a list of categories" do
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
		
		context 'a GET on :show' do
			setup { get :show, :id => Category.first }
			
			should assign_to(:discussions)
			should respond_with(:success)
			should render_template(:show)
			should_not set_the_flash

			should "retrieve a list of discussions" do
				assert assigns(:discussions).length > 0
			end
		end

		context 'a GET on :new' do
			setup { get :new }
			should set_the_flash
			should respond_with(:redirect)
		end
	end
	
	context "When logged in as a moderator" do 
		setup do 
			populate_application
			login_session(Factory(:user, :moderator => true)) 
		end

		context 'a GET on :new' do
			setup { get :new }

			should assign_to(:category)
			should respond_with(:success)
			should render_template(:new)
			should_not set_the_flash
			
			should "instance a new category" do
				assert_kind_of Category, assigns(:category)
			end
		end

		context 'creating a valid discussion' do
			setup do
				post :create, :category => {
					:name        => 'A new category',
					:description => 'Here we can discuss stuff'
				}
			end
			should assign_to(:category)
			should respond_with(:redirect)
			should set_the_flash.to(/was created/)

			should 'create it' do
				assert_redirected_to categories_path
			end
		end

		context 'creating an invalid discussion' do
			setup do
				post :create, :category => {
					:name        => '',
					:description => ''
				}
			end
			should assign_to(:category)
			should respond_with(:success)
			should render_template(:new)
			should set_the_flash.to(/required fields/)

			should 'instance an invalid category' do
				assert !assigns(:category).valid?
			end
		end

		context 'a GET on :edit' do
			setup { get :edit, :id => Category.first }
			
			should assign_to(:category)
			should respond_with(:success)
			should render_template(:edit)

			should "load the category" do
				assert_kind_of Category, assigns(:category)
			end
		end
		
		context 'updating a category with valid data' do
			setup do
				@category = Factory(:category, :name => 'Original name')
				put :update, :id => @category, :category => {:name => 'New name'}
			end
			should assign_to(:category)
			should respond_with(:redirect)
			should set_the_flash.to(/was saved/)

			should 'change the name' do
				assert_equal 'New name', assigns(:category).name
			end
			
			should 'redirect to categories' do
				assert_redirected_to categories_path
			end
		end

		context 'updating a category with invalid data' do
			setup do
				@category = Factory(:category, :name => 'Original name')
				put :update, :id => @category, :category => {:name => ''}
			end
			should assign_to(:category)
			should respond_with(:success)
			should render_template(:edit)
			should set_the_flash.to(/required fields/)
		end
	end
	
end
