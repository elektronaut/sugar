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

  describe '#update' do
    before { login user }

    context "regular update" do
      before { put :update, id: user.id, user: {realname: "New name"} }

      it { should assign_to(:user) }
      it { should redirect_to(edit_user_page_url(user.username, page: 'info')) }
      it { should set_the_flash.to("Your changes were saved!") }
      specify { user.reload.realname.should == "New name" }
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
        it { should assign_to(:user) }
        it { should render_template(:edit) }
        specify { flash.now[:notice].should == "That's not a valid OpenID URL!"}
      end
    end
  end

end
