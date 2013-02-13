# encoding: utf-8

require 'spec_helper'

describe SearchablePost do

  let(:post) { create(:post) }

  describe ".search_paginated" do

    let(:search_results) { double(results: [post], total: 2) }

    subject { Post.search_paginated(query: "Bacon") }
    it { should be_kind_of(Pagination::InstanceMethods) }

    context "with solr", solr: true do
      it { should == [] }
    end

    context "with stubbed search engine" do

      before do
        Post.stub(:search).and_return(search_results)
      end

      it { should include(post) }

      context "with option" do

        describe :page do

          context "when not specified" do
            subject { Post.search_paginated(query: "Bacon", limit: 1) }
            its(:page) { should == 1 }
          end

          context "when specified" do
            subject { Post.search_paginated(query: "Bacon", limit: 1, page: 2) }
            its(:page) { should == 2 }
          end

        end

        describe :limit do

          context "when not specified" do
            its(:per_page) { should == Post.per_page }
          end

          context "when specified" do
            subject { Post.search_paginated(query: "Bacon", limit: 7) }
            its(:per_page) { should == 7 }
          end

        end

      end

    end

  end

end