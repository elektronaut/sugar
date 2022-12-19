# frozen_string_literal: true

require "rails_helper"

describe Authenticable do
  subject(:user) { create(:user, facebook_uid: 123) }

  let(:banned_user) { create(:banned_user) }

  # Create the first admin user
  before { create(:user, facebook_uid: 345) }

  it { is_expected.to validate_presence_of(:hashed_password) }

  it "validates facebook_uid" do
    expect(user).to validate_uniqueness_of(:facebook_uid)
      .case_insensitive
      .with_message(/is already registered/)
  end

  describe "password validation" do
    subject { user.errors[:password] }

    let(:length) { subject.length }

    before { user.valid? }

    context "when confirm_password is missing" do
      let(:user) { build(:user, password: "new") }

      specify { expect(length).to eq(1) }
    end

    context "when confirm_password is wrong" do
      let(:user) { build(:user, password: "new", confirm_password: "wrong") }

      specify { expect(length).to eq(1) }
    end

    context "when confirm_password is present" do
      let(:user) { build(:user, password: "new", confirm_password: "new") }

      it { is_expected.to eq([]) }
    end
  end

  describe "password generation" do
    context "when user is a Facebook user" do
      let(:user) { create(:facebook_user) }

      it "generates a password" do
        expect(user.password.blank?).to be(false)
      end

      it "creates a valid user" do
        expect(user.valid?).to be(true)
      end
    end
  end

  describe ".encrypt_password" do
    subject { User.encrypt_password("password") }

    before do
      allow(BCrypt::Password).to receive(:create).and_return("hashed password")
    end

    it { is_expected.to eq("hashed password") }
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
        confirm_password: "password123"
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

      it { is_expected.to be_nil }
    end

    context "when email is blank" do
      let(:email) { nil }

      it { is_expected.to be_nil }
    end

    context "when password is wrong" do
      let(:password) { "password456" }

      it { is_expected.to be_nil }
    end

    context "when password is blank" do
      let(:password) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe "#facebook?" do
    specify { expect(create(:user, facebook_uid: 123).facebook?).to be(true) }
    specify { expect(create(:user, facebook_uid: nil).facebook?).to be(false) }
  end

  describe "#active" do
    specify { expect(user.active?).to be(true) }
    specify { expect(banned_user.active?).to be(false) }
  end

  describe "#valid_password?" do
    context "with SHA1 hashed password" do
      specify do
        expect(
          create(:user, hashed_password: Digest::SHA1.hexdigest("password123"))
            .valid_password?("password123")
        ).to be(true)
      end

      specify do
        expect(
          create(:user, hashed_password: Digest::SHA1.hexdigest("password123"))
            .valid_password?("password")
        ).to be(false)
      end
    end

    context "with BCrypt hashed password" do
      specify do
        expect(
          create(:user, hashed_password: BCrypt::Password.create("password123"))
            .valid_password?("password123")
        ).to be(true)
      end

      specify do
        expect(
          create(:user, hashed_password: BCrypt::Password.create("password123"))
            .valid_password?("password")
        ).to be(false)
      end
    end
  end

  describe "#hash_password!" do
    before do
      allow(User).to receive(:encrypt_password).and_return("encrypted password")
    end

    it "hashes the password" do
      user.hash_password!("new password")
      expect(user.hashed_password).to eq("encrypted password")
    end
  end

  describe "#new_password?" do
    specify { expect(user.new_password?).to be(false) }

    specify do
      expect(build(:user, password: "New password").new_password?).to be(true)
    end
  end

  describe "#new_password_confirmed?" do
    specify { expect(user.new_password_confirmed?).to be(false) }

    specify do
      expect(build(:user, password: "new").new_password_confirmed?).to be(false)
    end

    specify do
      expect(
        build(
          :user, password: "new", confirm_password: "wrong"
        ).new_password_confirmed?
      ).to be(false)
    end

    specify do
      expect(
        build(
          :user, password: "new", confirm_password: "new"
        ).new_password_confirmed?
      ).to be(true)
    end
  end

  describe "#password_needs_rehash?" do
    context "when password is hashed with SHA1" do
      specify do
        expect(
          create(
            :user, hashed_password: Digest::SHA1.hexdigest("password123")
          ).password_needs_rehash?
        ).to be(true)
      end
    end

    context "when password is hashed with BCrypt" do
      specify do
        expect(
          create(
            :user, hashed_password: BCrypt::Password.create("password123")
          ).password_needs_rehash?
        ).to be(false)
      end
    end
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

  describe "#ensure_password" do
    subject { user.password }

    before { user.valid? }

    context "when signed up with email" do
      let(:user) { build(:user, hashed_password: nil) }

      it { is_expected.to be_blank }
    end

    context "when signed up with Facebook" do
      let(:user) { build(:user, hashed_password: nil, facebook_uid: 1) }

      it { is_expected.not_to be_blank }
    end

    context "when password is set" do
      let(:user) { create(:user, password: "new", confirm_password: "new") }

      it { is_expected.to eq("new") }
    end
  end

  describe "#encrypt_new_password" do
    subject { user.hashed_password }

    let(:user) do
      build(
        :user, hashed_password: nil, password: "new", confirm_password: "new"
      )
    end

    before { user.valid? }

    it { is_expected.not_to be_blank }
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
        user.password = user.confirm_password = "new password"
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
