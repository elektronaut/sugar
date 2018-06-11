# frozen_string_literal: true

require "rails_helper"

describe SearchableExchange, solr: true do
  let!(:discussion) { create(:discussion, title: "testing discussion") }
  let!(:trusted_discussion) do
    create(:trusted_discussion, title: "testing trusted discussion")
  end
  let(:user) { create(:user) }
  let(:trusted_user) { create(:trusted_user) }

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

    context "when logged in as a trusted user" do
      subject do
        Discussion.search_results("testing", user: trusted_user, page: 1)
                  .results
      end

      it { is_expected.to match_array([discussion, trusted_discussion]) }
    end
  end
end
