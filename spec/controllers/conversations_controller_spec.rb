# encoding: utf-8

require "spec_helper"

describe ConversationsController do
  let(:user) { create(:user) }
  let(:conversation_with_user) do
    conversation = create(:conversation)
    conversation.add_participant(user)
    conversation
  end

  # Create the first admin user
  before { create(:user) }

  it_requires_login_for :index, :search_posts, :new, :create
  it_requires_login_for :show, :edit, :update
  it_requires_login_for :invite_participant, :remove_participant

  describe "GET index" do
    before do
      login(user)
      get :index
    end

    specify { expect(assigns(:exchanges)).to be_a(ActiveRecord::Relation) }
    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template(:index) }
  end

  describe "GET show" do
    before do
      login(user)
      get :show, id: conversation_with_user
    end

    specify { expect(assigns(:exchange)).to be_a(Conversation) }
    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template(:show) }
  end

  describe "DELETE remove_participant" do
    before do
      login(user)
      delete :remove_participant, id: conversation_with_user
    end

    specify do
      expect(flash[:notice]).to match(
        /You have been removed from the conversation/
      )
    end

    it "redirects back to conversations" do
      expect(response).to redirect_to(conversations_url)
    end

    it "removes the user from the conversation" do
      expect(assigns(:exchange).participants.to_a).not_to include(user)
    end
  end

  describe "GET new" do
    before { login }

    context "when starting a conversation with someone" do
      let(:recipient) { create(:user) }
      before { get :new, type: "conversation", username: recipient.username }
      specify { expect(assigns(:exchange)).to be_a(Conversation) }
      specify { expect(assigns(:recipient)).to eq(recipient) }
      it { is_expected.to render_template(:new) }
    end
  end

  describe "POST create" do
    before { login }

    context "when creating a conversation" do
      let(:recipient) { create(:user) }

      before do
        post :create,
             recipient_id: recipient.id,
             conversation: { title: "Test", body: "Test" }
      end

      specify { expect(assigns(:recipient)).to be_a(User) }
      specify { expect(assigns(:exchange)).to be_a(Conversation) }
      it { is_expected.to redirect_to(conversation_url(assigns(:exchange))) }
      specify { expect(assigns(:exchange).participants).to include(recipient) }
    end
  end
end
