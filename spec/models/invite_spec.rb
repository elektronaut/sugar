require 'spec_helper'

describe Invite do
  subject(:invite) { build(:invite) }

  # Create the first admin user
  before { create(:user) }

  it { should belong_to(:user) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:user_id) }

  describe "email validation" do
    subject { build(:invite, email: email) }

    context "when not registered" do
      let(:email) { 'test@example.com' }
      it { should be_valid }
    end

    context "when already registered" do
      let(:email) { create(:user).email }
      it { should_not be_valid }
      it { should have(1).errors_on(:email) }
    end

    context "when already invited" do
      let(:email) { create(:invite).email }
      it { should_not be_valid }
      it { should have(1).errors_on(:email) }
    end
  end

  describe "before_create" do
    subject { create(:invite) }

    its(:expires_at) { should be_within(30).of(Time.now + 14.days) }
    its(:token) { should be_kind_of(String) }
    its("token.length") { should >= 40 }

    it "revokes an invite from the inviter" do
      inviter = create(:user, available_invites: 1)
      expect {
        create(:invite, user: inviter)
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

  describe ".active" do
    let!(:invite) { create(:invite) }
    let!(:expired_invite) { create(:expired_invite) }

    subject { Invite.active }
    it { should == [invite] }
  end

  describe ".expired" do
    let!(:invite) { create(:invite) }
    let!(:expired_invite) { create(:expired_invite) }

    subject { Invite.expired }
    it { should == [expired_invite] }
  end

  describe ".destroy_expired!" do
    let!(:expired_invite) { create(:expired_invite) }

    it "destroys all expired invites" do
      expect {
        Invite.destroy_expired!
      }.to change{ Invite.count }.by(-1)
    end

  end

  describe "#expired?" do
    subject { invite.expired? }

    context "when invite isn't expired" do
      let(:invite) { create(:invite) }
      it { should be_false }
    end

    context "when invite is expired" do
      let(:invite) { create(:expired_invite) }
      it { should be_true }
    end
  end

  describe "#expire!" do
    let!(:invite) { create(:expired_invite) }
    it "destroys the invite" do
      expect { Invite.destroy_expired! }.to change{Invite.count}.by(-1)
    end
  end

end
