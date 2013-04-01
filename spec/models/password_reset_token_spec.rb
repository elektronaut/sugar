require 'spec_helper'

describe PasswordResetToken do
  let (:password_reset_token) { create(:password_reset_token) }
  let (:expired_password_reset_token) { create(:password_reset_token, expires_at: 2.days.ago) }

  it { should belong_to(:user) }
  it { should validate_presence_of(:user_id) }

  describe ".expire!" do
    before do
      password_reset_token
      expired_password_reset_token
      PasswordResetToken.expire!
    end
    specify { PasswordResetToken.all.should == [password_reset_token] }
  end

  describe ".find_by_token" do
    let(:user) { password_reset_token.user }
    let(:token) { password_reset_token.token }
    subject { user.password_reset_tokens.find_by_token(token) }

    context "when a token exists" do
      it { should == password_reset_token }
    end

    context "when a token is expired" do
      let(:password_reset_token) { expired_password_reset_token }
      it { should be_nil }
    end

    context "when a doesn't exist" do
      let(:token) { 'wrong token' }
      it { should be_nil }
    end
  end

  describe "#expired?" do
    subject { password_reset_token.expired? }

    context "when token is valid" do
      it { should be_false }
    end

    context "when token is expired" do
      let(:password_reset_token) { expired_password_reset_token }
      it { should be_true }
    end
  end

  describe "#expires_at" do
    subject { password_reset_token.expires_at }
    it { should be_within(30).of(Time.now + 48.hours) }
  end

  describe "#token" do
    subject { password_reset_token.token }
    its(:length) { should == 32 }
  end
end
