# encoding: utf-8

require 'spec_helper'

describe InvitesController do

  # Create the first admin user
  before { create(:user) }

  let(:invite)            { create(:invite) }
  let(:expired_invite)    { create(:invite, expires_at: 2.days.ago) }
  let(:user)              { create(:user) }
  let(:user_with_invites) { create(:user, available_invites: 1) }

  it_requires_login_for :index, :all, :new, :create, :destroy
  it_requires_user_admin_for :all


  describe "#load_invite" do
    before do
      login invite.user
      delete :destroy, id: invite_id
    end

    context "when invite exists" do
      let(:invite_id) { invite.id }
      specify { assigns(:invite).should be_a(Invite) }
    end

    context "when invite doesn't exist" do
      let(:invite_id) { 1231115 }
      specify { assigns(:invite).should be_nil }
      it { should respond_with(404) }
    end
  end

  describe "#verify_invites" do
    before { login(user); get :new }

    context "when user has invites" do
      let(:user) { create(:user, available_invites: 1) }
      it { should respond_with(:success) }
      specify { flash[:notice].should be_nil }
    end

    context "when user is user admin" do
      let(:user) { create(:user_admin) }
      it { should respond_with(:success) }
      specify { flash[:notice].should be_nil }
    end

    context "when user doesn't have any invites" do
      let(:user) { create(:user, available_invites: 0) }
      specify { flash[:notice].should match(/You don't have any invites!/) }
      it { should respond_with(:redirect) }
    end
  end

  describe "GET index" do
    let!(:invites) { [create(:invite, user: user), create(:invite)] }
    before { login(user); get :index }

    it { should respond_with(:success) }
    it { should render_template(:index) }
    specify { flash[:notice].should be_nil }
    specify { assigns(:invites).should =~ [invites.first] }
  end

  describe "GET all" do
    let(:user) { create(:user_admin) }
    let!(:invites) { [create(:invite, user: user), create(:invite)] }

    before { login(user); get :all }

    it { should respond_with(:success) }
    it { should render_template(:all) }
    specify { assigns(:invites).should =~ invites }
  end

  describe "GET accept" do
    before { get :accept, id: token }

    context "when invite is valid" do
      let(:token) { invite.token }
      specify { flash[:notice].should be_nil }
      specify { session[:invite_token].should == invite.token }
      it "redirects to the signup page" do
        response.should redirect_to(new_user_by_token_url(:token => invite.token))
      end
    end

    context "when invite is expired" do
      let(:token) { expired_invite.token }
      specify { flash[:notice].should match(/Your invite has expired!/) }
      specify { session[:invite_token].should be_nil }
      it "redirects to the login page" do
        response.should redirect_to(login_users_url)
      end
    end

    context "when invite doesn't exist" do
      let(:token) { "invalid token" }
      specify { flash[:notice].should match(/That's not a valid invite!/) }
      specify { session[:invite_token].should be_nil }
      it "redirects to the login page" do
        response.should redirect_to(login_users_url)
      end
    end
  end

  describe "GET new" do
    before { login(user_with_invites); get :new }
    it { should respond_with(:success) }
    it { should render_template(:new) }
    specify { assigns(:invite).should be_a(Invite) }
  end

  describe "POST create" do
    before { login(user_with_invites) }

    context "with valid params" do
      before do
        post :create, invite: {
          email:   'no-reply@example.com',
          message: 'testing message'
        }
      end

      specify { assigns(:invite).should be_a(Invite) }
      specify { flash[:notice].should match(/Your invite has been sent to no\-reply@example\.com/) }

      specify { last_email.to.should == ['no-reply@example.com'] }
      specify { last_email.body.encoded.should match('testing message') }

      it { should redirect_to(invites_url) }
    end

    context "when email is invalid" do
      before do
        Mailer.stub(:invite) { raise Net::SMTPSyntaxError }
        post :create, invite: {
          email:   'totally@wrong.com',
          message: 'testing message'
        }
      end

      specify { flash[:notice].should match("There was a problem sending your invite to totally@wrong.com, it has been cancelled.") }
      it { should redirect_to(invites_url) }

      it "should not send an email" do
        last_email.should be_nil
      end

      it "should not create an invite" do
        Invite.count.should == 0
      end
    end

    context "with invalid params" do
      before { post :create, invite: { foo: 'bar' } }
      specify { assigns(:invite).should be_a(Invite) }
      it { should respond_with(:success) }
      it { should render_template(:new) }
    end
  end

  describe "DELETE destroy" do
    context "when user owns the invite" do
      before { login(invite.user) and delete(:destroy, id: invite.id) }

      specify { assigns(:invite).should be_a(Invite) }
      specify { assigns(:invite).destroyed?.should be_true }

      it "redirects to the invites page" do
        response.should redirect_to(invites_url)
      end
    end

    context "when user doesn't own the invite" do
      before { login(user) and delete(:destroy, id: invite.id) }

      specify { assigns(:invite).should be_a(Invite) }
      specify { assigns(:invite).destroyed?.should be_false }

      it "redirects to the discussions page" do
        response.should redirect_to(discussions_url)
      end
    end
  end

end
