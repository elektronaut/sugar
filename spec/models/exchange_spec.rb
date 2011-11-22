require 'spec_helper'

describe Exchange do
	it { should belong_to :poster }
	it { should belong_to :last_poster }
	it { should have_many :posts }
	it { should have_one  :first_post }
	it { should have_many :discussion_views }

	it { should validate_presence_of(:title)}
	it { should validate_presence_of(:body)}
	
	it "can't have a title longer than 100 characters"

	it "updates the first post if body is changed"
	
	describe 'with no flags' do
		before { @exchange = create(:exchange) }

		it "isn't NSFW" do
			@exchange.nsfw?.should be_false
		end

		it 'has no labels' do
			@exchange.labels?.should be_false
			@exchange.labels.should == []
		end
	end
	
	context 'with the NSFW flag' do
		before { @exchange = create(:exchange, :nsfw => true) }

		it 'is NSFW' do
			@exchange.nsfw?.should be_true
		end
		
		it 'has the sticky label' do
			@exchange.labels.should include('NSFW')
		end
	end
	
end