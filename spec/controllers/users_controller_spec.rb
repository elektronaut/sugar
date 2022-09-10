# frozen_string_literal: true

require "rails_helper"

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
    specify { expect(flash[:notice]).to be_nil }
    it { is_expected.to render_template(:index) }
  end

  describe "#index.json" do
    before do
      login
      @user = create(:user)
      get :index, format: :json
    end

    specify { expect(assigns(:users)).to be_a(ActiveRecord::Relation) }
    specify { expect(flash[:notice]).to be_nil }

    it "renders JSON" do
      json = JSON.parse(response.body)
      expect(json["data"]).to be_kind_of(Array)
    end
  end

  describe "#deactivated" do
    before do
      login
      @user = create(:banned_user)
      get :deactivated
    end

    specify { expect(assigns(:users)).to be_a(ActiveRecord::Relation) }
    specify { expect(flash[:notice]).to be_nil }
    it { is_expected.to render_template(:deactivated) }
  end

  describe "#deactivated.json" do
    before do
      login
      @user = create(:banned_user)
      get :deactivated, format: :json
    end

    it "renders JSON" do
      json = JSON.parse(response.body)
      expect(json["data"]).to be_kind_of(Array)
    end
  end

  describe "#grant_invite" do
    let(:admin) { create(:user_admin) }

    before do
      login admin
      post :grant_invite, params: { id: user.username }
      user.reload
    end

    it "increases the user's available invites" do
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
      post :revoke_invites, params: { id: user.username }
      user.reload
    end

    it "sets user's available invites to zero" do
      expect(user.available_invites).to eq(0)
    end

    it "sets the flash" do
      expect(flash[:notice]).to match("has been revoked of all invites")
    end

    it { is_expected.to redirect_to(user_profile_url(user.username)) }
  end

  describe "#update" do
    before { login user }

    context "when updating profile" do
      before do
        put :update, params: { id: user.id, user: { realname: "New name" } }
      end

      specify { expect(assigns(:user)).to be_a(User) }
      specify { expect(flash[:notice]).to match("Your changes were saved!") }

      it "redirects back to the edit page" do
        expect(response).to redirect_to(
          edit_user_page_url(user.username, page: "info")
        )
      end

      specify { expect(user.reload.realname).to eq("New name") }
    end

    context "when going on hiatus" do
      before do
        put(:update,
            params: {
              id: user.id,
              user: { hiatus_until: (Time.now.utc + 2.days) }
            })
      end

      specify { expect(user.reload.temporary_banned?).to be(true) }
    end

    context "when banning a user" do
      let!(:target_user) { create(:user) }
      let(:user) { create(:user_admin) }

      before do
        put :update, params: { id: target_user.id,
                               user: { status: :banned } }
      end

      specify { expect(target_user.reload.banned?).to be(true) }
    end
  end
end
