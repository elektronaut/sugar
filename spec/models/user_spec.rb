# encoding: utf-8

require 'spec_helper'

describe User do

  it "should allow usernames with unicode characters" do
    user = build(:user, :username => 'Gustave Moíre')
    user.should be_valid
  end

  it "should not allow usernames with invalid characters" do
    user = build(:user, :username => '";Bobby Tables')
    user.should_not be_valid
  end

  context 'with no special privileges' do
    before do
      @user = create(:user)
    end

    it "shouldn't be marked as admin" do
      @user.admin?.should be_false
      @user.moderator?.should be_false
      @user.user_admin?.should be_false
      @user.trusted?.should be_false
    end
  end
end
