# encoding: utf-8

require 'spec_helper'

describe SearchableExchange do

  let(:discussion) { create(:discussion) }

  describe ".search_paginated" do

    let(:search_results) { double(results: [discussion], total: 2) }
    subject { Discussion.search_paginated(query: "Bacon") }

    context "with solr", solr: true do
      it { should == [] }
    end

    context "with stubbed search" do

      before do
        Discussion.stub(:search).and_return(search_results)
      end

      it { should be_kind_of(Pagination::InstanceMethods) }
      it { should include(discussion) }

      context "with options" do

        describe :page do

          context "when not specified" do
            subject { Discussion.search_paginated(query: "Bacon", limit: 1) }
            its(:page) { should == 1 }
          end

          context "when specified" do
            subject { Discussion.search_paginated(query: "Bacon", limit: 1, page: 2) }
            its(:page) { should == 2 }
          end

        end

        describe :limit do

          context "when not specified" do
            its(:per_page) { should == Exchange::DISCUSSIONS_PER_PAGE }
          end

          context "when specified" do
            subject { Discussion.search_paginated(query: "Bacon", limit: 7) }
            its(:per_page) { should == 7 }
          end

        end

      end

    end

  end

end