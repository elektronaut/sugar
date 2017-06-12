# encoding: utf-8

require "rails_helper"

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
      get :show, params: { id: conversation_with_user }
    end

    specify { expect(assigns(:exchange)).to be_a(Conversation) }
    it { is_expected.to respond_with(:success) }
    it { is_expected.to render_template(:show) }
  end

  describe "DELETE remove_participant" do
    let(:remover) { create(:moderator) }

    before { conversation_with_user.add_participant(remover) }

    before do
      login(remover)
      delete(
        :remove_participant,
        params: {
          id: conversation_with_user,
          username: user.username
        }
      )
    end

    context "when removing self" do
      let(:remover) { user }

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

    context "when removing someone else" do
      specify do
        expect(flash[:notice]).to eq(
          "#{user.username} has been removed from the conversation"
        )
      end

      it "redirects back to the conversation" do
        expect(response).to redirect_to(conversation_url(assigns(:exchange)))
      end

      it "removes the user from the conversation" do
        expect(assigns(:exchange).participants.to_a).not_to include(user)
      end
    end

    context "when removing someone else without privileges" do
      let(:remover) { create(:user) }

      specify do
        expect(flash[:error]).to eq("You can't do that!")
      end

      it "redirects back to the conversation" do
        expect(response).to redirect_to(conversation_url(assigns(:exchange)))
      end

      it "should not remove the user from the conversation" do
        expect(assigns(:exchange).participants.to_a).to include(user)
      end
    end
  end

  describe "GET new" do
    before { login }

    context "when starting a conversation with someone" do
      let(:recipient) { create(:user) }
      before { get :new, params: { type: "conversation", username: recipient.username } }
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
             params: {
               recipient_id: recipient.id,
               conversation: { title: "Test", body: "Test" }
             }
      end

      specify { expect(assigns(:recipient)).to be_a(User) }
      specify { expect(assigns(:exchange)).to be_a(Conversation) }
      it { is_expected.to redirect_to(conversation_url(assigns(:exchange))) }
      specify { expect(assigns(:exchange).participants).to include(recipient) }
    end
  end

  describe "GET mute" do
    let(:user) { create(:user) }
    let(:conversation) { create(:conversation) }
    before do
      conversation.add_participant(user)
      login(user)
      get :mute, params: { id: conversation.id, page: 2 }
    end

    it "should mute the conversation" do
      expect(user.muted_conversation?(conversation)).to eq(true)
    end

    it "should redirect back to the conversation" do
      expect(subject).to redirect_to(
        conversation_url(assigns(:exchange), page: 2)
      )
    end
  end

  describe "GET unmute" do
    let(:user) { create(:user) }
    let(:conversation) { create(:conversation) }
    before do
      conversation.add_participant(user)
      user.conversation_relationships.update_all(notifications: false)
      login(user)
      get :unmute, params: { id: conversation.id, page: 2 }
    end

    it "should mute the conversation" do
      expect(user.muted_conversation?(conversation)).to eq(false)
    end

    it "should redirect back to the conversation" do
      expect(subject).to redirect_to(
        conversation_url(assigns(:exchange), page: 2)
      )
    end
  end
end
