require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class CategoryTest < ActiveSupport::TestCase

	should have_many(:discussions)
	should validate_presence_of(:name)
	
	context "A category" do
		setup { @category = Factory(:category, :name => 'This is my Category') }

		should "slug urls" do
			Category.work_safe_urls = false
			assert @category.to_param =~ /^[\d]+;This\-is\-my\-Category$/
			Category.work_safe_urls = true
			assert @category.to_param =~ /^[\d]+$/
		end

		should "not have any labels" do
			assert !@category.labels?
			assert_same_elements [], @category.labels
		end
	end
	
	context "A trusted category" do

		setup { @category = Factory(:trusted_category) }

		should "be trusted" do
			assert @category.trusted?
		end

		should "not show up on trusted = 0" do
			assert_equal 1, Category.count(:all)
			assert_equal 0, Category.count(:all, :conditions => ['trusted = 0'])
		end

		should "not be viewable by a regular user" do
			assert !@category.viewable_by?(Factory(:user))
		end

		should "should be viewable by a trusted user" do
			assert @category.viewable_by?(Factory(:user, :trusted => true))
		end

		should "should be viewable by an admin" do
			assert @category.viewable_by?(Factory(:user, :admin => true))
		end
		
		should "not have the trusted label" do
			assert @category.labels?
			assert_same_elements ["Trusted"], @category.labels
		end

		# Category with discussions
		context "with 10 discussions" do
			setup do
				@category    = Factory(:trusted_category)
				@user        = Factory(:user)
				@discussions = (0...10).map{ Factory(:discussion, :category => @category, :poster => @user) }
			end
			
			should 'have discussions made' do
				assert_equal 10, @discussions.length
			end
			
			should "have all belonging to category" do
				assert_equal 10, @discussions.select{|d| d.category == @category}.length
			end

			should "report proper count" do
				assert_equal 10, @category.discussions.count
			end

			should "have only trusted discussions" do
				assert_equal 0,  Discussion.count(:all, :conditions => ['trusted = 0'])
				assert_equal 10, Discussion.count(:all, :conditions => ['trusted = 1'])
			end

			should "update trusted flag on discussions" do
				@category.update_attribute(:trusted, false)
				assert !@category.trusted?
				assert_equal 10, Discussion.count(:all, :conditions => ['trusted = 0'])
				assert_equal 0,  Discussion.count(:all, :conditions => ['trusted = 1'])
				@category.update_attribute(:trusted, true)
				assert @category.trusted?
				assert_equal 0,  Discussion.count(:all, :conditions => ['trusted = 0'])
				assert_equal 10, Discussion.count(:all, :conditions => ['trusted = 1'])
			end
		end
	end

	context "A series of categories" do
		setup { 5.times { Factory(:category) } }

		should "be created" do
			assert_equal 5, Category.count(:all)
		end

		should "act as a list" do
			categories = Category.find(:all, :order => 'position ASC')
			assert_equal 1, categories[0].position
			assert_equal 5, categories[4].position
			categories.each do |c|
				assert_equal categories.index(c) + 1, c.position
			end
		end
	end
	
end
