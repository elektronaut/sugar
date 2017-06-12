# encoding: utf-8

require "rails_helper"

describe PasswordResetsController do
  let(:user) { create(:user) }
  let(:password_reset_token) { create(:password_reset_token) }
  let(:expired_password_reset_token) do
    create(:password_reset_token, expires_at: 2.days.ago)
  end

  describe "GET new" do
    before { get :new }
    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template(:new) }
  end

  describe "POST create" do
    context "with an existing user" do
      before { post :create, params: { email: user.email } }
      it { is_expected.to redirect_to(login_users_url) }
      it "should set the flash" do
        expect(flash[:notice]).to match(
          /An email with further instructions has been sent/
        )
      end
      specify { expect(assigns(:user)).to be_a(User) }
      specify do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end
      specify { expect(last_email.to).to eq([user.email]) }
      specify do
        expect(last_email.body.encoded).to(
          match(
            password_reset_with_token_url(
              assigns(:password_reset_token).id,
              assigns(:password_reset_token).token
            )
          )
        )
      end
    end

    context "with a non-existant user" do
      before { post :create, params: { email: "none@example.com" } }
      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:new) }
      specify { expect(assigns(:password_reset_token)).to eq(nil) }
      specify do
        expect(flash.now[:notice]).to match(
          /Couldn't find a user with that email address/
        )
      end
    end
  end

  describe "GET show" do
    context "with a valid token" do
      before do
        get(
          :show,
          params: {
            id: password_reset_token.id,
            token: password_reset_token.token
          }
        )
      end
      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:show) }
      specify { expect(assigns(:user)).to be_a(User) }
      specify do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end
    end

    context "without a valid token" do
      before { get :show, params: { id: password_reset_token.id } }
      it { is_expected.to redirect_to(login_users_url) }
      specify do
        expect(flash.now[:notice]).to match(/Invalid password reset request/)
      end
    end

    context "with an expired token" do
      before do
        get :show,
            params: {
              id: expired_password_reset_token.id,
              token: expired_password_reset_token.token
            }
      end
      specify do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end
      it { is_expected.to redirect_to(login_users_url) }
      specify do
        expect(flash.now[:notice]).to match(
          /Your password reset link has expired/
        )
      end
      specify { expect(assigns(:password_reset_token).destroyed?).to eq(true) }
    end

    context "with a non-existant token" do
      before { get :show, params: { id: 123, token: "456" } }
      it { is_expected.to redirect_to(login_users_url) }
      specify do
        expect(flash.now[:notice]).to match(/Invalid password reset request/)
      end
    end
  end

  describe "PUT update" do
    context "with valid data" do
      before do
        put :update,
            params: {
              id: password_reset_token.id,
              token: password_reset_token.token,
              user: { password: "new password", confirm_password: "new password" }
            }
      end
      specify do
        expect(flash[:notice]).to match(/Your password has been changed/)
      end
      specify { expect(assigns(:current_user)).to be_a(User) }
      it { is_expected.to redirect_to(root_url) }
      specify { expect(session[:user_id]).to eq(password_reset_token.user.id) }
      specify { expect(assigns(:password_reset_token).destroyed?).to eq(true) }
    end

    context "without valid data" do
      before do
        put :update,
            params: {
              id: password_reset_token.id,
              token: password_reset_token.token,
              user: {
                password: "new password",
                confirm_password: "wrong password"
              }
            }
      end
      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:show) }
      specify { expect(assigns(:user)).to be_a(User) }
      specify do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end
      specify { expect(assigns(:password_reset_token).destroyed?).to eq(false) }
    end

    context "without a valid token" do
      before do
        put :update,
            params: {
              id: password_reset_token.id,
              user: { password: "new password", confirm_password: "new password" }
            }
      end
      it { is_expected.to redirect_to(login_users_url) }
      specify do
        expect(flash.now[:notice]).to match(/Invalid password reset request/)
      end
    end

    context "with an expired token" do
      before do
        put :update,
            params: {
              id: expired_password_reset_token.id,
              token: expired_password_reset_token.token,
              user: { password: "new password", confirm_password: "new password" }
            }
      end
      specify do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end
      it { is_expected.to redirect_to(login_users_url) }
      specify do
        expect(flash.now[:notice]).to match(
          /Your password reset link has expired/
        )
      end
      specify { expect(assigns(:password_reset_token).destroyed?).to eq(true) }
    end
  end
end
