# encoding: utf-8

require "rails_helper"

describe Post do
  let(:discussion) { create(:discussion) }
  let(:trusted_discussion) { create(:trusted_discussion) }
  let(:conversation) { create(:conversation) }
  let(:post) { create(:post) }
  let(:trusted_post) { create(:trusted_post) }
  let(:user) { create(:user) }
  let(:trusted_user) { create(:trusted_user) }
  let(:moderator) { create(:moderator) }
  let(:admin) { create(:admin) }
  let(:user_admin) { create(:user_admin) }
  let(:mentioned_users) do
    ["eléktronaut", "#1", "With space"].map { |u| create(:user, username: u) }
  end
  let(:mentioning_post) do
    create(
      :post,
      body: mentioned_users.map { |u| "@#{u.username.downcase}" }.join(" and ")
    )
  end
  let(:cache_path) do
    Rails.root.join("public", "cache", "discussions", discussion.id.to_s,
                    "posts", "count.json")
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:exchange) }
  it { is_expected.to have_many(:exchange_views) }

  describe "after_create" do
    let(:post) { create(:post, exchange: discussion) }

    specify do
      expect(post.user.participated_discussions).to include(discussion)
    end

    describe "the discussion it belongs to" do
      before { post }
      subject { discussion }
      specify { expect(subject.last_poster).to eq(post.user) }
      specify { expect(subject.last_post_at).to eq(post.created_at) }
    end

    context "when count cache file exists" do
      let!(:discussion) { create(:discussion) }
      let(:post) { create(:post, exchange: discussion) }
      it "should delete the file" do
        allow(File).to receive(:exist?).and_return(true)
        expect(File).to(
          receive(:unlink)
            .with(cache_path)
            .exactly(1).times
        )
        post
      end
    end
  end

  describe "after_destroy" do
    describe "decrementing public posts count" do
      let!(:post) { create(:post, user: user) }

      it "should decrement public_posts_count on user" do
        expect { post.destroy }.to change { user.public_posts_count }.by(-1)
      end
    end

    context "when count cache file exists" do
      let!(:post) { create(:post, exchange: discussion) }
      it "should delete the file" do
        allow(File).to receive(:exist?).and_return(true)
        expect(File).to(
          receive(:unlink)
            .with(cache_path)
            .exactly(1).times
        )
        post.destroy
      end
    end
  end

  describe "#me_post?" do
    subject { post.me_post? }

    context "when post starts with /me" do
      let(:post) { create(:post, body: "/me shuffles") }
      it { is_expected.to eq(true) }
    end

    context "when post starts with /me and contains a line break" do
      let(:post) { create(:post, body: "/me shuffles\noh yeah") }
      it { is_expected.to eq(false) }
    end

    context "when post doesn't start with /me" do
      let(:post) { create(:post, body: "Start with /me") }
      it { is_expected.to eq(false) }
    end
  end

  describe "#post_number" do
    specify { expect(discussion.posts.first.post_number).to eq(1) }
    specify { expect(create(:post, exchange: discussion).post_number).to eq(2) }
  end

  describe "#page" do
    subject { post.page }

    context "when it's the first post" do
      before { allow(post).to receive(:post_number).and_return(1) }
      it { is_expected.to eq(1) }
    end

    context "when it's the last post on a page" do
      before { allow(post).to receive(:post_number).and_return(50) }
      it { is_expected.to eq(1) }
    end

    context "when it's the first post on the second page" do
      before { allow(post).to receive(:post_number).and_return(51) }
      it { is_expected.to eq(2) }
    end

    context "with :limit set" do
      before { allow(post).to receive(:post_number).and_return(70) }
      subject { post.page(limit: 10) }
      it { is_expected.to eq(7) }
    end
  end

  describe "#body_html" do
    let!(:discussion) { create(:discussion) }
    let!(:post) { create(:post, exchange: discussion) }

    subject { post.body_html }
    it { is_expected.to eq(Renderer.render(post.body)) }

    context "when not saved" do
      let!(:post) { build(:post, exchange: discussion) }

      it "parses the post" do
        expect(Renderer).to receive(:render)
          .exactly(1).times
          .and_return(double(to_html: "<p>Test</p>"))
        post.body_html
      end
    end

    context "when body_html has been set" do
      let!(:post) do
        create(:post, exchange: discussion, body_html: "<p>Test</p>")
      end

      it "uses the cached version" do
        expect(Renderer).to receive(:render).exactly(0).times
        post.body_html
      end
    end

    context "when body_html hasn't been set" do
      it "parses the post" do
        post.body_html = nil
        expect(Renderer).to receive(:render)
          .exactly(1).times
          .and_return("<p>Test</p>".html_safe)
        post.body_html
      end
    end
  end

  describe "#edited?" do
    subject { post.edited? }

    context "when post hasn't been edited" do
      it { is_expected.to eq(false) }
    end

    context "when post has been edited" do
      let(:post) do
        create(:post, created_at: 5.minutes.ago, edited_at: 2.minutes.ago)
      end

      it { is_expected.to eq(true) }
    end

    context "when post has been edited less than five seconds ago" do
      let(:post) do
        create(:post, created_at: 14.seconds.ago, edited_at: 10.seconds.ago)
      end

      it { is_expected.to eq(false) }
    end
  end

  describe "#editable_by?" do
    specify { expect(post.editable_by?(post.user)).to eq(true) }
    specify { expect(post.editable_by?(moderator)).to eq(true) }
    specify { expect(post.editable_by?(admin)).to eq(true) }
    specify { expect(post.editable_by?(user)).to eq(false) }
    specify { expect(post.editable_by?(user_admin)).to eq(false) }
    specify { expect(post.editable_by?(nil)).to eq(false) }
  end

  describe "#viewable_by?" do
    context "when it isn't trusted" do
      specify { expect(post.viewable_by?(user)).to eq(true) }
    end

    context "when it is trusted" do
      specify { expect(trusted_post.viewable_by?(user)).to eq(false) }
      specify { expect(trusted_post.viewable_by?(trusted_user)).to eq(true) }
    end

    context "and public browsing is on" do
      before { Sugar.config.public_browsing = true }
      specify { expect(post.viewable_by?(nil)).to eq(true) }
    end

    context "and public browsing is of" do
      before { Sugar.config.public_browsing = false }
      specify { expect(post.viewable_by?(nil)).to eq(false) }
    end
  end

  describe "#mentions_users?" do
    subject { post.mentions_users? }

    context "when it doesn't mention users" do
      it { is_expected.to eq(false) }
    end

    context "when it mentions users" do
      let(:post) { mentioning_post }
      it { is_expected.to eq(true) }
    end
  end

  describe "#mentioned_users" do
    subject { post.mentioned_users }

    context "when it doesn't mention users" do
      it { is_expected.to eq([]) }
    end

    context "when it mentions users" do
      let(:post) { mentioning_post }
      it { is_expected.to match_array(mentioned_users) }
    end
  end

  describe "#update_trusted_status" do
    subject { post }

    context "when in a regular discussion" do
      let(:post) { create(:post, exchange: discussion) }
      specify { expect(subject.trusted?).to eq(false) }
      specify { expect(subject.conversation?).to eq(false) }
    end

    context "when in a trusted discussion" do
      let(:post) { create(:post, exchange: trusted_discussion) }
      specify { expect(subject.trusted?).to eq(true) }
    end
  end

  describe "#render_html" do
    context "when skip_html is false" do
      before { discussion }
      it "parses the post" do
        expect(Renderer).to receive(:render)
          .exactly(1).times
          .and_return("<p>Test</p>".html_safe)
        create(:post, exchange: discussion)
      end
    end

    context "when skip_html is true" do
      before { discussion }
      it "parses the post" do
        expect(Renderer).to receive(:render).exactly(0).times
        create(:post, skip_html: true, exchange: discussion)
      end
    end
  end

  describe "#set_edit_timestamp" do
    subject { post }

    context "when edited_at is set" do
      let(:timestamp) { 2.days.ago }
      let(:post) { create(:post, edited_at: timestamp) }
      specify { expect(subject.edited_at).to be_within(1.second).of(timestamp) }
    end

    context "when edited_at isn't set" do
      before do
        allow(Time).to receive(:now)
          .and_return(Time.zone.parse("Oct 22 2012"))
      end
      specify { expect(subject.edited_at).to eq(Time.now.utc) }
    end
  end

  describe "#define_relationship" do
    context "when it belongs to a discussion" do
      before { discussion }
      it "defines a relationship between the discussion and the poster" do
        expect(
          DiscussionRelationship
        ).to receive(:define)
          .exactly(1).times
          .with(user, discussion, participated: true)
        create(:post, user: user, exchange: discussion)
      end
    end

    context "when it belongs to a conversation" do
      before { conversation }
      it "does not define a relationship" do
        expect(DiscussionRelationship).to receive(:define).exactly(0).times
        create(:post, exchange: conversation)
      end
    end
  end

  describe "#update_exchange" do
    subject { post.exchange }
    specify { expect(subject.last_poster_id).to eq(post.user_id) }
    specify { expect(subject.last_post_at).to eq(post.created_at) }
  end
end
