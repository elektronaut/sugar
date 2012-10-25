# encoding: utf-8

require 'spec_helper'

describe Authenticable do

  let(:user)          { create(:user, facebook_uid: 123, openid_url: 'http://example.com') }
  let(:banned_user)   { create(:banned_user) }
  let(:inactive_user) { create(:user, activated: false) }

  subject { user }

  it { should validate_presence_of(:hashed_password) }
  it { should validate_uniqueness_of(:openid_url).with_message(/is already registered/) }
  it { should validate_uniqueness_of(:facebook_uid).with_message(/is already registered/) }

  specify { build(:user, password: 'new').should have(1).errors_on(:password) }
  specify { build(:user, password: 'new', confirm_password: 'wrong').should have(1).errors_on(:password) }
  specify { build(:user, password: 'new', confirm_password: 'new').should have(0).errors_on(:password) }

  describe ".encrypt_password" do
    before { BCrypt::Password.stub(:create).and_return('hashed password') }
    subject { User.encrypt_password('password') }
    it { should == 'hashed password' }
  end

  describe "#facebook?" do
    specify { create(:user, facebook_uid: 123).facebook?.should be_true }
    specify { create(:user, facebook_uid: nil).facebook?.should be_false }
  end

  describe "#generate_new_password!" do
    subject { user.generate_new_password! }
    it { should be_kind_of(String) }
    it { should == user.password }
    specify { user.should be_valid }
  end

  describe "#valid_password?" do

    context "with SHA1 hashed password" do
      specify do
        create(:user, hashed_password: Digest::SHA1.hexdigest("password123"))
          .valid_password?("password123").should be_true
      end
      specify do
        create(:user, hashed_password: Digest::SHA1.hexdigest("password123"))
          .valid_password?("password").should be_false
      end
    end

    context "with BCrypt hashed password" do
      specify do
        create(:user, hashed_password: BCrypt::Password.create("password123"))
          .valid_password?("password123").should be_true
      end
      specify do
        create(:user, hashed_password: BCrypt::Password.create("password123"))
          .valid_password?("password").should be_false
      end
    end

  end

  describe "#hash_password!" do
    before { User.stub(:encrypt_password).and_return("encrypted password") }
    it "hashes the password" do
      user.hash_password!("new password")
      user.hashed_password.should == "encrypted password"
    end
  end

  describe "#new_password?" do
    specify { user.new_password?.should be_false }
    specify { build(:user, password: "New password").new_password?.should be_true }
  end

  describe "#new_password_confirmed?" do
    specify { user.new_password_confirmed?.should be_false }
    specify { build(:user, password: "new").new_password_confirmed?.should be_false }
    specify { build(:user, password: "new", confirm_password: "wrong").new_password_confirmed?.should be_false }
    specify { build(:user, password: "new", confirm_password: "new").new_password_confirmed?.should be_true }
  end

  describe "#password_needs_rehash?" do

    context "when password is hashed with SHA1" do
      specify do
        create(:user, hashed_password: Digest::SHA1.hexdigest("password123"))
          .password_needs_rehash?.should be_true
      end
    end

    context "when password is hashed with BCrypt" do
      specify do
        create(:user, hashed_password: BCrypt::Password.create("password123"))
          .password_needs_rehash?.should be_false
      end
    end

  end

  describe "#temporary_banned?" do
    specify { user.temporary_banned?.should be_false }
    specify { create(:user, banned_until: 2.days.ago).temporary_banned?.should be_false }
    specify { create(:user, banned_until: (Time.now + 2.days)).temporary_banned?.should be_true }
  end

  describe "#status" do
    specify { inactive_user.status.should == 0 }
    specify { user.status.should == 1 }
    specify { banned_user.status.should == 2 }
  end

  describe "#status=" do

    context "when 0" do
      before { user.status = 0 }
      specify { user.banned?.should be_false }
      specify { user.activated?.should be_false }
    end

    context "when 1" do
      before { user.status = 1 }
      specify { user.banned?.should be_false }
      specify { user.activated?.should be_true }
    end

    context "when 2" do
      before { user.status = 2 }
      specify { user.banned?.should be_true }
      specify { user.activated?.should be_true }
    end

  end

  describe "#ensure_password" do
    before { user.valid? }
    subject { user.password }

    context "when signed up with email" do
      let(:user) { build(:user, hashed_password: nil) }
      it { should be_blank }
    end

    context "when signed up with Facebook" do
      let(:user) { build(:user, hashed_password: nil, facebook_uid: 1) }
      it { should_not be_blank }
    end

    context "when signed up with OpenID" do
      let(:user) { build(:user, hashed_password: nil, openid_url: "http://example.com/") }
      it { should_not be_blank }
    end

    context "when password is set" do
     let(:user) { create(:user, password: 'new', confirm_password: 'new') }
     it { should == 'new' }
    end

  end

  describe "#normalize_openid_url" do
    before { user.valid? }
    subject { user.openid_url }

    context "when missing http" do
      let(:user) { build(:user, openid_url: 'example.com') }
      it { should == 'http://example.com/' }
    end

    context "when not missing http" do
      let(:user) { build(:user, openid_url: 'https://example.com') }
      it { should == 'https://example.com/' }
    end

  end

  describe "#encrypt_new_password" do
    let(:user) { build(:user, hashed_password: nil, password: 'new', confirm_password: 'new') }
    before { user.valid? }
    subject { user.hashed_password }
    it { should_not be_blank }
  end

  describe "#clear_banned_until" do
    specify { create(:user, banned_until: 2.seconds.ago).banned_until.should be_nil }
    specify { create(:user, banned_until: (Time.now + 2.days)).banned_until.should be_kind_of(Time) }
  end

end