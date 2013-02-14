require 'spec_helper'

describe DiscussionRelationship do

  let(:relationship)       { create(:discussion_relationship) }
  let(:discussion)         { create(:discussion) }
  let(:trusted_discussion) { create(:trusted_discussion) }
  let(:user)               { create(:user) }

  it { should belong_to(:user) }
  it { should belong_to(:discussion) }

  its(:favorite?) { should be_false }
  its(:following?) { should be_true }
  its(:participated?) { should be_false }


  describe ".define" do

    context "when the discussion is trusted" do
      subject { DiscussionRelationship.define(user, trusted_discussion) }
      its(:trusted?) { should be_true }
    end

    context "when the discussion isn't trusted" do
      subject { DiscussionRelationship.define(user, discussion) }
      its(:trusted?) { should be_false }
    end

    context "with no existing relationship" do

      let(:relationship) do
        DiscussionRelationship.define(user, discussion, favorite: true)
      end

      specify { relationship.valid?.should be_true }
      specify { relationship.favorite?.should be_true }
      specify { relationship.user.discussion_relationships.should include(relationship) }

      it "creates a new record" do
        discussion # Creating a discussion also creates a separate relationship,
                   # so this needs to happen first.
        expect { relationship }.to change{ DiscussionRelationship.count }.by(1)
      end

    end

    context "with an existing relationship" do

      let(:existing) { create(:discussion_relationship) }

      let(:relationship) do
        DiscussionRelationship.define(existing.user, existing.discussion, favorite: true)
      end

      specify { relationship.valid?.should be_true }
      specify { relationship.favorite?.should be_true }

      it "doesn't create a new record" do
        existing
        expect { relationship }.not_to change{ DiscussionRelationship.count }
      end

    end

  end

  describe "#update_user_caches!" do

    it "updates caches when created" do
      expect {
        create(:discussion_relationship, user: user, favorite: true)
      }.to change{ user.favorites_count }.by(1)
    end

    it "updates caches when updated" do
      expect {
        relationship.update_attributes(favorite: true)
      }.to change{ relationship.user.favorites_count }.by(1)
    end

    it "updates caches when destroyed" do
      expect {
        relationship.destroy
      }.to change{ relationship.user.following_count }.by(-1)
    end

  end

end