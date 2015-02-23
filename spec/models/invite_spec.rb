require "spec_helper"

describe Invite do
  subject(:invite) { build(:invite) }

  # Create the first admin user
  before { create(:user) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:user_id) }

  describe "email validation" do
    subject { build(:invite, email: email) }

    context "when not registered" do
      let(:email) { "test@example.com" }
      it { is_expected.to be_valid }
    end

    context "when already registered" do
      before { subject.valid? }
      let(:email) { create(:user).email }
      it { is_expected.to_not be_valid }
      specify { expect(subject.errors[:email].length).to eq(1) }
    end

    context "when already invited" do
      before { subject.valid? }
      let(:email) { create(:invite).email }
      it { is_expected.to_not be_valid }
      specify { expect(subject.errors[:email].length).to eq(1) }
    end
  end

  describe "before_create" do
    subject { create(:invite) }

    specify do
      expect(subject.expires_at).to be_within(30).of(Time.now + 14.days)
    end

    specify { expect(subject.token).to be_kind_of(String) }
    specify { expect(subject.token.length >= 40).to eq(true) }

    it "revokes an invite from the inviter" do
      inviter = create(:user, available_invites: 1)
      expect do
        create(:invite, user: inviter)
      end.to change { inviter.available_invites }.by(-1)
    end
  end

  describe "before_destroy" do
    context "when invite has been used" do
      before { invite.used = true }
      it "doesn't grant the user an invite" do
        expect do
          invite.destroy
        end.not_to change { invite.user.available_invites }
      end
    end

    context "when invite hasn't been used" do
      it "grants the inviter back an invite" do
        expect do
          invite.destroy
        end.to change { invite.user.available_invites }.by(1)
      end
    end
  end

  describe ".unique_token" do
    subject { Invite.unique_token }
    it { is_expected.to be_kind_of(String) }
    specify { expect(subject.length >= 40).to eq(true) }
  end

  describe ".expiration_time" do
    subject { Invite.expiration_time }
    it { is_expected.to eq(14.days) }
  end

  describe ".active" do
    let!(:invite) { create(:invite) }
    let!(:expired_invite) { create(:expired_invite) }

    subject { Invite.active }
    it { is_expected.to eq([invite]) }
  end

  describe ".expired" do
    let!(:invite) { create(:invite) }
    let!(:expired_invite) { create(:expired_invite) }

    subject { Invite.expired }
    it { is_expected.to eq([expired_invite]) }
  end

  describe ".destroy_expired!" do
    let!(:expired_invite) { create(:expired_invite) }

    it "destroys all expired invites" do
      expect do
        Invite.destroy_expired!
      end.to change { Invite.count }.by(-1)
    end
  end

  describe "#expired?" do
    subject { invite.expired? }

    context "when invite isn't expired" do
      let(:invite) { create(:invite) }
      it { is_expected.to eq(false) }
    end

    context "when invite is expired" do
      let(:invite) { create(:expired_invite) }
      it { is_expected.to eq(true) }
    end
  end

  describe "#expire!" do
    let!(:invite) { create(:expired_invite) }
    it "destroys the invite" do
      expect { Invite.destroy_expired! }.to change { Invite.count }.by(-1)
    end
  end
end
