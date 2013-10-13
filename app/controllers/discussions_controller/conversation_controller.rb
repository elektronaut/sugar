class DiscussionsController < ApplicationController
  module ConversationController
    extend ActiveSupport::Concern

    included do
      before_filter :find_recipient, only: [:create]
    end

    def conversations
      @section = :conversations
      @exchanges = current_user.conversations.page(params[:page]).for_view
      load_views_for(@exchanges)
      render template: "conversations/index"
    end

    # Invite a participant
    def invite_participant
      if @exchange.kind_of?(Conversation) && params[:username]
        usernames = params[:username].split(/\s*,\s*/)
        usernames.each do |username|
          if user = User.find_by_username(username)
            @exchange.add_participant(user)
          end
        end
      end
      if request.xhr?
        render template: 'conversations/participants', layout: false
      else
        redirect_to discussion_url(@exchange)
      end
    end

    # Remove participant from discussion
    def remove_participant
      if @exchange.kind_of?(Conversation)
        @exchange.remove_participant(current_user)
        flash[:notice] = 'You have been removed from the conversation'
        redirect_to conversations_url and return
      end
    end

    private

    def find_recipient
      if params[:recipient_id]
        begin
          @recipient = User.find(params[:recipient_id])
        rescue ActiveRecord::RecordNotFound
          @recipient = nil
        end
      end
    end

  end
end