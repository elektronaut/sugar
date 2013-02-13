# encoding: utf-8

require 'spec_helper'

describe ExchangeParticipant do

  let(:user)       { create(:user) }
  let(:discussion) { create(:discussion) }

  subject { user }

  it { should have_many(:discussions) }
  it { should have_many(:posts) }
  it { should have_many(:discussion_posts).class_name('Post') }
  it { should have_many(:discussion_views).dependent(:destroy) }
  it { should have_many(:discussion_relationships).dependent(:destroy) }
  it { should have_many(:conversation_relationships).dependent(:destroy) }
  it { should have_many(:conversations).through(:conversation_relationships) }

  describe "#participated_discussions" do
    it "delegates to DiscussionRelationship" do
      DiscussionRelationship.should_receive(:find_participated) do |u, opt|
        u.should == user
        opt.should == {abc: 123}
      end
      user.participated_discussions(abc: 123)
    end
  end

  describe "#following_discussions" do
    it "delegates to DiscussionRelationship" do
      DiscussionRelationship.should_receive(:find_following) do |u, opt|
        u.should == user
        opt.should == {abc: 123}
      end
      user.following_discussions(abc: 123)
    end
  end

  describe "#favorite_discussions" do
    it "delegates to DiscussionRelationship" do
      DiscussionRelationship.should_receive(:find_favorite) do |u, opt|
        u.should == user
        opt.should == {abc: 123}
      end
      user.favorite_discussions(abc: 123)
    end
  end

  describe "#mark_discussion_viewed" do
    let(:post) { create(:post, discussion: discussion) }

    context "with existing discussion view" do
      let!(:discussion_view) { create(:discussion_view, user: user, discussion: discussion) }

      it "does not create a new view" do
        expect {
          user.mark_discussion_viewed(discussion, post, 2)
        }.to change{ DiscussionView.count }.by(0)
      end

      describe "the new view" do
        before do
          user.mark_discussion_viewed(discussion, post, 2)
          discussion_view.reload
        end

        subject { discussion_view }
        its(:post_index) { should == 2 }
        its(:post) { should == post }
      end

    end

    context "without existing discussion view" do
      it "creates a new view" do
        expect {
          user.mark_discussion_viewed(discussion, post, 2)
        }.to change{ DiscussionView.count }.by(1)
      end

      describe "the new discussion view" do
        before { user.mark_discussion_viewed(discussion, post, 2) }
        subject { user.discussion_views.last }
        its(:post_index) { should == 2 }
        its(:post) { should == post }
      end
    end

  end

  describe "#paginated_conversations" do

    subject { user.paginated_conversations }
    it { should be_kind_of Pagination::InstanceMethods }

    it "only finds the user's conversations" do
      conversation = create(:conversation, poster: user)
      other_conversation = create(:conversation)
      subject.should == [conversation]
    end

    context "with options" do

      describe :limit do

        context "when not specified" do
          its(:per_page) { should == Exchange.per_page }
        end

        context "when specified" do
          subject { user.paginated_conversations(limit: 7) }
          its(:per_page) { should == 7 }
        end

      end

      describe :page do

        before do
          2.times { create(:conversation, poster: user) }
        end

        context "when not specified" do
          subject { user.paginated_conversations(limit: 1) }
          its(:page) { should == 1 }
        end

        context "when specified" do
          subject { user.paginated_conversations(limit: 1, page: 2) }
          its(:page) { should == 2 }
        end

        context "when out of bounds" do
          subject { user.paginated_conversations(limit: 1, page: 3) }
          its(:page) { should == 2 }
        end

      end

    end
  end

  describe "#posts_per_day" do

    let(:user) { create(:user, :created_at => 3.days.ago) }

    before do
      create(:post, user: user)
      user.reload
    end

    subject { user.posts_per_day }

    it { should be_within(0.001).of(1.0/3.0) }
  end

  describe "#unread_conversations_count" do

    subject { user.unread_conversations_count }

    context "with no conversations" do
      it { should == 0 }
    end

    context "when notifications is set to false" do
      before { create(:conversation_relationship, user: user, new_posts: true, notifications: false) }
      it { should == 0 }
    end

    context "when notifications is set to false" do
      before { create(:conversation_relationship, user: user, new_posts: true, notifications: true) }
      it { should == 1 }
    end

  end

  describe "#unread_conversations?" do

    subject { user.unread_conversations? }

    context "with no unread conversations" do
      it { should be_false }
    end

    context "with unread conversations" do
      before { create(:conversation_relationship, user: user, new_posts: true, notifications: true) }
      it { should be_true }
    end

  end

  describe "#following?" do

    subject { user.following?(discussion) }

    context "when discussion isn't followed" do
      it { should be_false }
    end

    context "when discussion is followed" do
      before { DiscussionRelationship.define(user, discussion, following: true) }
      it { should be_true }
    end

  end

  describe "#favorite?" do

    subject { user.favorite?(discussion) }

    context "when discussion isn't favorite" do
      it { should be_false }
    end

    context "when discussion is favorite" do
      before { DiscussionRelationship.define(user, discussion, favorite: true) }
      it { should be_true }
    end

  end

end