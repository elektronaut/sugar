require 'spec_helper'

describe UsersController do

  let(:user) { create(:user) }

  # Create the first admin user
  before { create(:user) }

  describe '#index' do
    before do
      login
      @user = create(:user)
      get :index
    end

    specify { assigns(:users).should be_a(ActiveRecord::Relation) }
    specify { flash[:notice].should be_nil }
    it { should render_template(:index) }
  end

  describe '#index.json' do
    before do
      login
      @user = create(:user)
      get :index, :format => :json
      @json = JSON.parse(response.body)
    end

    specify { assigns(:users).should be_a(ActiveRecord::Relation) }
    specify { flash[:notice].should be_nil }

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

    specify { assigns(:users).should be_a(ActiveRecord::Relation) }
    specify { flash[:notice].should be_nil }
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

  describe '#update' do
    before { login user }

    context "regular update" do
      before { put :update, id: user.id, user: {realname: "New name"} }

      specify { assigns(:user).should be_a(User) }
      specify { flash[:notice].should match("Your changes were saved!") }
      it { should redirect_to(edit_user_page_url(user.username, page: 'info')) }
      specify { user.reload.realname.should == "New name" }
    end

    context "self banning" do
      before { put :update, id: user.id, user: {banned_until: (Time.now + 2.days)} }
      specify { user.reload.temporary_banned?.should be_true }
    end

    context "banning a user" do
      let!(:target_user) { create(:user) }
      before { put :update, id: target_user.id, user: {status: 2} }
      context "when user is a user admin" do
        let(:user) { create(:user_admin) }
        specify { target_user.reload.banned?.should be_true }
      end
    end

    context "updating openid_url" do
      it "redirects to the OpenID URL" do
        ApplicationController.any_instance
          .should_receive(:start_openid_session)
          .with("http://example.com/", {
            success: update_openid_user_url(:id => user.username),
            fail:    edit_user_page_url(:id => user.username, :page => 'settings')
          })
          .and_return(false)
        put :update, id: user.id, user: {openid_url: "http://example.com/"}, page: 'settings'
      end

      context "with a valid OpenID URL" do
        before do
          ApplicationController.any_instance.stub(:start_openid_session) do
            controller.redirect_to "http://example.com/"
            true
          end
          put :update, id: user.id, user: {openid_url: "http://example.com/"}, page: 'settings'
        end
        it { should redirect_to("http://example.com/") }
      end

      context "with an invalid OpenID URL" do
        before do
          ApplicationController.any_instance.stub(:start_openid_session) { false }
          put :update, id: user.id, user: {openid_url: "invalid"}, page: 'settings'
        end

        it { should respond_with(:success) }
        specify { assigns(:user).should be_a(User) }
        it { should render_template(:edit) }
        specify { flash.now[:notice].should == "That's not a valid OpenID URL!"}
      end
    end
  end

end
