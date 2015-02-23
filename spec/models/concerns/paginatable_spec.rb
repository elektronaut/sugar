require "spec_helper"

describe Paginatable do
  before(:each) do
    Exchange.per_page = 2
  end

  describe ".page" do
    subject { Exchange.page(2, context: 1) }
    specify { expect(subject.offset_value).to eq(1) }
    specify { expect(subject.limit_value).to eq(3) }
  end

  describe ".context" do
    specify { expect(Exchange.page(1, context: 3).context).to eq(0) }
    specify { expect(Exchange.page(2, context: 3).context).to eq(3) }
  end

  describe ".context?" do
    specify { expect(Exchange.page(1).context?).to eq(false) }
    specify { expect(Exchange.page(1, context: 3).context?).to eq(false) }
    specify { expect(Exchange.page(2, context: 3).context?).to eq(true) }
  end

  describe ".total_pages" do
    before { 3.times { create(:post) } }
    specify { expect(Exchange.page(2, context: 1).total_pages).to eq(2) }
  end

  describe ".current_page" do
    before { 3.times { create(:exchange) } }
    specify { expect(Exchange.page(0).current_page).to eq(1) }
    specify { expect(Exchange.page(1).current_page).to eq(1) }
    specify { expect(Exchange.page(2).current_page).to eq(2) }
    specify { expect(Exchange.page(3).current_page).to eq(2) }
    specify { expect(Exchange.page(2, context: 2).current_page).to eq(2) }
  end

  describe ".first_page" do
    specify { expect(Exchange.page(2).first_page).to eq(1) }
  end

  describe ".last_page" do
    before { 3.times { create(:exchange) } }
    specify { expect(Exchange.page(1).last_page).to eq(2) }
  end

  describe ".first_page?" do
    before { 3.times { create(:exchange) } }
    specify { expect(Exchange.page(1).first_page?).to eq(true) }
    specify { expect(Exchange.page(2).first_page?).to eq(false) }
  end

  describe ".last_page?" do
    before { 3.times { create(:exchange) } }
    specify { expect(Exchange.page(1).last_page?).to eq(false) }
    specify { expect(Exchange.page(2).last_page?).to eq(true) }
  end

  describe ".previous_page" do
    before { 3.times { create(:exchange) } }
    specify { expect(Exchange.page(2).previous_page).to eq(1) }
    specify { expect(Exchange.page(1).previous_page).to eq(nil) }
  end

  describe ".next_page" do
    before { 3.times { create(:exchange) } }
    specify { expect(Exchange.page(1).next_page).to eq(2) }
    specify { expect(Exchange.page(2).next_page).to eq(nil) }
  end

  describe ".total_count" do
    before { 3.times { create(:exchange) } }
    it "ignores limit" do
      expect(Exchange.limit(1).total_count).to eq(3)
    end
    it "ignores offset" do
      expect(Exchange.offset(1).total_count).to eq(3)
    end
  end

  describe ".per_page" do
    before { Exchange.per_page = 19 }
    specify { expect(Exchange.per_page).to eq(19) }
  end
end
