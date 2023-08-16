# frozen_string_literal: true

require "rails_helper"

describe UserLink do
  subject(:user_link) { build(:user_link) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:label) }

  describe ".labels" do
    subject { described_class.labels }

    before do
      create(:user_link, label: "Service A")
      create(:user_link, label: "Service B")
      create(:user_link, label: "service A")
    end

    it { is_expected.to eq(["Service A", "Service B"]) }
  end

  describe ".with_label" do
    subject(:links) { described_class.with_label("Service A") }

    before do
      create(:user_link, label: "Service A")
      create(:user_link, label: "Service B")
      create(:user_link, label: "service A")
    end

    specify { expect(links.count).to eq(2) }
  end
end
