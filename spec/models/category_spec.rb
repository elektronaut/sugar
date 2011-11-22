require 'spec_helper'

describe Category do
	it { should have_many(:discussions) }
	it { should validate_presence_of(:name) }
	before { @category = create(:category, :name => 'This is my Category') }
	
	it 'creates a URL slug' do
		Category.work_safe_urls = false
		@category.to_param.should =~ /^[\d]+;This\-is\-my\-Category$/
		Category.work_safe_urls = true
		@category.to_param.should =~ /^[\d]+$/
	end
	
	describe '#find_viewable_by' do
		before do
			@normal_category  = create(:category)
			@trusted_category = create(:trusted_category)
		end

		it 'only finds non-trusted categories for normal users' do
			user = create(:user)
			Category.find_viewable_by(user).should include(@normal_category)
			Category.find_viewable_by(user).should_not include(@trusted_category)
		end

		it 'finds all categories for trusted users' do
			user  = create(:user, :trusted => true)
			Category.find_viewable_by(user).should include(@normal_category)
			Category.find_viewable_by(user).should include(@trusted_category)
		end
	end
	
	context 'with normal attributes' do
		it 'has no labels' do
			@category.labels?.should be_false
			@category.labels.should == []
		end
	end
	
	context 'with the trusted flag set' do
		before { @category = create(:trusted_category) }
		
		it 'is trusted' do
			@category.trusted?.should be_true
		end
		
		it 'has the trusted label' do
			@category.labels?.should be_true
			@category.labels.should include('Trusted')
		end
		
		it 'is not viewable by regular users' do
			@category.viewable_by?(create(:user)).should be_false
		end
		
		it 'is viewable by trusted users and administrators' do
			@category.viewable_by?(create(:user, :trusted => true)).should be_true
			@category.viewable_by?(create(:user, :admin => true)).should be_true
			@category.viewable_by?(create(:user, :moderator => true)).should be_true
			@category.viewable_by?(create(:user, :user_admin => true)).should be_true
		end

		context 'with discussions' do
			before do
				@user        = create(:user)
				@discussions = (0...10).map{ create(:discussion, :category => @category, :poster => @user) }
			end

			it 'returns a proper count for the discussions' do
				@category.discussions.count.should == 10
			end
			
			it 'creates trusted discussions' do
				Discussion.where(:trusted => true).count.should == 10
				Discussion.where(:trusted => false).count.should == 0
			end
			
			it 'changes the trusted flag on discussions as well when changed' do
				@category.update_attribute(:trusted, false)
				Discussion.where(:trusted => true).count.should == 0
				Discussion.where(:trusted => false).count.should == 10
				@category.update_attribute(:trusted, true)
				Discussion.where(:trusted => true).count.should == 10
				Discussion.where(:trusted => false).count.should == 0
			end
			
		end
	end
	
	context 'several categories' do
		before { 5.times { create(:category) } }
		
		it 'acts as a list' do
			categories = Category.order(:position).all
			categories.length.should be > 5
			categories.map(&:position).should == (1..categories.length).to_a
		end
	end
	
end