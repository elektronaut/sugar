# frozen_string_literal: true

require "rails_helper"

describe Invite do
  subject(:invite) { build(:invite) }

  # Create the first admin user
  before { create(:user) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:email) }

  describe "email validation" do
    subject(:invite) { build(:invite, email:, user: User.first) }

    let(:email_errors) { invite.errors[:email] }

    before { invite.valid? }

    context "when not registered" do
      let(:email) { "test@example.com" }

      it { is_expected.to be_valid }
    end

    context "when already registered" do
      let(:email) { create(:user).email }

      it { is_expected.not_to be_valid }
      specify { expect(email_errors).to include("has already been invited") }
    end

    context "when already invited" do
      let(:email) { create(:invite).email }

      it { is_expected.not_to be_valid }
      specify { expect(email_errors).to include("has already been invited") }
    end
  end

  describe "before_create" do
    subject(:invite) { create(:invite) }

    specify do
      expect(invite.expires_at).to be_within(30).of(Time.now.utc + 14.days)
    end

    specify { expect(invite.token).to be_a(String) }
    specify { expect(invite.token.length >= 40).to be(true) }

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
        expect { invite.destroy }
          .not_to(change { invite.user.available_invites })
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
    subject(:token) { described_class.unique_token }

    it { is_expected.to be_a(String) }
    specify { expect(token.length >= 40).to be(true) }
  end

  describe ".expiration_time" do
    subject { described_class.expiration_time }

    it { is_expected.to eq(14.days) }
  end

  describe ".active" do
    subject { described_class.active }

    let!(:invite) { create(:invite) }

    before { create(:invite, :expired) }

    it { is_expected.to eq([invite]) }
  end

  describe ".destroy_expired!" do
    before { create(:invite, :expired) }

    it "destroys all expired invites" do
      expect do
        described_class.destroy_expired!
      end.to change(described_class, :count).by(-1)
    end
  end

  describe "#expired?" do
    subject { invite.expired? }

    context "when invite isn't expired" do
      let(:invite) { create(:invite) }

      it { is_expected.to be(false) }
    end

    context "when invite is expired" do
      let(:invite) { create(:invite, :expired) }

      it { is_expected.to be(true) }
    end
  end

  describe "#expire!" do
    before { create(:invite, :expired) }

    it "destroys the invite" do
      expect { described_class.destroy_expired! }.to(
        change(described_class, :count).by(-1)
      )
    end
  end
end
