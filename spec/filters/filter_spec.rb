require "rails_helper"

describe Filter do
  let(:input) { "pass through" }
  let(:filter) { Filter.new(input) }

  describe "#process" do
    subject { filter.process(input) }
    it { is_expected.to eq(input) }
  end

  describe "#to_html" do
    subject { filter.to_html }
    it { is_expected.to eq(input) }
  end

  describe "#logger" do
    subject { filter.logger }
    it { is_expected.to eq(Rails.logger) }
  end
end
