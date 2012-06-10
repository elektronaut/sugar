require 'spec_helper'

describe Pagination::Paginater do

  context 'on the 3rd page with 35 items, 10 per page' do
    before { @paginater = Pagination::Paginater.new(:total_count => 35, :per_page => 10, :page => 3) }

    it 'has 4 pages' do
      @paginater.pages.should eq(4)
    end

    it 'has a limit of 10' do
      @paginater.limit.should eq(10)
    end

    it 'has an offset of 20' do
      @paginater.offset.should eq(20)
    end
    
    it 'does not go beyond 4 pages' do
      @paginater.page = 5
      @paginater.page.should eq(4)
    end

    it 'does not go below page 1' do
      @paginater.page = 0
      @paginater.page.should eq(1)
    end
    
    it 'page = :last goes to the last page' do
      @paginater.page = :last
      @paginater.page.should eq(@paginater.pages)
    end

    it 'applies to a collection' do
      collection = [1,2,3,4,5,6,7,8,9,10]
      Pagination.apply(collection, @paginater)
      collection.paginater.should eq(@paginater)
    end
  end
  
  context 'with zero items' do
    before { @paginater = Pagination::Paginater.new(:total_count => 0, :per_page => 10, :page => 1) }

    it 'reports an offset of 0' do
      @paginater.offset.should eq(0)
    end
  end

end