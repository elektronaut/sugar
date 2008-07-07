class MessagesController < ApplicationController
    
    requires_authentication

    def update_read_status
        if @messages && @messages.length > 0
            @messages.each{ |m| m.update_attribute(:read, true) if !m.read? && m.recipient == @current_user }
        end
    end
    protected    :update_read_status
    #after_filter :update_read_status, :only => [:index, :conversation]

    def index
        @messages = @current_user.paginated_messages(:page => params[:page])
    end
    
    def outbox
        @messages = @current_user.paginated_sent_messages(:page => params[:page])
    end
    
    def conversations
        @user = User.find_by_username(params[:username])
        unless @user
            flash[:notice] = "Cannot find that user!"
            redirect_to messages_url and return
        end
        @messages = @current_user.paginated_conversation(:page => params[:page], :user => @user)
    end
    
    def create
        @user = User.find(params[:message][:recipient_id]) rescue nil
        unless @user
            flash[:notice] = "No such user found!"
            redirect_to messages_url and return
        end
        @message = @current_user.sent_messages.create(params[:message])
        @message.reload
        flash[:notice] = "Your message was sent"
        redirect_to last_user_conversation_page_url(:username => @message.recipient.username, :anchor => "message-#{@message.id}")
    end

end
