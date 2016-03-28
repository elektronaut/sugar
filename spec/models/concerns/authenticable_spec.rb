# encoding: utf-8

require "rails_helper"

describe Authenticable do
  # Create the first admin user
  before { create(:user, openid_url: "http://whatever.com", facebook_uid: 345) }

  let(:user) do
    create(:user, facebook_uid: 123, openid_url: "http://example.com")
  end
  let(:banned_user) { create(:banned_user) }

  subject { user }

  it { is_expected.to validate_presence_of(:hashed_password) }

  it "should validate openid_url" do
    is_expected.to validate_uniqueness_of(:openid_url)
      .with_message(/is already registered/)
  end

  it "should validate facebook_uid" do
    is_expected.to validate_uniqueness_of(:facebook_uid)
      .case_insensitive
      .with_message(/is already registered/)
  end

  it { is_expected.to have_many(:password_reset_tokens).dependent(:destroy) }

  describe "password validation" do
    subject { user.errors[:password] }
    before { user.valid? }

    context "when confirm_password is missing" do
      let(:user) { build(:user, password: "new") }
      specify { expect(subject.length).to eq(1) }
    end

    context "when confirm_password is wrong" do
      let(:user) { build(:user, password: "new", confirm_password: "wrong") }
      specify { expect(subject.length).to eq(1) }
    end

    context "when confirm_password is present" do
      let(:user) { build(:user, password: "new", confirm_password: "new") }
      it { is_expected.to eq([]) }
    end
  end

  describe "password generation" do
    context "when user is a Facebook user" do
      let(:user) { create(:facebook_user) }

      it "should generate a password" do
        expect(user.password.blank?).to eq(false)
        expect(user.hashed_password.blank?).to eq(false)
        expect(user.valid?).to eq(true)
      end
    end
  end

  describe ".encrypt_password" do
    before do
      allow(BCrypt::Password).to receive(:create).and_return("hashed password")
    end
    subject { User.encrypt_password("password") }
    it { is_expected.to eq("hashed password") }
  end

  describe ".find_and_authenticate_with_password" do
    let(:username) { "user123" }
    let(:password) { "password123" }
    let!(:user) do
      create(
        :user,
        username: "user123",
        password: "password123",
        confirm_password: "password123"
      )
    end
    subject { User.find_and_authenticate_with_password(username, password) }

    context "when username and password is correct" do
      it { is_expected.to eq(user) }
    end

    context "when username is wrong" do
      let(:username) { "user456" }
      it { is_expected.to eq(nil) }
    end

    context "when username is blank" do
      let(:username) { nil }
      it { is_expected.to eq(nil) }
    end

    context "when password is wrong" do
      let(:password) { "password456" }
      it { is_expected.to eq(nil) }
    end

    context "when password is blank" do
      let(:password) { nil }
      it { is_expected.to eq(nil) }
    end
  end

  describe "#facebook?" do
    specify { expect(create(:user, facebook_uid: 123).facebook?).to eq(true) }
    specify { expect(create(:user, facebook_uid: nil).facebook?).to eq(false) }
  end

  describe "#active" do
    specify { expect(user.active).to eq(true) }
    specify { expect(banned_user.active).to eq(false) }
  end

  describe "#valid_password?" do
    context "with SHA1 hashed password" do
      specify do
        expect(
          create(
            :user,
            hashed_password: Digest::SHA1.hexdigest("password123")
          ).valid_password?("password123")
        ).to eq(true)
      end
      specify do
        expect(
          create(
            :user,
            hashed_password: Digest::SHA1.hexdigest("password123")
          ).valid_password?("password")
        ).to eq(false)
      end
    end

    context "with BCrypt hashed password" do
      specify do
        expect(
          create(
            :user,
            hashed_password: BCrypt::Password.create("password123")
          ).valid_password?("password123")
        ).to eq(true)
      end
      specify do
        expect(
          create(
            :user,
            hashed_password: BCrypt::Password.create("password123")
          ).valid_password?("password")).to eq(false)
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
    specify { expect(user.new_password?).to eq(false) }
    specify do
      expect(build(:user, password: "New password").new_password?).to eq(true)
    end
  end

  describe "#new_password_confirmed?" do
    specify { expect(user.new_password_confirmed?).to eq(false) }
    specify do
      expect(build(:user, password: "new").new_password_confirmed?).to eq(false)
    end
    specify do
      expect(
        build(
          :user, password: "new", confirm_password: "wrong"
        ).new_password_confirmed?
      ).to eq(false)
    end
    specify do
      expect(
        build(
          :user, password: "new", confirm_password: "new"
        ).new_password_confirmed?
      ).to eq(true)
    end
  end

  describe "#password_needs_rehash?" do
    context "when password is hashed with SHA1" do
      specify do
        expect(
          create(
            :user, hashed_password: Digest::SHA1.hexdigest("password123")
          ).password_needs_rehash?
        ).to eq(true)
      end
    end

    context "when password is hashed with BCrypt" do
      specify do
        expect(
          create(
            :user, hashed_password: BCrypt::Password.create("password123")
          ).password_needs_rehash?
        ).to eq(false)
      end
    end
  end

  describe "#temporary_banned?" do
    specify { expect(user.temporary_banned?).to eq(false) }
    specify do
      expect(
        create(
          :user, banned_until: 2.days.ago
        ).temporary_banned?
      ).to eq(false)
    end
    specify do
      expect(
        create(
          :user, banned_until: (Time.now.utc + 2.days)
        ).temporary_banned?
      ).to eq(true)
    end
  end

  describe "#ensure_password" do
    before { user.valid? }
    subject { user.password }

    context "when signed up with email" do
      let(:user) { build(:user, hashed_password: nil) }
      it { is_expected.to be_blank }
    end

    context "when signed up with Facebook" do
      let(:user) { build(:user, hashed_password: nil, facebook_uid: 1) }
      it { is_expected.to_not be_blank }
    end

    context "when signed up with OpenID" do
      let(:user) do
        build(:user, hashed_password: nil, openid_url: "http://example.com/")
      end
      it { is_expected.to_not be_blank }
    end

    context "when password is set" do
      let(:user) { create(:user, password: "new", confirm_password: "new") }
      it { is_expected.to eq("new") }
    end
  end

  describe "#normalize_openid_url" do
    before { user.valid? }
    subject { user.openid_url }

    context "when missing http" do
      let(:user) { build(:user, openid_url: "example.com") }
      it { is_expected.to eq("http://example.com/") }
    end

    context "when not missing http" do
      let(:user) { build(:user, openid_url: "https://example.com") }
      it { is_expected.to eq("https://example.com/") }
    end
  end

  describe "#encrypt_new_password" do
    let(:user) do
      build(
        :user, hashed_password: nil, password: "new", confirm_password: "new"
      )
    end
    before { user.valid? }
    subject { user.hashed_password }
    it { is_expected.to_not be_blank }
  end

  describe "#clear_banned_until" do
    specify do
      expect(
        create(:user, banned_until: 2.seconds.ago).banned_until
      ).to eq(nil)
    end
    specify do
      expect(
        create(:user, banned_until: (Time.now.utc + 2.days)).banned_until
      ).to be_kind_of(Time)
    end
  end

  describe "#update_persistence_token" do
    let!(:previous_token) { user.persistence_token }
    subject { user.persistence_token }
    it { is_expected.to_not be_blank }

    context "when password is changed" do
      before do
        user.password = user.confirm_password = "new password"
        user.save
      end

      it { is_expected.to_not eq(previous_token) }
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
