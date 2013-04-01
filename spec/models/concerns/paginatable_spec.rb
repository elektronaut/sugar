require 'spec_helper'

describe Paginatable do

  before(:each) do
    Exchange.per_page = 2
  end

  describe ".page" do
    subject { Exchange.page(2, context: 1) }
    its(:offset_value) { should == 1 }
    its(:limit_value) { should == 3 }
  end

  describe ".context" do
    specify { Exchange.page(1, context: 3).context.should == 0 }
    specify { Exchange.page(2, context: 3).context.should == 3 }
  end

  describe ".context?" do
    specify { Exchange.page(1).context?.should be_false }
    specify { Exchange.page(1, context: 3).context?.should be_false }
    specify { Exchange.page(2, context: 3).context?.should be_true }
  end

  describe ".total_pages" do
    before { 3.times { create(:post) } }
    specify { Exchange.page(2, context: 1).total_pages.should == 2 }
  end

  describe ".current_page" do
    before { 3.times { create(:exchange) } }
    specify { Exchange.page(0).current_page.should == 1 }
    specify { Exchange.page(1).current_page.should == 1 }
    specify { Exchange.page(2).current_page.should == 2 }
    specify { Exchange.page(3).current_page.should == 2 }
    specify { Exchange.page(2, context: 2).current_page.should == 2 }
  end

  describe ".first_page" do
    specify { Exchange.page(2).first_page.should == 1 }
  end

  describe ".last_page" do
    before { 3.times { create(:exchange) } }
    specify { Exchange.page(1).last_page.should == 2 }
  end

  describe ".first_page?" do
    before { 3.times { create(:exchange) } }
    specify { Exchange.page(1).first_page?.should be_true }
    specify { Exchange.page(2).first_page?.should be_false }
  end

  describe ".last_page?" do
    before { 3.times { create(:exchange) } }
    specify { Exchange.page(1).last_page?.should be_false }
    specify { Exchange.page(2).last_page?.should be_true }
  end

  describe ".previous_page" do
    before { 3.times { create(:exchange) } }
    specify { Exchange.page(2).previous_page.should == 1 }
    specify { Exchange.page(1).previous_page.should be_nil }
  end

  describe ".next_page" do
    before { 3.times { create(:exchange) } }
    specify { Exchange.page(1).next_page.should == 2 }
    specify { Exchange.page(2).next_page.should be_nil }
  end

  describe ".total_count" do
    before { 3.times { create(:exchange) } }
    it "ignores limit" do
      Exchange.limit(1).total_count.should == 3
    end
    it "ignores offset" do
      Exchange.offset(1).total_count.should == 3
    end
  end

  describe ".per_page" do
    before { Exchange.per_page = 19 }
    specify { Exchange.per_page.should == 19 }
  end

end
