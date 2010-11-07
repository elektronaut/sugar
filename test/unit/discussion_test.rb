require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class DiscussionTest < ActiveSupport::TestCase

	should belong_to(:category)
	should belong_to(:poster)
	should belong_to(:last_poster)

	should have_many(:posts)
	should have_many(:discussion_views)
	should have_many(:discussion_relationships)

	should validate_presence_of(:category_id)
	should validate_presence_of(:body)

	context "A discussion" do
		setup { @discussion = Factory(:discussion, :title => 'This is my Discussion', :body => 'It has content') }

		should "slug urls" do
			Discussion.work_safe_urls = false
			assert @discussion.to_param =~ /^[\d]+;This\-is\-my\-Discussion$/
			Discussion.work_safe_urls = true
			assert @discussion.to_param =~ /^[\d]+$/
		end

		should "have a first post" do
			assert_equal 1, @discussion.posts.count
			assert_equal 'It has content', @discussion.posts.first.body
		end

		should "update the first post when body changes" do
			assert_equal @discussion.posts.first.body, @discussion.body
			assert @discussion.update_attribute(:body, "New body")
			assert_equal "New body", @discussion.posts.first.body
		end

		should "report labels" do
			assert !@discussion.labels?
			assert_equal [], @discussion.labels
			@discussion.update_attributes(:nsfw => true, :closed => true, :sticky => true)
			assert @discussion.labels?
			assert_same_elements ['NSFW', 'Closed', 'Sticky'], @discussion.labels
		end

		should "be editable only by poster or users with privileges" do
			assert @discussion.editable_by?(@discussion.poster)
			assert @discussion.editable_by?(Factory(:user, :admin => true))
			assert @discussion.editable_by?(Factory(:user, :moderator => true))
			assert !@discussion.editable_by?(Factory(:user))
			assert !@discussion.editable_by?(Factory(:user, :user_admin => true))
		end

		should "be postable by anyone if open" do
			assert @discussion.postable_by?(@discussion.poster)
			assert @discussion.postable_by?(Factory(:user))
		end

		should "only be postable by admins if closed" do
			@discussion.update_attribute(:closed, true)
			assert @discussion.closed?
			assert !@discussion.postable_by?(@discussion.poster)
			assert !@discussion.postable_by?(Factory(:user))
			assert @discussion.postable_by?(Factory(:user, :admin => true))
			assert @discussion.postable_by?(Factory(:user, :moderator => true))
		end

		# Discussion with posts
		context "with posts" do
			setup do
				54.times { Factory(:post, :discussion => @discussion) }
			end

			should "have posts" do
				assert_equal 55, @discussion.posts.count
			end

			should "paginate posts" do
				assert_equal 2, @discussion.last_page
				posts = @discussion.paginated_posts(:page => 1)
				assert_equal Post::POSTS_PER_PAGE, posts.length
				assert posts.kind_of?(Pagination::InstanceMethods)
				assert_equal 55, posts.total_count
				assert_equal 2, posts.pages
				posts = @discussion.paginated_posts(:page => 2)
				assert_equal 5, posts.length
			end

			should "load new posts by index" do
				new_posts = @discussion.posts_since_index(20)
				assert_equal 35, new_posts.length
			end
		end
	end
	
	context "A discussion in a trusted category" do
		setup do
			@category   = Factory(:trusted_category)
			@discussion = Factory(:discussion, :category => @category)
		end

		should "be trusted" do
			assert @discussion.trusted?
		end

		should "have the trusted label" do
			assert @discussion.labels?
			assert_same_elements ['Trusted'], @discussion.labels
		end

		should "not be viewable by a regular user" do
			assert !@discussion.viewable_by?(Factory(:user))
		end

		should "should be viewable by a trusted user or admin" do
			assert @discussion.viewable_by?(Factory(:user, :trusted => true))
			assert @discussion.viewable_by?(Factory(:user, :admin => true))
		end
	end
	
	context "A mixed sets of discussions" do
		setup do
			@regular_category = Factory(:category)
			@trusted_category = Factory(:category, :trusted => true)
			35.times { Factory(:discussion, :category => @regular_category) }
			35.times { Factory(:discussion, :category => @trusted_category) }
		end

		should "be created" do
			assert_equal 35, Discussion.count(:all, :conditions => {:trusted => false})
			assert_equal 70, Discussion.count(:all)
		end

		should "paginate" do
			# Find non-trusted discussions and check for pagination
			discussions = Discussion.find_paginated
			assert_equal Discussion::DISCUSSIONS_PER_PAGE, discussions.length
			assert discussions.kind_of?(Pagination::InstanceMethods)
			assert_equal 35, discussions.total_count
			assert_equal 2, discussions.pages

			# Find all discussions
			discussions = Discussion.find_paginated(:trusted => true)
			assert_equal 70, discussions.total_count
			assert_equal 3, discussions.pages

			# Find only trusted discussions
			discussions = Discussion.find_paginated(:trusted => true, :category => @trusted_category)
			assert_equal 35, discussions.total_count
			assert_equal 2, discussions.pages
			assert_same_elements [@trusted_category.id], discussions.map{|d| d.category_id}.uniq
		end
	end

end
