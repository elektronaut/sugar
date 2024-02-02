# frozen_string_literal: true

require "rails_helper"

describe PasswordResetsController do
  let(:user) { create(:user) }
  let(:expires_at) { 24.hours.from_now }

  let(:token) do
    Rails.application.message_verifier(:password_reset)
         .generate(user.id, expires_at:)
  end

  describe "GET new" do
    before { get :new }

    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template(:new) }
  end

  describe "POST create" do
    context "with an existing user" do
      before do
        perform_enqueued_jobs do
          post :create, params: { email: user.email }
        end
      end

      it { is_expected.to redirect_to(login_users_url) }

      it "sets the flash" do
        expect(flash[:notice]).to match(
          /An email with further instructions has been sent/
        )
      end

      specify { expect(assigns(:user)).to be_a(User) }

      specify { expect(last_email.to).to eq([user.email]) }
    end

    context "with a non-existant user" do
      before { post :create, params: { email: "none@example.com" } }

      it { is_expected.to redirect_to(login_users_url) }

      specify do
        expect(flash.now[:notice]).to match(
          /An email with further instructions has been sent/
        )
      end
    end
  end

  describe "GET show" do
    context "with a valid token" do
      before do
        get(:show, params: { token: })
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:show) }
      specify { expect(assigns(:user)).to be_a(User) }
    end

    context "without a valid token" do
      before { get :show }

      it { is_expected.to redirect_to(login_users_url) }

      specify do
        expect(flash[:notice]).to match(/Not a valid URL/)
      end
    end

    context "with an expired token" do
      let(:expires_at) { 2.days.ago }

      before do
        get :show, params: { token: }
      end

      it { is_expected.to redirect_to(login_users_url) }

      specify do
        expect(flash.now[:notice]).to match(/Not a valid URL/)
      end
    end

    context "with an invalid token" do
      before { get :show, params: { token: "456" } }

      it { is_expected.to redirect_to(login_users_url) }

      specify do
        expect(flash.now[:notice]).to match(/Not a valid URL/)
      end
    end
  end

  describe "PUT update" do
    context "with valid data" do
      before do
        put :update,
            params: {
              token:,
              user: { password: "new password",
                      password_confirmation: "new password" }
            }
      end

      specify do
        expect(flash[:notice]).to match(/Your password has been changed/)
      end

      specify { expect(assigns(:current_user)).to be_a(User) }
      it { is_expected.to redirect_to(root_url) }
      specify { expect(session[:user_id]).to eq(user.id) }
    end

    context "without valid data" do
      before do
        put :update,
            params: {
              token:,
              user: {
                password: "new password",
                password_confirmation: "wrong password"
              }
            }
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:show) }
      specify { expect(assigns(:user)).to be_a(User) }
    end

    context "without a valid token" do
      before do
        put :update,
            params: {
              user: { password: "new password",
                      password_confirmation: "new password" }
            }
      end

      it { is_expected.to redirect_to(login_users_url) }

      specify do
        expect(flash.now[:notice]).to match(/Not a valid URL/)
      end
    end

    context "with an expired token" do
      let(:expires_at) { 2.days.ago }

      before do
        put :update,
            params: {
              token:,
              user: { password: "new password",
                      password_confirmation: "new password" }
            }
      end

      it { is_expected.to redirect_to(login_users_url) }

      specify do
        expect(flash.now[:notice]).to match(/Not a valid URL/)
      end
    end
  end
end
