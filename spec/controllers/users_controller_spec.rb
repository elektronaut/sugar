require "spec_helper"

describe UsersController do

  let(:user) { create(:user) }

  # Create the first admin user
  before { create(:user) }

  describe "#index" do
    before do
      login
      @user = create(:user)
      get :index
    end

    specify { expect(assigns(:users)).to be_a(ActiveRecord::Relation) }
    specify { expect(flash[:notice]).to eq(nil) }
    it { is_expected.to render_template(:index) }
  end

  describe "#index.json" do
    before do
      login
      @user = create(:user)
      get :index, format: :json
      @json = JSON.parse(response.body)
    end

    specify { expect(assigns(:users)).to be_a(ActiveRecord::Relation) }
    specify { expect(flash[:notice]).to eq(nil) }

    it "renders JSON" do
      expect(@json["users"]).to be_kind_of(Array)
    end
  end

  describe "#banned" do
    before do
      login
      @user = create(:user, banned: true)
      get :banned
    end

    specify { expect(assigns(:users)).to be_a(ActiveRecord::Relation) }
    specify { expect(flash[:notice]).to eq(nil) }
    it { is_expected.to render_template(:banned) }
  end

  describe "#banned.json" do
    before do
      login
      @user = create(:user, banned: true)
      get :banned, format: :json
      @json = JSON.parse(response.body)
    end

    it "renders JSON" do
      expect(@json["users"]).to be_kind_of(Array)
    end
  end

  describe "#grant_invite" do
    let(:admin) { create(:user_admin) }
    before do
      login admin
      post :grant_invite, id: user.username
      user.reload
    end

    it "should increase the user's available invites" do
      expect(user.available_invites).to eq(1)
    end

    specify { expect(flash[:notice]).to match("has been granted one invite") }
    it { is_expected.to redirect_to(user_profile_url(user.username)) }
  end

  describe "#revoke_invites" do
    let(:admin) { create(:user_admin) }
    let(:user) { create(:user, available_invites: 1) }
    before do
      login admin
      post :revoke_invites, id: user.username
      user.reload
    end

    it "should set user's available invites to zero" do
      expect(user.available_invites).to eq(0)
    end

    it "should set the flash" do
      expect(flash[:notice]).to match("has been revoked of all invites")
    end

    it { is_expected.to redirect_to(user_profile_url(user.username)) }
  end

  describe "#update" do
    before { login user }

    context "regular update" do
      before { put :update, id: user.id, user: { realname: "New name" } }

      specify { expect(assigns(:user)).to be_a(User) }
      specify { expect(flash[:notice]).to match("Your changes were saved!") }

      it "should redirect back to the edit page" do
        is_expected.to redirect_to(
          edit_user_page_url(user.username, page: "info")
        )
      end

      specify { expect(user.reload.realname).to eq("New name") }
    end

    context "self banning" do
      before do
        put :update, id: user.id, user: { banned_until: (Time.now + 2.days) }
      end

      specify { expect(user.reload.temporary_banned?).to eq(true) }
    end

    context "banning a user" do
      let!(:target_user) { create(:user) }
      before { put :update, id: target_user.id, user: { banned: true } }
      context "when user is a user admin" do
        let(:user) { create(:user_admin) }
        specify { expect(target_user.reload.banned?).to eq(true) }
      end
    end

    context "updating openid_url" do
      it "redirects to the OpenID URL" do
        expect_any_instance_of(
          ApplicationController
        ).to receive(:start_openid_session).
          with(
            "http://example.com/",
            success: update_openid_user_url(id: user.username),
            fail:    edit_user_page_url(id: user.username, page: "settings")
          ).
          and_return(false)
        put(
          :update,
          id: user.id,
          user: { openid_url: "http://example.com/" },
          page: "settings"
        )
      end

      context "with a valid OpenID URL" do
        before do
          allow_any_instance_of(
            ApplicationController
          ).to receive(:start_openid_session) do
            controller.redirect_to "http://example.com/"
            true
          end
          put(
            :update,
            id: user.id,
            user: { openid_url: "http://example.com/" },
            page: "settings"
          )
        end
        it { is_expected.to redirect_to("http://example.com/") }
      end

      context "with an invalid OpenID URL" do
        before do
          allow_any_instance_of(
            ApplicationController
          ).to receive(:start_openid_session).
            and_return(false)
          put(
            :update,
            id: user.id,
            user: { openid_url: "invalid" },
            page: "settings"
          )
        end

        it { is_expected.to respond_with(:success) }
        specify { expect(assigns(:user)).to be_a(User) }
        it { is_expected.to render_template(:edit) }

        it "should set the flash" do
          expect(flash.now[:notice]).to eq("That's not a valid OpenID URL!")
        end
      end
    end
  end
end
