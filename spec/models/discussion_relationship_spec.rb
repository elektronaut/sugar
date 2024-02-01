# frozen_string_literal: true

require "rails_helper"

describe DiscussionRelationship do
  let(:relationship)       { create(:discussion_relationship) }
  let(:discussion)         { create(:discussion) }
  let(:user)               { create(:user) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:discussion) }

  # Default values
  specify { expect(relationship.favorite?).to be(false) }
  specify { expect(relationship.following?).to be(true) }
  specify { expect(relationship.participated?).to be(false) }

  describe "mutual exclusive flags" do
    context "when a discussion is being hidden" do
      let(:relationship) do
        create(:discussion_relationship, following: true, favorite: true)
      end

      before { relationship.update(hidden: true) }

      it "unsets following" do
        expect(relationship.following?).to be(false)
      end

      it "unsets favorite" do
        expect(relationship.favorite?).to be(false)
      end
    end

    context "when following a hidden discussion" do
      subject { relationship.hidden? }

      let(:relationship) { create(:discussion_relationship, hidden: true) }

      before { relationship.update(following: true) }

      it { is_expected.to be(false) }
    end

    context "when favoriting a hidden discussion" do
      subject { relationship.hidden? }

      let(:relationship) { create(:discussion_relationship, hidden: true) }

      before { relationship.update(favorite: true) }

      it { is_expected.to be(false) }
    end
  end

  describe ".define" do
    context "with no existing relationship" do
      let(:relationship) do
        described_class.define(user, discussion, favorite: true)
      end

      specify { expect(relationship.valid?).to be(true) }
      specify { expect(relationship.favorite?).to be(true) }

      specify do
        expect(
          relationship.user.discussion_relationships
        ).to include(relationship)
      end

      it "creates a new record" do
        # Creating a discussion also creates a separate relationship,
        # so this needs to happen first.
        discussion
        expect { relationship }.to change(described_class, :count).by(1)
      end
    end

    context "with an existing relationship" do
      let(:existing) { create(:discussion_relationship) }

      let(:relationship) do
        described_class.define(
          existing.user, existing.discussion, favorite: true
        )
      end

      specify { expect(relationship.valid?).to be(true) }
      specify { expect(relationship.favorite?).to be(true) }

      it "doesn't create a new record" do
        existing
        expect { relationship }.not_to(change(described_class, :count))
      end
    end
  end

  describe "#update_user_caches!" do
    it "updates caches when created" do
      expect do
        create(:discussion_relationship, user:, favorite: true)
      end.to change(user, :favorites_count).by(1)
    end

    it "updates caches when updated" do
      expect do
        relationship.update(favorite: true)
      end.to change { relationship.user.favorites_count }.by(1)
    end

    it "updates caches when destroyed" do
      expect do
        relationship.destroy
      end.to change { relationship.user.following_count }.by(-1)
    end
  end
end
