require 'spec_helper'

describe Viewable do

  let(:trusted_category)   { create(:trusted_category) }
  let(:discussion)         { create(:discussion) }
  let(:trusted_discussion) { create(:discussion, category: trusted_category) }
  let(:user)               { create(:user) }
  let(:trusted_user)       { create(:trusted_user) }

  describe ".viewable_by" do
    before do
      discussion
      trusted_discussion
    end

    subject { Discussion.viewable_by(user) }

    context "when user is trusted" do
      let(:user) { create(:trusted_user) }
      it { should =~ [discussion, trusted_discussion] }
    end

    context "when user isn't trusted" do
      let(:user) { create(:user) }
      it { should =~ [discussion] }
    end
  end

  describe "#viewable_by?" do
    specify { trusted_discussion.viewable_by?(trusted_user).should be_true }
    specify { trusted_discussion.viewable_by?(user).should be_false }
    specify { trusted_discussion.viewable_by?(nil).should be_false }

    context "when public browsing is on" do
      before { configure public_browsing: true }
      specify { discussion.viewable_by?(user).should be_true }
      specify { discussion.viewable_by?(nil).should be_true }
    end

    context "when public browsing is off" do
      before { configure public_browsing: false }
      specify { discussion.viewable_by?(user).should be_true }
      specify { discussion.viewable_by?(nil).should be_false }
    end
  end

end