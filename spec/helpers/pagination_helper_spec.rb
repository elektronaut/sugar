# encoding: utf-8

require "rails_helper"

describe PaginationHelper do
  describe "#nearest_pages" do
    let(:pages) { 100 }
    let(:collection) { double(current_page: page, total_pages: pages) }
    subject { helper.nearest_pages(collection) }

    context "not near the edges" do
      let(:page) { 15 }
      it { is_expected.to eq((11..19).to_a) }
      specify { expect(subject.length).to eq(9) }
    end

    context "near the beginning" do
      let(:page) { 2 }
      it { is_expected.to eq((1..9).to_a) }
      specify { expect(subject.length).to eq(9) }
    end

    context "near the end" do
      let(:page) { 99 }
      it { is_expected.to eq((92..100).to_a) }
      specify { expect(subject.length).to eq(9) }
    end

    context "when range is limited" do
      let(:page) { 1 }
      let(:pages) { 6 }
      it { is_expected.to eq((1..6).to_a) }
      specify { expect(subject.length).to eq(pages) }
    end
  end
end
