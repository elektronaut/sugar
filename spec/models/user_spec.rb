# encoding: utf-8

require 'spec_helper'

describe User do

  let(:user)         { create(:user) }
  let(:trusted_user) { create(:trusted_user) }
  let(:admin)        { create(:admin) }
  let(:moderator)    { create(:moderator) }
  let(:user_admin)   { create(:user_admin) }
  let(:public_attributes) { [
    "admin", "avatar_url", "banned_until", "created_at", "description",
    "discussions_count", "flickr", "gamertag", "gtalk", "id", "instagram",
    "inviter_id", "last_active", "last_fm", "latitude", "location", "longitude",
    "moderator", "msn", "posts_count", "realname", "twitter", "user_admin",
    "username", "website"
  ] }

  subject { user }

  it { should be_kind_of(Authenticable) }
  it { should be_kind_of(Inviter) }
  it { should be_kind_of(ExchangeParticipant) }

  it { should validate_presence_of(:username) }
  it { should validate_uniqueness_of(:username).case_insensitive.with_message(/is already registered/) }
  it { should validate_format_of(:username).with("test").with_message("is not valid") }

  it { should allow_value("Gustave Moíre").for(:username) }
  it { should_not allow_value(";Bobby Tables").for(:username) }

  it { should validate_uniqueness_of(:email).case_insensitive.with_message(/is already registered/) }

  it { should allow_value("test@example.com").for(:email) }
  it { should_not allow_value("test.example.com").for(:email) }

  describe "validation" do

    context "when signed up with email" do
      it { should validate_presence_of(:email) }
    end

    context "when signed up with Facebook" do
      subject { build(:user, email: nil, facebook_uid: 123) }
      it { should_not validate_presence_of(:email) }
    end

    context "when signed up with OpenID" do
      subject { build(:user, email: nil, openid_url: "http://example.com/") }
      it { should_not validate_presence_of(:email) }
    end

    context "when signup approval is required" do
      subject { build(:user) }
      before { Sugar.config(:signup_approval_required, true) }
      it { should validate_presence_of(:realname) }
      it { should validate_presence_of(:application) }
    end

    context "signup approval isn't required" do
      before { Sugar.config(:signup_approval_required, false) }
      it { should_not validate_presence_of(:realname) }
      it { should_not validate_presence_of(:application) }
    end

  end

  describe "scopes" do

    describe "active" do
      let!(:not_activated) { create(:user, activated: false) }
      let!(:banned) { create(:user, banned: true) }
      let!(:active) { create(:user) }
      subject { User.active }
      it { should == [active] }
    end

    describe "by_username" do
      let!(:user1) { create(:user, username: 'danz') }
      let!(:user2) { create(:user, username: 'adam') }
      subject { User.by_username }
      it { should == [user2, user1] }
    end

    describe "banned" do
      let!(:not_banned) { create(:user) }
      let!(:banned) { create(:user, banned: true) }
      let!(:temporarily_banned) { create(:user, banned_until: (Time.now + 2.days)) }
      subject { User.banned }
      it { should =~ [banned, temporarily_banned] }
    end

    describe "online" do
      let!(:online) { create(:user, last_active: 5.minutes.ago) }
      let!(:not_online) { create(:user, last_active: 20.minutes.ago) }
      subject { User.online }
      it { should == [online] }
    end

    describe "admins" do
      let!(:user) { create(:user) }
      let!(:admin) { create(:admin) }
      let!(:moderator) { create(:moderator) }
      let!(:user_admin) { create(:user_admin) }
      subject { User.admins }
      it { should =~ [admin, moderator, user_admin] }
    end

    describe "xbox_users" do
      let!(:xbox_user) { create(:user, gamertag: 'example') }
      let!(:non_xbox_user) { create(:user, gamertag: nil) }
      subject { User.xbox_users }
      it { should == [xbox_user] }
    end

    describe "social" do
      let!(:user) { create(:user) }
      let!(:twitter) { create(:admin, twitter: 'elektronaut') }
      let!(:instagram) { create(:admin, instagram: 'elektronaut') }
      let!(:flickr) { create(:admin, flickr: 'elektronaut') }
      subject { User.social }
      it { should =~ [twitter, instagram, flickr] }
    end

    describe "recently_joined" do
      let!(:user1) { create(:user, created_at: 2.days.ago) }
      let!(:user2) { create(:user, created_at: 1.days.ago) }
      subject { User.recently_joined }
      it { should == [user2, user1] }
    end

    describe "top_posters" do
      let!(:user1) { create(:user, posts_count: 1) }
      let!(:user2) { create(:user, posts_count: 2) }
      let!(:user3) { create(:user, posts_count: 0) }
      subject { User.top_posters }
      it { should == [user2, user1] }
    end

    describe "trusted" do
      let!(:user) { create(:user) }
      let!(:trusted) { create(:trusted_user) }
      let!(:admin) { create(:admin) }
      let!(:moderator) { create(:moderator) }
      let!(:user_admin) { create(:user_admin) }
      subject { User.trusted }
      it { should =~ [trusted, admin, moderator, user_admin] }
    end

  end

  describe ".safe_attributes" do
    subject do
      User.safe_attributes(
        # Invalid attributes
        id: 1, username: 'username', hashed_password: 'hash',
        admin: true, activated: true, banned: true, trusted: true,
        moderator: true, user_admin: true, last_active: Time.now,
        created_at: Time.now, updated_at: Time.now, posts_count: 14,
        discussions_count: 12, inviter_id: 1, available_invites: 13,

        # Valid attributes
        realname: 'Test', email: 'test@example.com'
      )
    end

    it { should == { realname: 'Test', email: 'test@example.com' } }

  end

  describe "#full_email" do

    subject { user.full_email }

    context "when realname is set" do
      let(:user) { create(:user, realname: 'John') }
      it { should == "#{user.realname} <#{user.email}>" }
    end

    context "when realname isn't set" do
      let(:user) { create(:user, realname: nil) }
      it { should == "#{user.email}" }
    end

  end

  describe "#realname_or_username" do

    subject { user.realname_or_username }

    context "when realname is set" do
      let(:user) { create(:user, realname: 'John') }
      it { should == user.realname }
    end

    context "when realname isn't set" do
      let(:user) { create(:user, realname: nil) }
      it { should == user.username }
    end

  end

  describe "#online?" do
    specify { create(:user, last_active: 2.minutes.ago).online?.should be_true }
    specify { create(:user, last_active: 2.days.ago).online?.should be_false }
  end

  describe "#trusted?" do
    specify { trusted_user.trusted?.should be_true }
    specify { moderator.trusted?.should be_true }
    specify { user_admin.trusted?.should be_true }
    specify { admin.trusted?.should be_true }
    specify { user.trusted?.should be_false }
  end

  describe "#user_admin?" do
    specify { user_admin.user_admin?.should be_true }
    specify { admin.user_admin?.should be_true }
    specify { moderator.user_admin?.should be_false }
  end

  describe "#moderator?" do
    specify { moderator.moderator?.should be_true }
    specify { admin.moderator?.should be_true }
    specify { user_admin.moderator?.should be_false }
  end

  describe "#admin_labels" do
    specify { admin.admin_labels.should == ["Admin"] }
    specify { user_admin.admin_labels.should == ["User Admin"] }
    specify { moderator.admin_labels.should == ["Moderator"] }
    specify { create(:user, moderator: true, user_admin: true)
      .admin_labels.should == ["User Admin", "Moderator"] }
    specify { user.admin_labels.should == [] }
  end

  describe "#theme" do
    before { Sugar.config(:default_theme, "default") }
    specify { user.theme.should == "default" }
    specify { create(:user, theme: "mytheme").theme.should == "mytheme" }
  end

  describe "#mobile_theme" do
    before { Sugar.config(:default_mobile_theme, "default_mobile") }
    specify { user.mobile_theme.should == "default_mobile" }
    specify { create(:user, mobile_theme: "mytheme_mobile").mobile_theme.should == "mytheme_mobile" }
  end

  describe "#gamertag_avatar_url" do
    specify { user.gamertag_avatar_url.should be_nil }
    specify { create(:user, gamertag: 'my gamertag')
      .gamertag_avatar_url.should == "http://avatar.xboxlive.com/avatar/my%20gamertag/avatarpic-l.png" }
  end

  describe "#as_json" do
    it "only includes public information" do
      user.as_json.keys.should =~ public_attributes
    end
  end

  describe "#to_xml" do
    it "only includes public information" do
      Hash.from_xml(user.to_xml)["user"].keys.should =~ public_attributes
    end
  end

  describe "#ensure_last_active_is_set" do
    its(:last_active) { should be_kind_of(Time) }
  end

end
