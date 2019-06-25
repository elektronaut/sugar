# frozen_string_literal: true

require "rails_helper"

describe SearchableExchange, solr: true do
  let!(:discussion) { create(:discussion, title: "testing discussion") }
  let(:user) { create(:user) }

  before do
    create(:conversation, title: "testing conversation")
  end

  describe ".search_results" do
    before { Sunspot.commit }

    context "when not logged in" do
      subject do
        Discussion.search_results("testing", user: nil, page: 1).results
      end

      it { is_expected.to match_array([discussion]) }
    end

    context "when logged in as a regular user" do
      subject do
        Discussion.search_results("testing", user: user, page: 1).results
      end

      it { is_expected.to match_array([discussion]) }
    end
  end
end
