# frozen_string_literal: true

require "rails_helper"

describe SearchableExchange do
  describe ".search" do
    subject { Discussion.search("testing") }

    let!(:discussion) { create(:discussion, title: "testing discussion") }
    let(:user) { create(:user) }

    before { create(:conversation, title: "testing conversation") }

    it { is_expected.to contain_exactly(discussion) }
  end
end
