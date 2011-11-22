require 'spec_helper'

describe Discussion do
	it { should be_kind_of(Exchange) }
	it { should belong_to :closer }

	it "can't be reopened if closed by someone else" do
		discussion = create(:discussion)
		discussion.update_attributes(:closed => true, :updated_by => create(:moderator))

		discussion.update_attributes(:closed => false, :updated_by => discussion.poster)
		discussion.should have(1).errors_on(:closed)
	end
	
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