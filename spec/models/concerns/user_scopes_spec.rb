# encoding: utf-8

require 'spec_helper'

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
    let!(:user1) { create(:user, username: 'danz') }
    let!(:user2) { create(:user, username: 'adam') }
    subject { User.by_username }
    it { is_expected.to eq([user2, user1]) }
  end

  describe "banned" do
    before { first_user.destroy }
    let!(:not_banned) { create(:user) }
    let!(:banned) { create(:user, banned: true) }
    let!(:temporarily_banned) { create(:user, banned_until: (Time.now + 2.days)) }
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

  describe "xbox_users" do
    let!(:xbox_user) { create(:user, gamertag: 'example') }
    let!(:non_xbox_user) { create(:user, gamertag: nil) }
    subject { User.xbox_users }
    it { is_expected.to eq([xbox_user]) }
  end

  describe "sony_users" do
    let!(:sony_user) { create(:user, sony: 'example') }
    let!(:non_sony_user) { create(:user, sony: nil) }
    subject { User.sony_users }
    it { is_expected.to eq([sony_user]) }
  end

  describe "nintendo_users" do
    let!(:nintendo_user) { create(:user, nintendo: 'example') }
    let!(:non_nintendo_user) { create(:user, nintendo: nil) }
    subject { User.nintendo_users }
    it { is_expected.to eq([nintendo_user]) }
  end

  describe "steam_users" do
    let!(:steam_user) { create(:user, steam: 'example') }
    let!(:non_steam_user) { create(:user, steam: nil) }
    subject { User.steam_users }
    it { is_expected.to eq([steam_user]) }
  end
  
  describe "social" do
    let!(:user) { create(:user) }
    let!(:twitter) { create(:admin, twitter: 'elektronaut') }
    let!(:instagram) { create(:admin, instagram: 'elektronaut') }
    let!(:flickr) { create(:admin, flickr: 'elektronaut') }
    subject { User.social }
    it { is_expected.to match_array([twitter, instagram, flickr]) }
  end

  describe "recently_joined" do
    let!(:user1) { create(:user, created_at: 2.days.ago) }
    let!(:user2) { create(:user, created_at: 1.days.ago) }
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
