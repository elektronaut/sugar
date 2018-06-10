# frozen_string_literal: true

require "rails_helper"

describe PasswordResetToken do
  let(:password_reset_token) { create(:password_reset_token) }
  let(:expired_password_reset_token) do
    create(:password_reset_token, expires_at: 2.days.ago)
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:user_id) }

  describe ".expire!" do
    before do
      password_reset_token
      expired_password_reset_token
      PasswordResetToken.expire!
    end
    specify { expect(PasswordResetToken.all).to eq([password_reset_token]) }
  end

  describe "#expired?" do
    subject { password_reset_token.expired? }

    context "when token is valid" do
      it { is_expected.to eq(false) }
    end

    context "when token is expired" do
      let(:password_reset_token) { expired_password_reset_token }
      it { is_expected.to eq(true) }
    end
  end

  describe "#expires_at" do
    subject { password_reset_token.expires_at }
    it { is_expected.to be_within(30).of(Time.now.utc + 48.hours) }
  end

  describe "#token" do
    subject { password_reset_token.token }
    specify { expect(subject.length).to eq(32) }
  end
end
