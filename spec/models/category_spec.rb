require "spec_helper"

describe Category do
  let(:category) { create(:category, name: "This is my Category") }
  let(:trusted_category) { create(:trusted_category) }
  let(:user) { create(:user) }
  let(:trusted_user) { create(:trusted_user) }
  let(:moderator) { create(:moderator) }
  let(:user_admin) { create(:user_admin) }
  let(:admin) { create(:admin) }

  it { should have_many(:discussions) }
  it { should validate_presence_of(:name) }
  it { should be_kind_of(ActiveRecord::Acts::List) }

  describe "save callbacks" do

    it "changes the trusted status on discussions" do
      create(:discussion, category: category)
      category.discussions.first.trusted?.should == false
      category.update_attributes(trusted: true)
      category.discussions.first.trusted?.should == true
      category.update_attributes(trusted: false)
      category.discussions.first.trusted?.should == false
    end

  end

  describe ".find_viewable_by" do

    let!(:category) { create(:category) }
    let!(:trusted_category) { create(:trusted_category) }

    context "when logged in as regular user" do
      subject { Category.find_viewable_by(user) }
      it { should include(category) }
      it { should_not include(trusted_category) }
    end

    context "when logged in as a trusted user" do
      subject { Category.find_viewable_by(trusted_user) }
      it { should include(category) }
      it { should include(trusted_category) }
    end

  end

  describe "#labels?" do

    context "with no labels" do
      subject { category.labels? }
      it { should be_false }
    end

    context "with labels" do
      subject { trusted_category.labels? }
      it { should be_true }
    end

  end

  describe "#labels" do

    context "with no labels" do
      subject { category.labels }
      it { should == [] }
    end

    context "with labels" do
      subject { trusted_category.labels }
      it { should == ["Trusted"] }
    end

  end

  describe "#viewable_by?" do

    context "regular category" do
      specify { category.viewable_by?(user).should be_true }
      specify { category.viewable_by?(trusted_user).should be_true }
      specify { category.viewable_by?(admin).should be_true }
      specify { category.viewable_by?(moderator).should be_true }
      specify { category.viewable_by?(user_admin).should be_true }
    end

    context "trusted category" do
      specify { trusted_category.viewable_by?(user).should be_false }
      specify { trusted_category.viewable_by?(trusted_user).should be_true }
      specify { trusted_category.viewable_by?(admin).should be_true }
      specify { trusted_category.viewable_by?(moderator).should be_true }
      specify { trusted_category.viewable_by?(user_admin).should be_true }
    end

    context "when public browsing is on" do
      before { Sugar.config(:public_browsing, true) }
      specify { category.viewable_by?(nil).should be_true }
    end

    context "when public browsing is off" do
      before { Sugar.config(:public_browsing, false) }
      specify { category.viewable_by?(nil).should be_false }
    end

  end

  describe "#to_param" do

    it "creates a URL slug" do
      category.to_param.should =~ /^[\d]+;This\-is\-my\-Category$/
    end

  end

end
