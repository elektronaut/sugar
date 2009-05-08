require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class PaginationTest < ActiveSupport::TestCase

	context "A Paginater" do
		setup { @paginater = Pagination::Paginater.new(:total_count => 35, :per_page => 10, :page => 3) }   

		should "report the correct number of pages" do
			assert_equal 4, @paginater.pages
		end

		should "report the correct limit" do
			assert_equal 10, @paginater.limit
		end

		should "report the correct offset" do
			assert_equal 20, @paginater.offset
		end

		should "stay within 4 pages" do
			@paginater.page = 0
			assert_equal 1, @paginater.page
			@paginater.page = 5
			assert_equal 4, @paginater.page
		end

		should "should report the last page for :last" do
			@paginater.page = :last
			assert_equal @paginater.pages, @paginater.page
		end

		should "apply to a collection" do
			collection = [1,2,3,4,5,6,7,8,9,10]
			assert Pagination.apply(collection, @paginater)
			assert_equal @paginater, collection.paginater
		end

		context "with zero items" do
			setup { @paginater = Pagination::Paginater.new(:total_count => 0, :per_page => 10, :page => 1) }

			should "report an offset of 0" do
				assert_equal 0, @paginater.offset
			end
		end
	end

	context "A collection fetched with Pagination.paginate" do
		context "on page 3" do
			setup { @collection = Pagination.paginate(:total_count => 95, :per_page => 10, :page => 3){[1,2,3,4,5,6,7,8,9,10]} }

			should "be an Enumerable" do 
				assert @collection.kind_of?(Enumerable)
			end

			should "have Pagination::InstanceMethods mixed in" do 
				assert @collection.kind_of?(Pagination::InstanceMethods)
			end

			should "delegate to paginater" do
				assert_equal @collection.paginater.total_count, @collection.total_count
				assert_equal @collection.paginater.pages, @collection.pages
				assert_equal @collection.paginater.page, @collection.page
				assert_equal @collection.paginater.per_page, @collection.per_page
				assert_equal @collection.paginater.offset, @collection.offset
			end

			should "have previous and next pages" do
				assert_equal true, @collection.next_page?
				assert_equal true, @collection.previous_page?
			end

			should "report next and previous page" do
				assert_equal 4, @collection.next_page
				assert_equal 2, @collection.previous_page
			end

			should "report first and last page" do
				assert_equal 1, @collection.first_page
				assert_equal 10, @collection.last_page
			end

			should "not be on the first or last page" do
				assert !@collection.first_page?
				assert !@collection.last_page?
			end

			should "report it's nearest pages" do
				assert_same_elements [2,3,4], @collection.nearest_pages(3)
				assert_same_elements [1,2,3,4,5,6,7], @collection.nearest_pages(7)
			end
		end

		context "on the first page" do
			setup { @collection = Pagination.paginate(:total_count => 95, :per_page => 10, :page => 1){[1,2,3,4,5,6,7,8,9,10]} }

			should "be on the first page" do
				assert @collection.first_page?
			end

			should "not have a previous page" do
				assert !@collection.previous_page?
				assert_equal nil, @collection.previous_page
			end

			should "report it's nearest pages" do
				assert_same_elements [1,2,3], @collection.nearest_pages(3)
			end
		end

		context "on the last page" do
			setup { @collection = Pagination.paginate(:total_count => 95, :per_page => 10, :page => :last){[1,2,3,4,5,6,7,8,9,10]} }

			should "be on the last page" do
				assert_equal 10, @collection.pages
				assert @collection.last_page?
			end

			should "not have a next page" do
				assert !@collection.next_page?
				assert_equal nil, @collection.next_page
			end

			should "report it's nearest pages" do
				assert_same_elements [8,9,10], @collection.nearest_pages(3)
			end
		end
	end

end
