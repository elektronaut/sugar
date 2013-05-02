# encoding: utf-8

require 'spec_helper'

describe DiscussionsController do

  let(:user) { create(:user) }

  # Create the first admin user
  before { create(:user) }

  describe 'with public browsing off' do
    before { Sugar.config(:public_browsing, false); Sugar.save_config! }

    it_requires_login_for :index, :search, :new, :create
    it_requires_login_for :favorites, :following
    it_requires_login_for :show, :edit, :update
    it_requires_login_for :follow, :unfollow, :favorite, :unfavorite
  end

  describe 'with public browsing on' do
    before { Sugar.config(:public_browsing, true); Sugar.save_config! }

    it_requires_login_for :new, :create, :favorites, :following
    it_requires_login_for :edit, :update, :follow, :unfollow, :favorite, :unfavorite

    it 'is open for browsing discussions and posts' do
      discussion = create(:discussion)
      [:index, :show].each do |action|
        get action, :id => discussion
        should respond_with(:success)
      end
    end
  end

  describe 'GET index' do
    before do
      #@discussion = create(:discussion)
      get :index
    end

    specify { assigns(:discussions).should be_a(ActiveRecord::Relation) }
    it { should respond_with(:success) }
    it { should render_template(:index) }

    #it 'finds a discussion' do
    #  assigns(:discussions).to_a.should include(@discussion)
    #end
  end

  describe 'GET show' do
    before do
      @discussion = create(:discussion)
      get :show, :id => @discussion
    end

    specify { assigns(:discussion).should be_a(Discussion) }
    it { should respond_with(:success) }
    it { should render_template(:show) }
  end

  describe 'when part of a conversation' do
    before do
      @user = create(:user)
      @conversation = create(:conversation)
      @conversation.add_participant(@user)
      login @user
    end

    describe 'DELETE remove_participant' do
      before { delete :remove_participant, :id => @conversation }
      specify { flash[:notice].should match(/You have been removed from the conversation/) }
      it 'redirects back to conversations' do
        response.should redirect_to(conversations_url)
      end
      it 'removes the user from the conversation' do
        @conversation.participants.to_a.should_not include(@user)
      end
    end
  end

  describe "GET new" do
    before { login }

    context "when no category exists" do
      before { get :new }
      it { should redirect_to(categories_url) }
      specify { flash[:notice].should match(/Can't create a new discussion, no categories have been made!/) }
    end

    context "Starting a new discussion" do
      let!(:category) { create(:category) }
      before { get :new }
      specify { assigns(:discussion).should be_a(Discussion) }
      it { should render_template(:new) }
    end

    context "Starting a new discussion in a category" do
      let!(:category) { create(:category) }
      before { get :new, category_id: category.id }
      specify { assigns(:discussion).category.should == category }
    end

    context "when starting a conversation with someone" do
      let(:recipient) { create(:user) }
      before { get :new, type: 'conversation', username: recipient.username }
      specify { assigns(:discussion).should be_a(Conversation) }
      it { assigns(:recipient).should == recipient }
      it { should render_template(:new) }
    end
  end

  describe "POST create" do
    before { login }

    context "when no category exists" do
      before { post :create }
      it { should redirect_to(categories_url) }
      specify { flash[:notice].should match(/Can't create a new discussion, no categories have been made!/) }
    end

    context "with invalid params" do
      let!(:category) { create(:category) }
      before { post :create, discussion: { foo: 'bar' } }
      it { should render_template(:new) }
      specify { flash.now[:notice].should match(/Could not save your discussion! Please make sure all required fields are filled in\./) }
    end

    context "when creating a discussion" do
      let!(:category) { create(:category) }
      before { post :create, discussion: { title: 'Test', body: 'Test', category_id: category.id } }
      specify { assigns(:discussion).should be_a(Discussion) }
      it { should redirect_to(discussion_url(assigns(:discussion))) }
    end

    context "when creating a conversation" do
      let(:recipient) { create(:user) }

      before do
        post :create,
             type: 'conversation',
             recipient_id: recipient.id,
             conversation: { title: 'Test', body: 'Test' }
      end

      specify { assigns(:recipient).should be_a(User) }
      specify { assigns(:discussion).should be_a(Conversation) }
      it { should redirect_to(discussion_url(assigns(:discussion))) }
      specify { assigns(:discussion).participants.should include(recipient) }
    end

  end

end
