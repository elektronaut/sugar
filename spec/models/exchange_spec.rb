require 'spec_helper'

describe Exchange do
  it { should belong_to :poster }
  it { should belong_to :last_poster }
  it { should have_many :posts }
  it { should have_one  :first_post }
  it { should have_many :discussion_views }

  it { should validate_presence_of(:title)}
  it { should validate_presence_of(:body)}

  let(:exchange) { create(:exchange, :title => 'This is my Discussion', :body => 'First post!') }
  let(:nsfw_exchange) { create(:exchange, :nsfw => true) }

  it "can't have a title longer than 100 characters" do
    build(
      :exchange,
      :title => 'This is a very, very, very, very, very, very, very, very, very, very, very, very, very, very long title'
    ).should have(1).errors_on(:title)
  end

  it "creates a first post when created" do
    exchange.first_post.body.should == 'First post!'
    exchange.first_post.user.should == exchange.poster
  end

  it "updates the first post if body is changed" do
    exchange.update_attributes(:body => 'changed post')
    exchange.first_post.body.should == 'changed post'
  end

  it 'creates a URL slug' do
    exchange.to_param.should =~ /^[\d]+;This\-is\-my\-Discussion$/
  end

  describe 'with no flags' do
    it "isn't NSFW" do
      exchange.nsfw?.should be_false
    end

    it 'has no labels' do
      exchange.labels?.should be_false
      exchange.labels.should == []
    end
  end

  context 'with the NSFW flag' do
    it 'is NSFW' do
      nsfw_exchange.nsfw?.should be_true
    end

    it 'has the NSFW label' do
      nsfw_exchange.labels.should include('NSFW')
    end
  end

end
