# encoding: utf-8

require "rails_helper"

describe SearchableExchange, solr: true do
  let!(:discussion) { create(:discussion, title: "testing discussion") }
  let!(:trusted_discussion) do
    create(:trusted_discussion, title: "testing trusted discussion")
  end
  let!(:conversation) do
    create(:conversation, title: "testing conversation")
  end

  let(:user) { create(:user) }
  let(:trusted_user) { create(:trusted_user) }

  describe ".search_results" do
    before { Sunspot.commit }

    context "as nobody" do
      subject do
        Discussion.search_results("testing", user: nil, page: 1).results
      end

      it { is_expected.to match_array([discussion]) }
    end

    context "as a regular user" do
      subject do
        Discussion.search_results("testing", user: user, page: 1).results
      end

      it { is_expected.to match_array([discussion]) }
    end

    context "as a trusted user" do
      subject do
        Discussion.search_results("testing", user: trusted_user, page: 1).
          results
      end

      it { is_expected.to match_array([discussion, trusted_discussion]) }
    end
  end
end
