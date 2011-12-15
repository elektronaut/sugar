require 'spec_helper'

describe Setting do
	describe '#set' do
		it 'creates a new record if necessary' do
			expect { Setting.set('something', true) }.to change{Setting.count}.by(1)
		end

		it 'overwrites the existing record' do
			Setting.set('existing', 'this')
			expect { Setting.set('existing', 'that') }.to change{Setting.count}.by(0)
		end

		it 'saves false as 0' do
			Setting.set('something', false)
			Setting.find_by_key('something').value.should == '0'
		end

		it 'saves true as 1' do
			Setting.set('something', true)
			Setting.find_by_key('something').value.should == '1'
		end

		it 'saves a blank string as nil' do
			Setting.set('something', '')
			Setting.find_by_key('something').value.should be_nil
			Setting.find_by_key('something').value?.should be_false
		end
	end
end