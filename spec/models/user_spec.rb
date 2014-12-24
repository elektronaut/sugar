# encoding: utf-8

require 'spec_helper'

describe User do
  # Create the first admin user
  let!(:first_user) { create(:banned_user) }

  let(:user)         { create(:user) }
  let(:trusted_user) { create(:trusted_user) }
  let(:admin)        { create(:admin) }
  let(:moderator)    { create(:moderator) }
  let(:user_admin)   { create(:user_admin) }
  let(:public_attributes) { [
    "admin", "banned_until", "created_at", "description",
    "flickr", "gamertag", "gtalk", "id", "instagram", "facebook_uid",
    "inviter_id", "last_active", "last_fm", "latitude", "location", "longitude",
    "moderator", "msn", "realname", "twitter", "user_admin",
    "username", "website", "active", "banned", "sony"
  ] }

  subject { user }

  it { is_expected.to be_kind_of(Authenticable) }
  it { is_expected.to be_kind_of(Inviter) }
  it { is_expected.to be_kind_of(ExchangeParticipant) }
  it { is_expected.to be_kind_of(UserScopes) }

  it { is_expected.to belong_to(:avatar).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to validate_uniqueness_of(:username).case_insensitive.with_message(/is already registered/) }

  it { is_expected.to allow_value("Gustave Moíre").for(:username) }
  it { is_expected.to allow_value("فاطمة").for(:username) }
  it { is_expected.to allow_value("王秀英").for(:username) }
  it { is_expected.not_to allow_value("").for(:username) }
  it { is_expected.not_to allow_value("elektronaut?admin=1").for(:username) }

  it { is_expected.to validate_uniqueness_of(:email).case_insensitive.with_message(/is already registered/) }

  it { is_expected.to allow_value("test@example.com").for(:email) }
  it { is_expected.not_to allow_value("test.example.com").for(:email) }

  describe "validation" do
    context "when signed up with email" do
      it { is_expected.to validate_presence_of(:email) }
    end

    context "when signed up with Facebook" do
      subject { build(:user, email: nil, facebook_uid: 123) }
      it { is_expected.not_to validate_presence_of(:email) }
    end

    context "when signed up with OpenID" do
      subject { build(:user, email: nil, openid_url: "http://example.com/") }
      it { is_expected.not_to validate_presence_of(:email) }
    end
  end

  describe "#name_and_email" do
    subject { user.name_and_email }

    context "when realname is set" do
      let(:user) { create(:user, realname: 'John') }
      it { is_expected.to eq("#{user.realname} <#{user.email}>") }
    end

    context "when realname isn't set" do
      let(:user) { create(:user, realname: nil) }
      it { is_expected.to eq("#{user.email}") }
    end
  end

  describe "#previous_usernames" do
    subject { user.previous_usernames }
    let(:user) { create(:user, username: 'originalname') }

    context "when username hasn't been changed" do
      it { is_expected.to eq([]) }
    end

    context "when username changes" do
      before { user.update(username: 'newname') }
      it { is_expected.to eq(['originalname']) }
    end
  end

  describe "#realname_or_username" do
    subject { user.realname_or_username }

    context "when realname is set" do
      let(:user) { create(:user, realname: 'John') }
      it { is_expected.to eq(user.realname) }
    end

    context "when realname isn't set" do
      let(:user) { create(:user, realname: nil) }
      it { is_expected.to eq(user.username) }
    end
  end

  describe "#online?" do
    specify { expect(create(:user, last_active: 2.minutes.ago).online?).to eq(true) }
    specify { expect(create(:user, last_active: 2.days.ago).online?).to eq(false) }
  end

  describe "#trusted?" do
    specify { expect(trusted_user.trusted?).to eq(true) }
    specify { expect(moderator.trusted?).to eq(true) }
    specify { expect(user_admin.trusted?).to eq(true) }
    specify { expect(admin.trusted?).to eq(true) }
    specify { expect(user.trusted?).to eq(false) }
  end

  describe "#user_admin?" do
    specify { expect(user_admin.user_admin?).to eq(true) }
    specify { expect(admin.user_admin?).to eq(true) }
    specify { expect(moderator.user_admin?).to eq(false) }
  end

  describe "#moderator?" do
    specify { expect(moderator.moderator?).to eq(true) }
    specify { expect(admin.moderator?).to eq(true) }
    specify { expect(user_admin.moderator?).to eq(false) }
  end

  describe "#admin_labels" do
    specify { expect(admin.admin_labels).to eq(["Admin"]) }
    specify { expect(user_admin.admin_labels).to eq(["User Admin"]) }
    specify { expect(moderator.admin_labels).to eq(["Moderator"]) }
    specify { expect(create(:user, moderator: true, user_admin: true)
      .admin_labels).to eq(["User Admin", "Moderator"]) }
    specify { expect(user.admin_labels).to eq([]) }
  end

  describe "#theme" do
    before { Sugar.config.default_theme = "default" }
    specify { expect(user.theme).to eq("default") }
    specify { expect(create(:user, theme: "mytheme").theme).to eq("mytheme") }
  end

  describe "#mark_active!" do
    before { user.mark_active! }

    context "when user hasn't signed in yet" do
      let(:user) { create(:user, last_active: nil) }
      specify { expect(user.last_active).to be_within(1.0).of(Time.now) }
    end

    context "when user has been active" do
      let(:user) { create(:user, last_active: 2.days.ago) }
      specify { expect(user.last_active).to be_within(1.0).of(Time.now) }
    end

    context "when user has been active in the last 10 minutes" do
      let(:user) { create(:user, last_active: 5.minutes.ago) }
      specify { expect(user.last_active).to be_within(1.0).of(5.minutes.ago) }
    end
  end

  describe "#mobile_theme" do
    before { Sugar.config.default_mobile_theme = "default_mobile" }
    specify { expect(user.mobile_theme).to eq("default_mobile") }
    specify { expect(create(:user, mobile_theme: "mytheme_mobile").mobile_theme).to eq("mytheme_mobile") }
  end

  describe "#gamertag_avatar_url" do
    specify { expect(user.gamertag_avatar_url).to eq(nil) }
    specify { expect(create(:user, gamertag: 'my gamertag')
      .gamertag_avatar_url).to eq("http://avatar.xboxlive.com/avatar/my%20gamertag/avatarpic-l.png") }
  end

  describe "#as_json" do
    it "only includes public information" do
      expect(user.as_json.keys.map(&:to_s)).to match_array(public_attributes)
    end
  end

  describe "#to_xml" do
    it "only includes public information" do
      expect(Hash.from_xml(user.to_xml)["user"].keys).to match_array(public_attributes)
    end
  end

  describe "#ensure_last_active_is_set" do
    specify { expect(subject.last_active).to be_kind_of(Time) }
  end
end
