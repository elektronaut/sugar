require 'spec_helper'

describe Invite do
  it { should belong_to(:user) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:user_id) }
  
  describe '#create' do
    before do
      @invite = create(:invite)
    end

    it 'should have an expiration date 14 days into the future' do
      @invite.expires_at.should be_within(30).of(Time.now + 14.days)
    end

    it "verifies that the user isn't registered" do
      user = create(:user, :email => 'foo@bar.com')
      invite = build(:invite, :email => 'foo@bar.com')
      invite.valid?.should be_false
      invite.should have(1).errors_on(:email)
    end
    
    it "verifies that the email isn't already invited" do
      invite = build(:invite, :email => @invite.email)
      invite.valid?.should be_false
      invite.should have(1).errors_on(:email)
    end
    
    it 'revokes an invite from the inviter' do
      inviter = create(:user, :available_invites => 5)
      expect { create(:invite, :user => inviter) }.to change{inviter.available_invites}.by(-1)
    end
    
    it 'generates a token of at least 40 characters' do
      @invite.token?.should be_true
      @invite.token.should be_kind_of(String)
      @invite.token.length.should >= 40
    end
  end
  
  describe '#destroy' do
    it 'grants the inviter a new invite' do
      invite = create(:invite)
      expect { invite.destroy }.to change{invite.user.available_invites}.by(1)
    end
  end
  
  describe '#find_active' do
    before do
      5.times { create(:invite) }
      5.times { create(:invite, :expires_at => 2.days.ago) }
      @invites = Invite.find_active
    end

    it 'finds all active invites' do
      @invites.length.should == 5
    end

    it 'does not find expired invites' do
      @invites.select(&:expired?).length == 0
    end
  end

  describe '#find_expired' do
    before do
      5.times { create(:invite) }
      5.times { create(:invite, :expires_at => 2.days.ago) }
      @invites = Invite.find_expired
    end

    it 'finds all expired invites' do
      @invites.length.should == 5
    end

    it 'finds only expired invites' do
      @invites.select(&:expired?).length == 5
    end
  end

  context 'expired' do
    before do
      @invite = create(:invite, :expires_at => 2.days.ago)
    end

    it 'is expired' do
      @invite.expired?.should be_true
    end

    it 'is cleaned up by destroy_expired!' do
      expect { Invite.destroy_expired! }.to change{Invite.count}.by(-1)
    end
  end
  
end