# encoding: utf-8

require "rails_helper"

describe UsersController, redis: true do
  let(:invite) { create(:invite) }

  describe "#new" do
    context "with a valid invite token" do
      before do
        configure signups_allowed: false
        get :new, params: { token: invite.token }
      end
      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:new) }
      specify { expect(assigns(:invite)).to be_a(Invite) }
      specify { expect(assigns(:user)).to be_a(User) }
      specify { expect(assigns(:user).email).to eq(invite.email) }
    end

    context "without a valid invite token" do
      before do
        create(:user) # Ensures the first user exists
        configure signups_allowed: false
        get :new
      end
      specify { expect(flash[:notice]).to match("Signups are not allowed") }
      it { is_expected.to redirect_to(login_users_url) }
    end
  end

  describe "#create" do
    let(:params) do
      attributes = attributes_for(:user)
      {
        username:         attributes[:username],
        email:            attributes[:email],
        password:         "randompassword",
        confirm_password: "randompassword",
        realname:         attributes[:realname]
      }
    end

    context "with a valid invite token" do
      before { post :create, params: { token: invite.token, user: params } }
      specify { expect(assigns(:invite)).to be_a(Invite) }
      specify { expect(assigns(:user)).to be_a(User) }
      it "should redirect " do
        is_expected.to redirect_to(
          user_profile_url(id: assigns(:user).username)
        )
      end
    end
  end
end
