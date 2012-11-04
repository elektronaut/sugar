# encoding: utf-8

require 'spec_helper'

describe Inviter do

  let(:user) { create(:user) }

  subject { user }

  it { should belong_to(:inviter).class_name('User') }
  it { should have_many(:invitees).class_name('User') }
  it { should have_many(:invites).dependent(:destroy) }

  describe "active scope on invites" do
    it "returns only the user's active invites" do
      active_invite = create(:invite, user: user)
      expired_invite = create(:invite, user: user, expires_at: 2.days.ago)
      other_invite = create(:invite)
      user.invites.active.should == [active_invite]
    end
  end

  describe "#invites?" do

    subject { user.invites? }

    context "when user has no invites" do
      it { should be_false }
    end

    context "when user has invites" do
      before { create(:invite, user: user) }
      it { should be_true }
    end

  end

  describe "#invitees?" do

    subject { user.invitees? }

    context "when user has no invitees" do
      it { should be_false }
    end

    context "when user has invitees" do
      before { create(:user, inviter: user) }
      it { should be_true }
    end

  end

  describe "#invites_or_invitees?" do

    subject { user.invites_or_invitees? }

    context "when user has none" do
      it { should be_false }
    end

    context "when user has invites" do
      before { create(:invite, user: user) }
      it { should be_true }
    end

    context "when user has invitees" do
      before { create(:user, inviter: user) }
      it { should be_true }
    end

  end

  describe "#available_invites?" do
    specify { create(:user).available_invites?.should be_false }
    specify { create(:user_admin).available_invites?.should be_true }
    specify { create(:user, available_invites: 2).available_invites?.should be_true }
  end

  describe "#available_invites" do
    specify { create(:user).available_invites.should == 0 }
    specify { create(:user, available_invites: 2).available_invites.should == 2 }
    specify { create(:user_admin).available_invites.should == 1 }
    specify { create(:user_admin, available_invites: 99).available_invites.should == 1 }
  end

  describe "#revoke_invite!" do

    subject { user.revoke_invite! }

    context "when user is user admin" do
      let(:user) { create(:user_admin) }
      it "does not revoke any invites" do
        user.revoke_invite!(:all)
        user.available_invites?.should be_true
      end
    end

    context "when user has no invites" do
      it "does not revoke any invites" do
        user.revoke_invite!
        user.available_invites.should == 0
      end
    end

    context "when user has invites" do
      let(:user) { create(:user, available_invites: 3) }
      it "revokes one invite" do
        user.revoke_invite!
        user.available_invites.should == 2
      end

      describe "revoking two invites" do
        it "revokes one invite" do
          user.revoke_invite!(2)
          user.available_invites.should == 1
        end
      end

      describe "revoking all invites" do
        it "revokes one invite" do
          user.revoke_invite!(:all)
          user.available_invites.should == 0
        end
      end

    end

  end

  describe "#grant_invite!" do

    let(:user) { create(:user, available_invites: 1) }

    it "grants an invite to the user" do
      user.grant_invite!
      user.available_invites.should == 2
    end

    it "grants an invite to the user" do
      user.grant_invite!(2)
      user.available_invites.should == 3
    end

    context "when user is user admin" do

      let(:user) { create(:user_admin, available_invites: 10) }

      it "does not grant any invites" do
        user.grant_invite!(10)
        user.available_invites.should == 1
      end

    end

  end

end