# frozen_string_literal: true

require "rails_helper"

describe Authenticable do
  subject(:user) { create(:user) }

  let(:banned_user) { create(:user, :banned) }

  # Create the first admin user
  before { create(:user) }

  it { is_expected.to validate_presence_of(:password) }

  describe "password validation" do
    subject { user.errors[:password] }

    let(:length) { subject.length }

    before { user.valid? }

    context "when password_confirmation is missing" do
      let(:user) { build(:user, password: "new") }

      specify { expect(length).to eq(1) }
    end

    context "when password_confirmation is wrong" do
      let(:user) do
        build(:user, password: "new", password_confirmation: "wrong")
      end

      specify { expect(length).to eq(1) }
    end

    context "when password_confirmation is present" do
      let(:user) do
        build(:user,
              password: "new password",
              password_confirmation: "new password")
      end

      it { is_expected.to eq([]) }
    end
  end

  describe ".find_and_authenticate_with_password" do
    subject { User.find_and_authenticate_with_password(email, password) }

    let(:email) { "test@example.com" }
    let(:password) { "password123" }
    let!(:user) do
      create(
        :user,
        email: "test@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
    end

    context "when username and password is correct" do
      it { is_expected.to eq(user) }
    end

    context "when email has the wrong case" do
      let(:email) { "Test@example.com" }

      it { is_expected.to eq(user) }
    end

    context "when email is wrong" do
      let(:email) { "wrong@example.com" }

      it { is_expected.to be_falsey }
    end

    context "when email is blank" do
      let(:email) { nil }

      it { is_expected.to be_falsey }
    end

    context "when password is wrong" do
      let(:password) { "password456" }

      it { is_expected.to be_falsey }
    end

    context "when password is blank" do
      let(:password) { nil }

      it { is_expected.to be_falsey }
    end
  end

  describe "#active" do
    specify { expect(user.active?).to be(true) }
    specify { expect(banned_user.active?).to be(false) }
  end

  describe "#temporary_banned?" do
    specify { expect(user.temporary_banned?).to be(false) }

    specify do
      expect(
        create(
          :user, banned_until: 2.days.ago
        ).temporary_banned?
      ).to be(false)
    end

    specify do
      expect(
        create(
          :user, banned_until: (Time.now.utc + 2.days)
        ).temporary_banned?
      ).to be(true)
    end
  end

  describe "#clear_banned_until" do
    specify do
      expect(
        create(:user, banned_until: 2.seconds.ago).banned_until
      ).to be_nil
    end

    specify do
      expect(
        create(:user, banned_until: (Time.now.utc + 2.days)).banned_until
      ).to be_a(Time)
    end
  end

  describe "#update_persistence_token" do
    subject { user.persistence_token }

    let!(:previous_token) { user.persistence_token }

    it { is_expected.not_to be_blank }

    context "when password is changed" do
      before do
        user.password = user.password_confirmation = "new password"
        user.save
      end

      it { is_expected.not_to eq(previous_token) }
    end

    context "when password isn't changed" do
      before do
        user.realname = "New name"
        user.save
      end

      it { is_expected.to eq(previous_token) }
    end
  end
end
