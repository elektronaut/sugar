require 'spec_helper'

describe UsersController, redis: true do

  let(:invite) { create(:invite) }

  describe "#new" do
    context "with a valid invite token" do
      before do
        configure signups_allowed: false
        get :new, :token => invite.token
      end
      it { should respond_with(:success) }
      it { should render_template(:new) }
      specify { assigns(:invite).should be_a(Invite) }
      specify { assigns(:user).should be_a(User) }
      specify { assigns(:user).email.should == invite.email }
    end

    context "without a valid invite token" do
      before do
        create(:user) # Ensures the first user exists
        configure signups_allowed: false
        get :new
      end
      specify { flash[:notice].should match("Signups are not allowed") }
      it { should redirect_to(login_users_url) }
    end
  end

  describe "#create" do
    let(:params) {
      attributes = attributes_for(:user)
      {
        username:         attributes[:username],
        email:            attributes[:email],
        password:         'randompassword',
        confirm_password: 'randompassword',
        realname:         attributes[:realname]
      }
    }

    context 'with a valid invite token' do
      before { post :create, :token => invite.token, :user => params }

      specify { assigns(:invite).should be_a(Invite) }
      specify { assigns(:user).should be_a(User) }
      it { should redirect_to(user_url(:id => assigns(:user).username)) }
    end
  end
end