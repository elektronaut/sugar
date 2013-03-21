require 'spec_helper'

describe UsersController do

  # Create the first admin user
  before { create(:user) }

  describe '#index' do
    before do
      login
      @user = create(:user)
      get :index
    end

    it { should assign_to(:users) }
    it { should_not set_the_flash }
    it { should render_template(:index) }
  end

  describe '#index.json' do
    before do
      login
      @user = create(:user)
      get :index, :format => :json
      @json = JSON.parse(response.body)
    end

    it { should assign_to(:users) }
    it { should_not set_the_flash }

    it "renders JSON" do
      @json.should be_kind_of(Array)
    end
  end

  describe '#banned' do
    before do
      login
      @user = create(:user, :banned => true)
      get :banned
    end

    it { should assign_to(:users) }
    it { should_not set_the_flash }
    it { should render_template(:banned) }
  end

  describe '#banned.json' do
    before do
      login
      @user = create(:user, :banned => true)
      get :banned, :format => :json
      @json = JSON.parse(response.body)
    end

    it "renders JSON" do
      @json.should be_kind_of(Array)
    end
  end

  describe 'POST create' do
    before do
      attributes = attributes_for(:user)
      @params = {
        :username         => attributes[:username],
        :email            => attributes[:email],
        :password         => 'randompassword',
        :confirm_password => 'randompassword',
        :realname         => attributes[:realname]
      }
    end

    describe 'with a valid invite token' do
      before do
        @invite = create(:invite)
        post :create, :token => @invite.token, :user => @params
      end

      it { should assign_to(:invite) }
      it { should assign_to(:user) }

      it "redirects to the user profile" do
        response.should redirect_to(user_url(:id => assigns(:user).username))
      end
    end
  end
end
