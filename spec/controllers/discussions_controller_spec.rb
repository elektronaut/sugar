require 'spec_helper'

describe DiscussionsController do

	describe 'with public browsing off' do
		before { Sugar.config(:public_browsing, false) }

		it_requires_login_for :index, :search, :new, :create
		it_requires_login_for :favorites, :following
		it_requires_login_for :show, :edit, :update
		it_requires_login_for :follow, :unfollow, :favorite, :unfavorite
	end

	describe 'with public browsing on' do
		before { Sugar.config(:public_browsing, true) }

		it_requires_login_for :new, :create, :favorites, :following
		it_requires_login_for :edit, :update, :follow, :unfollow, :favorite, :unfavorite

		it 'is open for browsing discussions and posts' do
			discussion = create(:discussion)
			[:index, :show].each do |action|
				get action, :id => discussion
				should respond_with(:success)
			end
		end
	end

	describe 'GET index' do
		before do 
			@discussion = create(:discussion)
			get :index
		end

		it { should assign_to(:discussions).with_kind_of(Enumerable) }
		it { should respond_with(:success) }
		it { should render_template(:index) }
		it { should_not set_the_flash }

		it 'finds a discussion' do
			assigns(:discussions).should include(@discussion)
		end
	end

	describe 'GET show' do
		before do
			@discussion = create(:discussion)
			get :show, :id => @discussion
		end

		it { should assign_to(:discussion).with_kind_of(Discussion) }
		it { should respond_with(:success) }
		it { should render_template(:show) }
		it { should_not set_the_flash }
	end

end

