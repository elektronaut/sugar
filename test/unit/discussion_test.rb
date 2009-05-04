require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase

	should_belong_to :category
	should_belong_to :poster
	should_belong_to :last_poster

	should_have_many :posts
	should_have_many :discussion_views
	should_have_many :discussion_relationships

	should_validate_presence_of :category_id
	should_validate_presence_of :body

	context "A discussion" do
		setup { @discussion = Discussion.make(:title => 'This is my Discussion', :body => 'It has content') }

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
			assert @discussion.editable_by?(User.make(:admin))
			assert @discussion.editable_by?(User.make(:moderator))
			assert !@discussion.editable_by?(User.make)
			assert !@discussion.editable_by?(User.make(:user_admin))
		end

		should "be postable by anyone if open" do
			assert @discussion.postable_by?(@discussion.poster)
			assert @discussion.postable_by?(User.make)
		end

		should "only be postable by admins if closed" do
			@discussion.update_attribute(:closed, true)
			assert @discussion.closed?
			assert !@discussion.postable_by?(@discussion.poster)
			assert !@discussion.postable_by?(User.make)
			assert @discussion.postable_by?(User.make(:admin))
			assert @discussion.postable_by?(User.make(:moderator))
		end

		# Discussion with posts
		context "with posts" do
			setup do
				@user = User.make
				54.times { @discussion.posts.make(:user => @user) }
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
			@category = Category.make(:trusted)
			@discussion = @category.discussions.make(:title => 'This is my Discussion')
		end

		should "be trusted" do
			assert @discussion.trusted?
		end

		should "have the trusted label" do
			assert @discussion.labels?
			assert_same_elements ['Trusted'], @discussion.labels
		end

		should "not be viewable by a regular user" do
			assert !@discussion.viewable_by?(User.make)
		end

		should "should be viewable by a trusted user or admin" do
			assert @discussion.viewable_by?(User.make(:trusted))
			assert @discussion.viewable_by?(User.make(:admin))
		end
	end
	
	context "A mixed sets of discussions" do
		setup do
			@user = User.make
			@regular_category = Category.make
			@trusted_category = Category.make(:trusted)
			35.times { @regular_category.discussions.make(:poster => @user) }
			35.times { @trusted_category.discussions.make(:poster => @user) }
		end

		should "be created" do
			assert_equal 35, Discussion.count(:all, :conditions => {:trusted => false})
			assert_equal 70, Discussion.count(:all)
		end

		should "paginate" do
			discussions = Discussion.find_paginated
			assert_equal Discussion::DISCUSSIONS_PER_PAGE, discussions.length
			assert discussions.kind_of?(Pagination::InstanceMethods)
			assert_equal 35, discussions.total_count
			assert_equal 2, discussions.pages

			discussions = Discussion.find_paginated(:trusted => true)
			assert_equal 70, discussions.total_count
			assert_equal 3, discussions.pages

			discussions = Discussion.find_paginated(:trusted => true, :category => @trusted_category)
			assert_equal 35, discussions.total_count
			assert_equal 2, discussions.pages
			assert_same_elements [@trusted_category.id], discussions.map{|d| d.category_id}.uniq
		end
	end

end
