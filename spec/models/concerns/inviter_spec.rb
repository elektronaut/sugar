# encoding: utf-8

require 'spec_helper'

describe Inviter do

  # Create the first admin user
  before { create(:admin) }

  let(:user) { create(:user) }

  subject { user }

  it { is_expected.to belong_to(:inviter).class_name('User') }
  it { is_expected.to have_many(:invitees).class_name('User') }
  it { is_expected.to have_many(:invites).dependent(:destroy) }

  describe "active scope on invites" do
    it "returns only the user's active invites" do
      active_invite = create(:invite, user: user)
      expired_invite = create(:invite, user: user, expires_at: 2.days.ago)
      other_invite = create(:invite)
      expect(user.invites.active).to match_array([active_invite])
    end
  end

  describe "#invites?" do

    subject { user.invites? }

    context "when user has no invites" do
      it { is_expected.to eq(false) }
    end

    context "when user has invites" do
      before { create(:invite, user: user) }
      it { is_expected.to eq(true) }
    end

  end

  describe "#invitees?" do

    subject { user.invitees? }

    context "when user has no invitees" do
      it { is_expected.to eq(false) }
    end

    context "when user has invitees" do
      before { create(:user, inviter: user) }
      it { is_expected.to eq(true) }
    end

  end

  describe "#invites_or_invitees?" do

    subject { user.invites_or_invitees? }

    context "when user has none" do
      it { is_expected.to eq(false) }
    end

    context "when user has invites" do
      before { create(:invite, user: user) }
      it { is_expected.to eq(true) }
    end

    context "when user has invitees" do
      before { create(:user, inviter: user) }
      it { is_expected.to eq(true) }
    end

  end

  describe "#available_invites?" do
    specify { expect(create(:user).available_invites?).to eq(false) }
    specify { expect(create(:user_admin).available_invites?).to eq(true) }
    specify { expect(create(:user, available_invites: 2).available_invites?).to eq(true) }
  end

  describe "#available_invites" do
    specify { expect(create(:user).available_invites).to eq(0) }
    specify { expect(create(:user, available_invites: 2).available_invites).to eq(2) }
    specify { expect(create(:user_admin).available_invites).to eq(1) }
    specify { expect(create(:user_admin, available_invites: 99).available_invites).to eq(1) }
  end

  describe "#revoke_invite!" do

    subject { user.revoke_invite! }

    context "when user is user admin" do
      let(:user) { create(:user_admin) }
      it "does not revoke any invites" do
        user.revoke_invite!(:all)
        expect(user.available_invites?).to eq(true)
      end
    end

    context "when user has no invites" do
      it "does not revoke any invites" do
        user.revoke_invite!
        expect(user.available_invites).to eq(0)
      end
    end

    context "when user has invites" do
      let(:user) { create(:user, available_invites: 3) }
      it "revokes one invite" do
        user.revoke_invite!
        expect(user.available_invites).to eq(2)
      end

      describe "revoking two invites" do
        it "revokes one invite" do
          user.revoke_invite!(2)
          expect(user.available_invites).to eq(1)
        end
      end

      describe "revoking all invites" do
        it "revokes one invite" do
          user.revoke_invite!(:all)
          expect(user.available_invites).to eq(0)
        end
      end

    end

  end

  describe "#grant_invite!" do

    let(:user) { create(:user, available_invites: 1) }

    it "grants an invite to the user" do
      user.grant_invite!
      expect(user.available_invites).to eq(2)
    end

    it "grants an invite to the user" do
      user.grant_invite!(2)
      expect(user.available_invites).to eq(3)
    end

    context "when user is user admin" do

      let(:user) { create(:user_admin, available_invites: 10) }

      it "does not grant any invites" do
        user.grant_invite!(10)
        expect(user.available_invites).to eq(1)
      end

    end

  end

end
