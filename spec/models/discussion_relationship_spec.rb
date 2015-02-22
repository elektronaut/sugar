require "spec_helper"

describe DiscussionRelationship do

  let(:relationship)       { create(:discussion_relationship) }
  let(:discussion)         { create(:discussion) }
  let(:trusted_discussion) { create(:trusted_discussion) }
  let(:user)               { create(:user) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:discussion) }

  specify { expect(subject.favorite?).to eq(false) }
  specify { expect(subject.following?).to eq(true) }
  specify { expect(subject.participated?).to eq(false) }

  describe ".define" do

    context "when the discussion is trusted" do
      subject { DiscussionRelationship.define(user, trusted_discussion) }
      specify { expect(subject.trusted?).to eq(true) }
    end

    context "when the discussion isn't trusted" do
      subject { DiscussionRelationship.define(user, discussion) }
      specify { expect(subject.trusted?).to eq(false) }
    end

    context "with no existing relationship" do

      let(:relationship) do
        DiscussionRelationship.define(user, discussion, favorite: true)
      end

      specify { expect(relationship.valid?).to eq(true) }
      specify { expect(relationship.favorite?).to eq(true) }
      specify { expect(relationship.user.discussion_relationships).to include(relationship) }

      it "creates a new record" do
        discussion # Creating a discussion also creates a separate relationship,
        # so this needs to happen first.
        expect { relationship }.to change { DiscussionRelationship.count }.by(1)
      end

    end

    context "with an existing relationship" do

      let(:existing) { create(:discussion_relationship) }

      let(:relationship) do
        DiscussionRelationship.define(existing.user, existing.discussion, favorite: true)
      end

      specify { expect(relationship.valid?).to eq(true) }
      specify { expect(relationship.favorite?).to eq(true) }

      it "doesn't create a new record" do
        existing
        expect { relationship }.not_to change { DiscussionRelationship.count }
      end

    end

  end

  describe "#update_user_caches!" do

    it "updates caches when created" do
      expect do
        create(:discussion_relationship, user: user, favorite: true)
      end.to change { user.favorites_count }.by(1)
    end

    it "updates caches when updated" do
      expect do
        relationship.update_attributes(favorite: true)
      end.to change { relationship.user.favorites_count }.by(1)
    end

    it "updates caches when destroyed" do
      expect do
        relationship.destroy
      end.to change { relationship.user.following_count }.by(-1)
    end

  end

end
