require 'spec_helper'

describe Invite do

  let(:invite)         { create(:invite) }
  let(:expired_invite) { create(:invite, expires_at: 2.days.ago) }
  let(:user)           { create(:user) }

  it { should belong_to(:user) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:user_id) }

  describe "email validation" do

    context "when already registered" do
      subject { build(:invite, email: user.email) }
      it { should_not be_valid }
      it { should have(1).errors_on(:email) }
    end

    context "when already invited" do
      subject { build(:invite, email: invite.email) }
      it { should_not be_valid }
      it { should have(1).errors_on(:email) }
    end

  end

  describe "before_create" do

    subject { invite }
    its(:expires_at) { should be_within(30).of(Time.now + 14.days) }
    its(:token) { should be_kind_of(String) }
    its("token.length") { should >= 40 }

    it "revokes an invite from the inviter" do
      inviter = create(:user, :available_invites => 1)
      expect {
        create(:invite, :user => inviter)
      }.to change{inviter.available_invites}.by(-1)
    end

  end

  describe "before_destroy" do

    context "when invite has been used" do
      before { invite.used = true }
      it "doesn't grant the user an invite" do
        expect {
          invite.destroy
        }.not_to change{ invite.user.available_invites }
      end
    end

    context "when invite hasn't been used" do
      it "grants the inviter back an invite" do
        expect {
          invite.destroy
        }.to change{ invite.user.available_invites }.by(1)
      end
    end
  end

  describe ".unique_token" do
    subject { Invite.unique_token }
    it { should be_kind_of(String) }
    its(:length) { should >= 40 }
  end

  describe ".expiration_time" do
    subject { Invite.expiration_time }
    it { should == 14.days }
  end

  describe ".find_active" do

    before do
      invite
      expired_invite
    end

    subject { Invite.find_active }
    it { should == [invite] }

  end

  describe ".find_expired" do

    before do
      invite
      expired_invite
    end

    subject { Invite.find_expired }
    it { should == [expired_invite] }

  end

  describe ".destroy_expired!" do

    before do
      invite
      expired_invite
    end

    it "destroys all expired invites" do
      expect {
        Invite.destroy_expired!
      }.to change{ Invite.count }.by(-1)
    end

  end

  describe "#expired?" do
    specify { invite.expired?.should be_false }
    specify { expired_invite.expired?.should be_true }
  end

  describe "#expire!" do
    before { expired_invite }
    it "destroys the invite" do
      expect { Invite.destroy_expired! }.to change{Invite.count}.by(-1)
    end
  end

end
