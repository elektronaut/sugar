require 'spec_helper'

describe Category do
  it { should have_many(:discussions) }
  it { should validate_presence_of(:name) }

  let(:category) { create(:category, :name => 'This is my Category') }
  let(:trusted_category) { create(:trusted_category) }

  let(:user) { create(:user) }
  let(:trusted_user) { create(:trusted_user) }

  it 'creates a URL slug' do
    category.to_param.should =~ /^[\d]+;This\-is\-my\-Category$/
  end

  describe '#find_viewable_by' do
    before do
      category
      trusted_category
    end

    it 'only finds non-trusted categories for normal users' do
      Category.find_viewable_by(user).should include(category)
      Category.find_viewable_by(user).should_not include(trusted_category)
    end

    it 'finds all categories for trusted users' do
      Category.find_viewable_by(trusted_user).should include(category)
      Category.find_viewable_by(trusted_user).should include(trusted_category)
    end
  end

  context 'with normal attributes' do
    it 'has no labels' do
      category.labels?.should be_false
      category.labels.should == []
    end
  end

  context 'with the trusted flag set' do
    it 'is trusted' do
      trusted_category.trusted?.should be_true
    end

    it 'has the trusted label' do
      trusted_category.labels?.should be_true
      trusted_category.labels.should include('Trusted')
    end

    it 'is not viewable by regular users' do
      trusted_category.viewable_by?(user).should be_false
    end

    it 'is viewable by trusted users and administrators' do
      trusted_category.viewable_by?(create(:user, :trusted => true)).should be_true
      trusted_category.viewable_by?(create(:user, :admin => true)).should be_true
      trusted_category.viewable_by?(create(:user, :moderator => true)).should be_true
      trusted_category.viewable_by?(create(:user, :user_admin => true)).should be_true
    end
  end

  it 'changes the trusted status on discussions' do
    create(:discussion, :category => category)
    category.discussions.first.trusted?.should == false
    category.update_attributes(:trusted => true)
    category.discussions.first.trusted?.should == true
    category.update_attributes(:trusted => false)
    category.discussions.first.trusted?.should == false
  end

  context 'several categories' do
    it 'acts as a list' do
      5.times { create(:category) }
      categories = Category.order(:position).all
      categories.length.should == 5
      categories.map(&:position).should == (1..categories.length).to_a
    end
  end

end
