# encoding: utf-8

require "rails_helper"

describe User do
  let(:user) { build(:user) }
  let(:trusted_user) { build(:trusted_user) }
  let(:admin) { build(:admin) }
  let(:moderator) { build(:moderator) }
  let(:user_admin) { build(:user_admin) }
  let(:public_attributes) do
    %w(
      admin banned_until created_at description
      flickr gamertag gtalk id instagram facebook_uid
      inviter_id last_active last_fm latitude location
      longitude moderator msn realname twitter user_admin
      username website active banned
      sony nintendo nintendo_switch steam battlenet)
  end

  subject { user }

  it { is_expected.to be_kind_of(Authenticable) }
  it { is_expected.to be_kind_of(Inviter) }
  it { is_expected.to be_kind_of(ExchangeParticipant) }
  it { is_expected.to be_kind_of(UserScopes) }

  it { is_expected.to belong_to(:avatar).dependent(:destroy) }
  it { is_expected.to have_many(:exchange_moderators).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:username) }
  it do
    is_expected.to validate_uniqueness_of(:username)
      .case_insensitive.with_message(/is already registered/)
  end
  it { is_expected.to allow_value("Gustave Moíre").for(:username) }
  xit { is_expected.to allow_value("فاطمة").for(:username) }
  xit { is_expected.to allow_value("王秀英").for(:username) }
  it { is_expected.not_to allow_value("").for(:username) }
  it { is_expected.not_to allow_value("elektronaut?admin=1").for(:username) }
  it do
    is_expected.to validate_uniqueness_of(:email)
      .case_insensitive.with_message(/is already registered/)
  end
  it { is_expected.to allow_value("test@example.com").for(:email) }
  it { is_expected.not_to allow_value("test.example.com").for(:email) }
  it { is_expected.to validate_presence_of(:email) }

  describe "#name_and_email" do
    subject { user.name_and_email }

    context "when realname is set" do
      let(:user) { build(:user, realname: "John") }
      it { is_expected.to eq("#{user.realname} <#{user.email}>") }
    end

    context "when realname isn't set" do
      let(:user) { build(:user, realname: nil) }
      it { is_expected.to eq(user.email.to_s) }
    end
  end

  describe "#previous_usernames" do
    subject { user.previous_usernames }
    let(:user) { create(:user, username: "originalname") }

    context "when username hasn't been changed" do
      it { is_expected.to eq([]) }
    end

    context "when username changes" do
      before { user.update(username: "newname") }
      it { is_expected.to eq(["originalname"]) }
    end
  end

  describe "#realname_or_username" do
    subject { user.realname_or_username }

    context "when realname is set" do
      let(:user) { build(:user, realname: "John") }
      it { is_expected.to eq(user.realname) }
    end

    context "when realname isn't set" do
      let(:user) { build(:user, realname: nil) }
      it { is_expected.to eq(user.username) }
    end
  end

  describe "#online?" do
    subject { user.online? }

    context "when user is online" do
      let(:user) { build(:user, last_active: 2.minutes.ago) }
      it { is_expected.to eq(true) }
    end

    context "when user is offline" do
      let(:user) { build(:user, last_active: 2.days.ago) }
      it { is_expected.to eq(false) }
    end
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
    specify do
      expect(
        build(:user, moderator: true, user_admin: true).admin_labels
      ).to eq(["User Admin", "Moderator"])
    end
    specify { expect(user.admin_labels).to eq([]) }
  end

  describe "#theme" do
    before { Sugar.config.default_theme = "default" }
    specify { expect(user.theme).to eq("default") }
    specify { expect(create(:user, theme: "mytheme").theme).to eq("mytheme") }
  end

  describe "#mark_active!" do
    subject { user.last_active }
    before { user.mark_active! }

    context "when user hasn't signed in yet" do
      let(:user) { create(:user, last_active: nil) }
      it { is_expected.to be_within(1.0).of(Time.now.utc) }
    end

    context "when user has been active" do
      let(:user) { create(:user, last_active: 2.days.ago) }
      it { is_expected.to be_within(1.0).of(Time.now.utc) }
    end

    context "when user has been active in the last 10 minutes" do
      let(:user) { create(:user, last_active: 5.minutes.ago) }
      it { is_expected.to be_within(1.0).of(5.minutes.ago) }
    end
  end

  describe "#mobile_theme" do
    subject { user.mobile_theme }
    before { Sugar.config.default_mobile_theme = "default_mobile" }

    context "when not set" do
      it { is_expected.to eq("default_mobile") }
    end

    context "when set" do
      let(:user) { build(:user, mobile_theme: "mytheme_mobile") }
      it { is_expected.to eq("mytheme_mobile") }
    end
  end

  describe "#gamertag_avatar_url" do
    subject { user.gamertag_avatar_url }

    context "when gamertag is nil" do
      let(:user) { build(:user) }
      it { is_expected.to eq(nil) }
    end

    context "when gamertag is nil" do
      let(:user) { build(:user, gamertag: "my gamertag") }
      it do
        is_expected.to(
          eq("http://avatar.xboxlive.com/avatar/my%20gamertag/avatarpic-l.png")
        )
      end
    end
  end

  describe "#as_json" do
    let(:keys) { user.as_json.keys.map(&:to_s) }
    it "only includes public information" do
      expect(keys).to match_array(public_attributes)
    end
  end

  describe "#to_xml" do
    let(:keys) { Hash.from_xml(user.to_xml)["user"].keys }
    it "only includes public information" do
      expect(keys).to match_array(public_attributes)
    end
  end

  describe "#ensure_last_active_is_set" do
    subject { create(:user).last_active }
    it { is_expected.to be_kind_of(Time) }
  end
end
