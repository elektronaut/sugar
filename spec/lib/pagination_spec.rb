require 'spec_helper'

describe 'A collection run through Pagination.paginate' do
  
  context 'on page 3' do
    before do
      @collection = Pagination.paginate(:total_count => 95, :per_page => 10, :page => 3){[1,2,3,4,5,6,7,8,9,10]}
    end
  
    it 'retains it original object type' do
      @collection.should be_kind_of(Enumerable)
    end
  
    it 'has Pagination::InstanceMethods mixed in' do
      @collection.should be_kind_of(Pagination::InstanceMethods)
    end
  
    it 'delegates to paginater' do
      [:total_count, :pages, :page, :per_page, :offset].each do |delegated_method|
        @collection.send(delegated_method).should eq(@collection.paginater.send(delegated_method))
      end
    end
  
    it 'has a first page' do
      @collection.first_page.should eq(1)
    end

    it 'has a last page' do
      @collection.last_page.should eq(10)
    end

    it 'is not on the first page' do
      @collection.first_page?.should be_false
    end

    it 'is not on the last page' do
      @collection.last_page?.should be_false
    end
  
    it 'has a next page' do
      @collection.next_page?.should be_true
    end

    it 'has a previous page' do
      @collection.previous_page?.should be_true
    end

    it 'responds to next page with 4' do
      @collection.next_page.should eq(4)
    end
  
    it 'responds to previous page with 2' do
      @collection.previous_page.should eq(2)
    end
    
    it 'reports its nearest pages' do
      @collection.nearest_pages(3).should eq([2,3,4])
      @collection.nearest_pages(7).should eq([1,2,3,4,5,6,7])
    end

  end
  
  context 'on the first page' do
    before do
      @collection = Pagination.paginate(:total_count => 95, :per_page => 10, :page => 1){[1,2,3,4,5,6,7,8,9,10]}
    end
    
    it 'is on the first page' do
      @collection.first_page?.should be_true
    end
    
    it 'does not have a previous page' do
      @collection.previous_page?.should be_false
      @collection.previous_page.should be_nil
    end
    
    it 'reports its nearest pages' do
      @collection.nearest_pages(3).should eq([1,2,3])
    end
  end

  context 'on the last page' do
    before do
      @collection = Pagination.paginate(:total_count => 95, :per_page => 10, :page => :last){[1,2,3,4,5,6,7,8,9,10]}
    end
    
    it 'is on the last page' do
      @collection.last_page?.should be_true
    end
    
    it 'does not have a next page' do
      @collection.next_page?.should be_false
      @collection.next_page.should be_nil
    end
    
    it 'reports its nearest pages' do
      @collection.nearest_pages(3).should eq([8,9,10])
    end
  end

end
