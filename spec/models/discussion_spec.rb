require 'spec_helper'

describe Discussion do
  let(:discussion) { create(:discussion) }
  let(:closed_discussion) { create(:discussion, closed: true) }
  let(:trusted_discussion) { create(:discussion, category: trusted_category) }
  let(:category) { create(:category) }
  let(:trusted_category) { create(:trusted_category) }
  let(:user) { create(:user) }
  let(:trusted_user) { create(:trusted_user) }
  let(:moderator) { create(:moderator) }
  let(:user_admin) { create(:user_admin) }
  let(:admin) { create(:admin) }

  it { should have_many(:discussion_relationships).dependent(:destroy) }
  it { should belong_to(:category) }
  it { should validate_presence_of(:category_id) }
  it { should be_kind_of(Exchange) }

  describe 'save callbacks' do
    context "created in a trusted category" do
      subject { create(:discussion, category: trusted_category) }
      its(:trusted) { should be_true }
    end
    context "created in a regular category" do
      subject { create(:discussion, category: category) }
      its(:trusted) { should be_false }
    end
    it "changes the trusted status on discussions" do
      create(:post, discussion: discussion)
      discussion.posts.first.trusted?.should == false
      discussion.update_attributes(category: trusted_category)
      discussion.posts.first.trusted?.should == true
      discussion.update_attributes(category: category)
      discussion.posts.first.trusted?.should == false
    end
  end

  describe ".find_popular" do
    subject { Discussion.find_popular }
    it { should be_kind_of(Pagination::InstanceMethods) }
    describe ":page option" do
      before { 2.times { create(:discussion) } }
      context "default" do
        subject { Discussion.find_popular(:limit => 1) }
        its(:page) { should == 1 }
      end
      context "specified" do
        subject { Discussion.find_popular(:limit => 1, :page => 2) }
        its(:page) { should == 2 }
      end
      context "out of bounds" do
        subject { Discussion.find_popular(:limit => 1, :page => 3) }
        its(:page) { should == 2 }
      end
    end
    describe ":since option" do
      let(:discussion1) { create(:discussion) }
      let(:discussion2) { create(:discussion) }
      before do
        discussion1.posts.first.update_attributes(created_at: 4.days.ago)
        [13.days.ago, 12.days.ago].each do |t|
          create(:post, discussion: discussion1, created_at: t)
        end
        [2.days.ago].each do |t|
          create(:post, discussion: discussion2, created_at: t)
        end
      end
      context "last 3 days" do
        subject { Discussion.find_popular(since: 3.days.ago) }
        it { should == [discussion2] }
      end
      context "last 7 days" do
        subject { Discussion.find_popular(since: 7.days.ago) }
        it { should == [discussion2, discussion1] }
        its(:first) { should respond_to(:recent_posts_count) }
        its(:first) { subject.recent_posts_count.to_i.should == 2 }
      end
      context "last 14 days" do
        subject { Discussion.find_popular(since: 14.days.ago) }
        it { should == [discussion1, discussion2] }
      end
    end
    describe ":limit option" do
      context "default" do
        its(:per_page) { should == Exchange::DISCUSSIONS_PER_PAGE }
      end
      context "specified" do
        subject { Discussion.find_popular(limit: 7) }
        its(:per_page) { should == 7 }
      end
    end
    describe ":trusted option" do
      before { discussion; trusted_discussion }
      context "default" do
        it { should include(discussion) }
        it { should_not include(trusted_discussion) }
      end
      context "true" do
        subject { Discussion.find_popular(trusted: true) }
        it { should include(discussion, trusted_discussion) }
      end
      context "false" do
        subject { Discussion.find_popular(trusted: false) }
        it { should include(discussion) }
        it { should_not include(trusted_discussion) }
      end
    end
  end

  describe "#viewable_by?" do
    context "trusted discussion" do
      context "regular user" do
        subject { trusted_discussion.viewable_by?(user) }
        it { should be_false }
      end
      context "trusted user" do
        subject { trusted_discussion.viewable_by?(trusted_user) }
        it { should be_true }
      end
    end
    context "regular discussion" do
      context "public browsing on" do
        before { Sugar.config(:public_browsing, true) }
        it { discussion.viewable_by?(nil).should be_true }
      end
      context "public browsing off" do
        before { Sugar.config(:public_browsing, false) }
        it { discussion.viewable_by?(nil).should be_false }
        it { discussion.viewable_by?(user).should be_true }
      end
    end
  end

  describe "#editable_by?" do
    context "poster" do
      subject { discussion.editable_by?(discussion.poster) }
      it { should be_true }
    end
    context "other user" do
      subject { discussion.editable_by?(user) }
      it { should be_false }
    end
    context "moderator" do
      subject { discussion.editable_by?(moderator) }
      it { should be_true }
    end
    context "admin" do
      subject { discussion.editable_by?(admin) }
      it { should be_true }
    end
    context "user admin" do
      subject { discussion.editable_by?(user_admin) }
      it { should be_false }
    end
    context "no user" do
      subject { discussion.editable_by?(nil) }
      it { should be_false }
    end
  end

  describe "#postable_by?" do
    context "not closed" do
      context "any user" do
        subject { discussion.postable_by?(user) }
        it { should be_true }
      end
      context "no user" do
        subject { discussion.postable_by?(nil) }
        it { should be_false }
      end
    end
    context "closed" do
      context "any user" do
        subject { closed_discussion.postable_by?(user) }
        it { should be_false }
      end
      context "poster" do
        subject { closed_discussion.postable_by?(closed_discussion.poster) }
        it { should be_false }
      end
      context "moderator" do
        subject { closed_discussion.postable_by?(moderator) }
        it { should be_true }
      end
      context "admin" do
        subject { closed_discussion.postable_by?(admin) }
        it { should be_true }
      end
    end
  end

  describe "#closeable_by?" do
    context "other user" do
      subject { discussion.closeable_by?(user) }
      it { should be_false }
    end
    context "not closed" do
      context "poster" do
        subject { discussion.closeable_by?(discussion.poster) }
        it { should be_true }
      end
      context "moderator" do
        subject { discussion.closeable_by?(moderator) }
        it { should be_true }
      end
    end
    context "closed by self" do
      before { discussion.update_attributes(closed: true, updated_by: discussion.poster) }
      subject { discussion }
      its(:closer) { should == discussion.poster }
      context "poster" do
        subject { discussion.closeable_by?(discussion.poster) }
        it { should be_true }
      end
      context "moderator" do
        subject { discussion.closeable_by?(moderator) }
        it { should be_true }
      end
    end
    context "closed by moderator" do
      before { discussion.update_attributes(closed: true, updated_by: moderator) }
      subject { discussion }
      its(:closer) { should == moderator }
      context "poster" do
        subject { discussion.closeable_by?(discussion.poster) }
        it { should be_false }
      end
      context "moderator" do
        subject { discussion.closeable_by?(moderator) }
        it { should be_true }
      end
    end
  end

end
