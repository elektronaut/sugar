# encoding: utf-8

require 'spec_helper'

describe SearchableExchange, solr: true do

  let!(:discussion)         { create(:discussion, title: 'testing discussion') }
  let!(:trusted_discussion) { create(:trusted_discussion, title: 'testing trusted discussion') }
  let!(:conversation)       { create(:conversation, title: 'testing conversation') }

  let(:user)                { create(:user) }
  let(:trusted_user)        { create(:trusted_user) }

  describe ".search_results" do
    before { Sunspot.commit }

    context "as nobody" do
      subject { Discussion.search_results('testing', user: nil, page: 1) }
      it { should =~ [discussion] }
    end

    context "as a regular user" do
      subject { Discussion.search_results('testing', user: user, page: 1) }
      it { should =~ [discussion] }
    end

    context "as a trusted user" do
      subject { Discussion.search_results('testing', user: trusted_user, page: 1) }
      it { should =~ [discussion, trusted_discussion] }
    end
  end

end