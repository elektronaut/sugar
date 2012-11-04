# encoding: utf-8

require "spec_helper"

describe Post do

  let(:discussion)         { create(:discussion) }
  let(:trusted_discussion) { create(:trusted_discussion) }
  let(:conversation)       { create(:conversation) }
  let(:post)               { create(:post) }
  let(:trusted_post)       { create(:trusted_post) }
  let(:user)               { create(:user) }
  let(:trusted_user)       { create(:trusted_user) }
  let(:moderator)          { create(:moderator) }
  let(:admin)              { create(:admin) }
  let(:user_admin)         { create(:user_admin) }
  let(:mentioned_users)    { ["eléktronaut", "#1", "With space"].map{|u| create(:user, username: u) } }
  let(:mentioning_post)    { create(:post, body: mentioned_users.map{|u| "@#{u.username.downcase}" }.join(" and ")) }

  it { should belong_to(:user) }
  it { should belong_to(:discussion).class_name('Exchange') }
  it { should have_many(:discussion_views) }

  describe "after_create" do

    let(:post) { create(:post, discussion: discussion) }

    specify { post.user.participated_discussions.should include(discussion) }

    describe "the discussion it belongs to" do
      before { post }
      subject { discussion }
      its(:last_poster) { should == post.user }
      its(:last_post_at) { should == post.created_at }
    end

  end

  describe "before_save" do

    subject { post }

    context "when in a conversation" do
      let(:post) { create(:post, discussion: conversation) }
      its(:conversation?) { should be_true }
    end

    context "when in a regular discussion" do
      let(:post) { create(:post, discussion: discussion) }
      its(:trusted?) { should be_false }
      its(:conversation?) { should be_false }
    end

    context "when in a trusted discussion" do
      let(:post) { create(:post, discussion: trusted_discussion) }
      its(:trusted?) { should be_true }
    end

    context "when edited_at is set" do
      let(:timestamp) { 2.days.ago }
      let(:post) { create(:post, edited_at: timestamp) }
      its(:edited_at) { should == timestamp }
    end

    context "when edited_at isn't set" do
      before { Time.stub!(:now).and_return(Time.parse("Oct 22 2012")) }
      its(:edited_at) { should == Time.now }
    end

    context "when skip_html is false" do
      before { discussion }
      it "parses the post" do
        PostParser.should_receive(:new).exactly(1).times
          .and_return { double(:to_html => "<p>Test</p>") }
        create(:post, discussion: discussion)
      end
    end

    context "when skip_html is true" do
      before { discussion }
      it "parses the post" do
        PostParser.should_receive(:new).exactly(0).times
        create(:post, skip_html: true, discussion: discussion)
      end
    end

  end

  describe ".find_paginated" do

    subject { Post.find_paginated(discussion: discussion) }
    it { should be_kind_of(Pagination::InstanceMethods) }

    context "with option" do

      describe :page do

        before do
          create(:post, discussion: discussion)
          discussion.reload
        end

        context "when not specified" do
          subject { Post.find_paginated(discussion: discussion, limit: 1) }
          its(:page) { should == 1 }
        end

        context "when specified" do
          subject { Post.find_paginated(discussion: discussion, limit: 1, page: 2) }
          its(:page) { should == 2 }
        end

        context "when out of bounds" do
          subject { Post.find_paginated(discussion: discussion, limit: 1, page: 3) }
          its(:page) { should == 2 }
        end

      end

      describe :limit do

        context "when not specified" do
          its(:per_page) { should == Post::POSTS_PER_PAGE }
        end

        context "when specified" do
          subject { Post.find_paginated(discussion: discussion, limit: 7) }
          its(:per_page) { should == 7 }
        end

      end

      describe :context do

        before do
          2.times { create(:post, discussion: discussion) }
          discussion.reload
        end

        context "when not specified" do
          subject { Post.find_paginated(discussion: discussion, limit: 1, page: 1) }
          its(:length) { should == 1 }
        end

        context "when specified, on first page" do
          subject { Post.find_paginated(discussion: discussion, limit: 1, context: 2, page: 1) }
          its(:length) { should == 1 }
        end

        context "when specified, on second page" do
          subject { Post.find_paginated(discussion: discussion, limit: 1, context: 2, page: 2) }
          its(:length) { should == 3 }
        end

      end

    end

  end

  describe ".search_paginated" do

    let(:search_results) { double(results: [post], total: 2) }

    subject { Post.search_paginated(query: "Bacon") }
    it { should be_kind_of(Pagination::InstanceMethods) }

    context "with solr", solr: true do
      it { should == [] }
    end

    context "with stubbed search engine" do

      before do
        Post.stub(:search).and_return(search_results)
      end

      it { should include(post) }

      context "with option" do

        describe :page do

          context "when not specified" do
            subject { Post.search_paginated(query: "Bacon", limit: 1) }
            its(:page) { should == 1 }
          end

          context "when specified" do
            subject { Post.search_paginated(query: "Bacon", limit: 1, page: 2) }
            its(:page) { should == 2 }
          end

        end

        describe :limit do

          context "when not specified" do
            its(:per_page) { should == Post::POSTS_PER_PAGE }
          end

          context "when specified" do
            subject { Post.search_paginated(query: "Bacon", limit: 7) }
            its(:per_page) { should == 7 }
          end

        end

      end

    end

  end

  describe "#me_post?" do

    subject { post.me_post? }

    context "when post starts with /me" do
      let(:post) { create(:post, body: "/me shuffles") }
      it { should be_true }
    end

    context "when post starts with /me and contains a line break" do
      let(:post) { create(:post, body: "/me shuffles\noh yeah") }
      it { should be_false }
    end

    context "when post doesn't start with /me" do
      let(:post) { create(:post, body: "Start with /me") }
      it { should be_false }
    end

  end

  describe "#post_number" do
    specify { discussion.first_post.post_number.should == 1 }
    specify { create(:post, discussion: discussion).post_number.should == 2 }
  end

  describe "#page" do

    subject { post.page }

    context "when it's the first post" do
      before { post.stub(:post_number).and_return(1) }
      it { should == 1 }
    end

    context "when it's the last post on a page" do
      before { post.stub(:post_number).and_return(50) }
      it { should == 1 }
    end

    context "when it's the first post on the second page" do
      before { post.stub(:post_number).and_return(51) }
      it { should == 2 }
    end

    context "with :limit set" do
      before { post.stub(:post_number).and_return(70) }
      subject { post.page(:limit => 10) }
      it { should == 7 }
    end

  end

  describe "#body_html" do

    let!(:discussion) { create(:discussion) }
    let!(:post) { create(:post, discussion: discussion) }

    subject { post.body_html }
    it { should == PostParser.new(post.body).to_html }

    context "when not saved" do

      let!(:post) { build(:post, discussion: discussion) }

      it "parses the post" do
        PostParser.should_receive(:new).exactly(1).times
          .and_return { double(:to_html => "<p>Test</p>") }
        post.body_html
      end

    end

    context "when body_html has been set" do

      let!(:post) { create(:post, discussion: discussion, body_html: "<p>Test</p>") }

      it "uses the cached version" do
        PostParser.should_receive(:new).exactly(0).times
        post.body_html
      end
    end

    context "when body_html hasn't been set" do

      it "parses the post" do
        post.body_html = nil
        PostParser.should_receive(:new).exactly(1).times
          .and_return { double(:to_html => "<p>Test</p>") }
        post.body_html
      end

    end

  end

  describe "#edited?" do

    subject { post.edited? }

    context "when post hasn't been edited" do
      it { should be_false }
    end

    context "when post has been edited" do
      let(:post) { create(:post, created_at: 5.minutes.ago, edited_at: 2.minutes.ago) }
      it { should be_true }
    end

    context "when post has been edited less than five seconds ago" do
      let(:post) { create(:post, created_at: 14.seconds.ago, edited_at: 10.seconds.ago) }
      it { should be_false }
    end

  end

  describe "#editable_by?" do
    specify { post.editable_by?(post.user).should be_true }
    specify { post.editable_by?(moderator).should be_true }
    specify { post.editable_by?(admin).should be_true }
    specify { post.editable_by?(user).should be_false }
    specify { post.editable_by?(user_admin).should be_false }
    specify { post.editable_by?(nil).should be_false }
  end

  describe "#viewable_by?" do

    context "when it isn't trusted" do
      specify { post.viewable_by?(user).should be_true }
    end

    context "when it is trusted" do
      specify { trusted_post.viewable_by?(user).should be_false }
      specify { trusted_post.viewable_by?(trusted_user).should be_true }
    end

    context "and public browsing is on" do
      before { Sugar.config(:public_browsing, true) }
      specify { post.viewable_by?(nil).should be_true }
    end

    context "and public browsing is of" do
      before { Sugar.config(:public_browsing, false) }
      specify { post.viewable_by?(nil).should be_false }
    end

  end

  describe "#mentions_users?" do

    subject { post.mentions_users? }

    context "when it doesn't mention users" do
      it { should be_false }
    end

    context "when it mentions users" do
      let(:post) { mentioning_post }
      it { should be_true }
    end

  end

  describe "#mentioned_users" do

    subject { post.mentioned_users }

    context "when it doesn't mention users" do
      it { should == [] }
    end

    context "when it mentions users" do
      let(:post) { mentioning_post }
      it { should =~ mentioned_users }
    end

  end

end