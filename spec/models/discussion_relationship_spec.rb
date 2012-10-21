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

  describe ".find_participated" do
    let(:participated_discussion) { create(:discussion) }
    before { DiscussionRelationship.define(user, participated_discussion, participated: true) }
    subject { DiscussionRelationship.find_participated(user) }
    it { should include(participated_discussion) }
    it { should_not include(discussion) }
  end

  describe ".find_following" do
    let(:followed_discussion) { create(:discussion) }
    before { DiscussionRelationship.define(user, followed_discussion, following: true) }
    subject { DiscussionRelationship.find_following(user) }
    it { should include(followed_discussion) }
    it { should_not include(discussion) }
  end

  describe ".find_favorite" do
    let(:favorite_discussion) { create(:discussion) }
    before { DiscussionRelationship.define(user, favorite_discussion, favorite: true) }
    subject { DiscussionRelationship.find_favorite(user) }
    it { should include(favorite_discussion) }
    it { should_not include(discussion) }
  end

  describe ".find_discussions" do

    subject { DiscussionRelationship.find_discussions(relationship.user) }

    context "with options" do

      describe :page do

        context "not specified" do
          it { should_not be_kind_of(Pagination::InstanceMethods) }
        end

        context "specified" do
          subject { DiscussionRelationship.find_discussions(relationship.user, page: 1) }
          it { should be_kind_of(Pagination::InstanceMethods) }
          its(:page) { should == 1 }
        end

      end

      describe :trusted do

        before { DiscussionRelationship.define(user, trusted_discussion) }

        context "when not specified" do
          subject { DiscussionRelationship.find_discussions(user, following: true) }
          it { should_not include(trusted_discussion) }
        end

        context "when true" do
          subject { DiscussionRelationship.find_discussions(user, following: true, trusted: true) }
          it { should include(trusted_discussion) }
        end

        context "when false" do
          subject { DiscussionRelationship.find_discussions(user, following: true, trusted: false) }
          it { should_not include(trusted_discussion) }
        end

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