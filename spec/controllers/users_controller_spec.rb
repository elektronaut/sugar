require 'spec_helper'

describe UsersController do
  describe 'POST create' do
    before do
      attributes = attributes_for(:user)
      @params = {
        :username         => attributes[:username],
        :email            => attributes[:email],
        :password         => 'randompassword',
        :confirm_password => 'randompassword',
        :realname         => attributes[:realname]
      }
    end
    
    describe 'with a valid invite token' do
      before do
        @invite = create(:invite)
        post :create, :token => @invite.token, :user => @params
      end
      
      it { should assign_to(:invite) }
      it { should assign_to(:user) }
      
      it "redirects to the user profile" do
        response.should redirect_to(user_url(:id => assigns(:user).username))
      end
    end
  end
end