# frozen_string_literal: true

require "rails_helper"

describe SearchableExchange, solr: true do
  around do |each|
    perform_enqueued_jobs do
      each.run
    end
  end

  describe ".search_results" do
    let!(:discussion) { create(:discussion, title: "testing discussion") }
    let(:user) { create(:user) }

    before do
      create(:conversation, title: "testing conversation")
      Sunspot.commit
    end

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
