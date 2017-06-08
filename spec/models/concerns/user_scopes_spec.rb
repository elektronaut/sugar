# encoding: utf-8

require "rails_helper"

describe UserScopes do
  # Create the first admin user
  let!(:first_user) { create(:banned_user) }

  describe "active" do
    let!(:banned) { create(:user, banned: true) }
    let!(:active) { create(:user) }
    subject { User.active }
    it { is_expected.to eq([active]) }
  end

  describe "by_username" do
    before { first_user.destroy }
    let!(:user1) { create(:user, username: "danz") }
    let!(:user2) { create(:user, username: "adam") }
    subject { User.by_username }
    it { is_expected.to eq([user2, user1]) }
  end

  describe "banned" do
    before { first_user.destroy }
    let!(:not_banned) { create(:user) }
    let!(:banned) { create(:user, banned: true) }
    let!(:temporarily_banned) do
      create(:user, banned_until: (Time.now.utc + 2.days))
    end
    subject { User.banned }
    it { is_expected.to match_array([banned, temporarily_banned]) }
  end

  describe "online" do
    let!(:online) { create(:user, last_active: 5.minutes.ago) }
    let!(:not_online) { create(:user, last_active: 20.minutes.ago) }
    subject { User.online }
    it { is_expected.to eq([online]) }
  end

  describe "admins" do
    let!(:user) { create(:user) }
    let!(:admin) { create(:admin) }
    let!(:moderator) { create(:moderator) }
    let!(:user_admin) { create(:user_admin) }
    subject { User.admins }
    it { is_expected.to match_array([admin, moderator, user_admin]) }
  end

  describe "social" do
    let!(:user) { create(:user) }
    let!(:twitter) { create(:admin, twitter: "elektronaut") }
    let!(:instagram) { create(:admin, instagram: "elektronaut") }
    let!(:flickr) { create(:admin, flickr: "elektronaut") }
    subject { User.social }
    it { is_expected.to match_array([twitter, instagram, flickr]) }
  end

  describe "gaming" do
    let!(:user) { create(:user) }
    let!(:gamertag) { create(:user, gamertag: "example") }
    let!(:sony) { create(:user, sony: "example") }
    let!(:nintendo) { create(:user, nintendo: "example") }
    let!(:nintendo_switch) { create(:user, nintendo_switch: "example") }
    let!(:steam) { create(:user, steam: "example") }
    let!(:battlenet) { create(:user, battlenet: 'example#1234') }

    it "should be a list of all gaming profiles" do
      expect(User.gaming).to match_array(
        [gamertag, sony, nintendo, nintendo_switch, steam, battlenet]
      )
    end
  end

  describe "recently_joined" do
    let!(:user1) { create(:user, created_at: 2.days.ago) }
    let!(:user2) { create(:user, created_at: 1.day.ago) }
    subject { User.recently_joined }
    it { is_expected.to eq([user2, user1]) }
  end

  describe "top_posters" do
    let!(:user1) { create(:user, public_posts_count: 1) }
    let!(:user2) { create(:user, public_posts_count: 2) }
    let!(:user3) { create(:user, public_posts_count: 0) }
    subject { User.top_posters }
    it { is_expected.to eq([user2, user1]) }
  end

  describe "trusted" do
    let!(:user) { create(:user) }
    let!(:trusted) { create(:trusted_user) }
    let!(:admin) { create(:admin) }
    let!(:moderator) { create(:moderator) }
    let!(:user_admin) { create(:user_admin) }
    subject { User.trusted }
    it { is_expected.to match_array([trusted, admin, moderator, user_admin]) }
  end
end
