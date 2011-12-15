require 'spec_helper'

describe Discussion do
	it { should belong_to :closer }
	it { should belong_to :category }
	it { should have_many :discussion_relationships }

	it { should validate_presence_of(:category_id) }

	before { @discussion = create(:discussion) }
	
	it 'inherits from Exchange' do
		@discussion.should be_kind_of(Exchange)
	end

	it "can't be reopened if closed by someone else" do
		@discussion.update_attributes(:closed => true, :updated_by => create(:moderator))

		@discussion.update_attributes(:closed => false, :updated_by => @discussion.poster)
		@discussion.should have(1).errors_on(:closed)
	end
	
	it 'is only editable by the poster, moderators and admins' do
		@discussion.editable_by?(@discussion.poster).should be_true
		@discussion.editable_by?(create(:admin)).should be_true
		@discussion.editable_by?(create(:moderator)).should be_true
		@discussion.editable_by?(create(:user_admin)).should be_false
		@discussion.editable_by?(create(:user)).should be_false
	end
	
	it 'is postable by everyone' do
		@discussion.postable_by?(create(:user)).should be_true
	end
	
	context 'when closed' do
		before do
			@moderator = create(:moderator)
			@discussion.update_attributes(:closed => true, :updated_by => @moderator)
		end

		it "updates closer when closed" do
			@discussion.closer.should == @moderator
		end

		it 'is only postable by admins and moderators' do
			@discussion.update_attributes(:closed => true)
			@discussion.postable_by?(create(:user)).should be_false
			@discussion.postable_by?(@discussion.poster).should be_false
			@discussion.postable_by?(create(:user_admin)).should be_false
			@discussion.postable_by?(create(:admin)).should be_true
			@discussion.postable_by?(create(:moderator)).should be_true
		end
	end
	
	context 'with the sticky flag' do
		before { @discussion = create(:discussion, :sticky => true) }

		it 'is sticky' do
			@discussion.sticky?.should be_true
		end
		
		it 'has the sticky label' do
			@discussion.labels.should include('Sticky')
		end
	end
	
	context 'with more than one page of posts' do
		before do
			50.times { create(:post, :discussion => @discussion, :user => @discussion.poster) }
		end
		
		it 'responds to last_page' do
			@discussion.last_page.should == 2
		end

		describe '#paginated_posts' do
			it 'paginates posts' do
				posts = @discussion.paginated_posts(:page => 1)
				posts.length.should == Post::POSTS_PER_PAGE
				posts.should be_kind_of(Pagination::InstanceMethods)
				posts.total_count.should == 51
				posts.pages.should == 2
				posts = @discussion.paginated_posts(:page => 2)
				posts.length.should == 1
			end
		end
		
		describe '#posts_since_index' do
			it 'finds posts with an offset' do
				@discussion.posts_since_index(20).length.should == (@discussion.posts.count - 20)
			end
		end
	end
	
	context 'in a trusted category' do
		before { @discussion = create(:trusted_discussion)}
		
		it 'is trusted' do
			@discussion.trusted?.should be_true
		end
		
		it 'has the trusted label' do
			@discussion.labels?.should be_true
			@discussion.labels.should include('Trusted')
		end
		
		it 'is not viewable by a regular user or user admin' do
			@discussion.viewable_by?(create(:user)).should be_false
		end
		
		it 'is viewable by trusted users and admins' do
			@discussion.viewable_by?(create(:trusted_user)).should be_true
			@discussion.viewable_by?(create(:admin)).should be_true
			@discussion.viewable_by?(create(:moderator)).should be_true
			@discussion.viewable_by?(create(:user_admin)).should be_true
		end
	end
	
	describe '#find_paginated' do
		before do
			create(:discussion, :category => create(:trusted_category))
		end
		
		it 'does not include trusted discussions without :trusted' do
			discussions = Discussion.find_paginated
			discussions.map(&:trusted?).should_not include(true)
		end
		
		it 'includes trusted discussions with :trusted' do
			discussions = Discussion.find_paginated(:trusted => true)
			discussions.map(&:trusted?).should include(true)
		end
	end
	
end