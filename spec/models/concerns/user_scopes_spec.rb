# frozen_string_literal: true

require "rails_helper"

describe UserScopes do
  # Create the first admin user
  let!(:first_user) { create(:banned_user) }

  describe "active" do
    subject { User.active }

    let!(:active) { create(:user) }

    before { create(:banned_user) }

    it { is_expected.to eq([active]) }
  end

  describe "by_username" do
    before { first_user.destroy }
    subject { User.by_username }

    let!(:user1) { create(:user, username: "danz") }
    let!(:user2) { create(:user, username: "adam") }

    it { is_expected.to eq([user2, user1]) }
  end

  describe "deactivated" do
    subject { User.deactivated }

    before do
      first_user.destroy
      create(:user)
    end

    let!(:banned) { create(:banned_user) }
    let!(:hiatus) do
      create(:user, banned_until: (Time.now.utc + 2.days), status: :hiatus)
    end

    it { is_expected.to match_array([banned, hiatus]) }
  end

  describe "online" do
    subject { User.online }

    let!(:online) { create(:user, last_active: 5.minutes.ago) }

    before { create(:user, last_active: 20.minutes.ago) }

    it { is_expected.to eq([online]) }
  end

  describe "admins" do
    subject { User.admins }

    let!(:admin) { create(:admin) }
    let!(:moderator) { create(:moderator) }
    let!(:user_admin) { create(:user_admin) }

    before { create(:user) }

    it { is_expected.to match_array([admin, moderator, user_admin]) }
  end

  describe "social" do
    subject { User.social }

    let!(:twitter) { create(:admin, twitter: "elektronaut") }
    let!(:instagram) { create(:admin, instagram: "elektronaut") }
    let!(:flickr) { create(:admin, flickr: "elektronaut") }

    before { create(:user) }

    it { is_expected.to match_array([twitter, instagram, flickr]) }
  end

  describe "gaming" do
    let!(:gamertag) { create(:user, gamertag: "example") }
    let!(:sony) { create(:user, sony: "example") }
    let!(:nintendo) { create(:user, nintendo: "example") }
    let!(:nintendo_switch) { create(:user, nintendo_switch: "example") }
    let!(:steam) { create(:user, steam: "example") }
    let!(:battlenet) { create(:user, battlenet: "example#1234") }

    before { create(:user) }

    it "is a list of all gaming profiles" do
      expect(User.gaming).to match_array(
        [gamertag, sony, nintendo, nintendo_switch, steam, battlenet]
      )
    end
  end

  describe "recently_joined" do
    subject { User.recently_joined }

    let!(:user1) { create(:user, created_at: 2.days.ago) }
    let!(:user2) { create(:user, created_at: 1.day.ago) }

    it { is_expected.to eq([user2, user1]) }
  end

  describe "top_posters" do
    subject { User.top_posters }

    let!(:user1) { create(:user, public_posts_count: 1) }
    let!(:user2) { create(:user, public_posts_count: 2) }

    before { create(:user, public_posts_count: 0) }

    it { is_expected.to eq([user2, user1]) }
  end

  describe "trusted" do
    subject { User.trusted }

    let!(:trusted) { create(:trusted_user) }
    let!(:admin) { create(:admin) }
    let!(:moderator) { create(:moderator) }
    let!(:user_admin) { create(:user_admin) }

    before { create(:user) }

    it { is_expected.to match_array([trusted, admin, moderator, user_admin]) }
  end
end
