require 'spec_helper'

describe Discussion do
	it { should be_kind_of(Exchange) }
	it { should belong_to :closer }

	it "can't be changed if closed by someone else"
	
	it "updates closer_id when closed"

	context 'with the sticky flag' do
		before { @discussion = create(:discussion, :sticky => true) }

		it 'is sticky' do
			@discussion.sticky?.should be_true
		end
		
		it 'has the sticky label' do
			@discussion.labels.should include('Sticky')
		end
	end
	
end