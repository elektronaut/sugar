class MessagesController < ApplicationController

	requires_authentication

	def update_read_status
		if @messages && @messages.length > 0
			@messages.each{ |m| m.update_attribute(:read, true) if !m.read? && m.recipient == @current_user }
		end
	end
	protected    :update_read_status
	after_filter :update_read_status, :only => [:index, :conversations]

	def index
		respond_to do |format|
			format.html   { @users = @current_user.paginated_conversation_partners(:page => params[:page]) }
			format.iphone { @users = @current_user.conversation_partners }
		end
	end

	def conversations
		@user = User.find_by_username(params[:username])
		unless @user
			flash[:notice] = "Cannot find that user!"
			redirect_to messages_url and return
		end
		@messages = @current_user.paginated_conversation(:page => params[:page], :user => @user)
		@new_message = @user.messages.new(:subject => params[:subject])
	end

	def create
		@user = User.find(params[:message][:recipient_id]) rescue nil
		unless @user
			flash[:notice] = "No such user found!"
			redirect_to messages_url and return
		end
		@message = @current_user.sent_messages.create(params[:message])
		@message.reload
		if @message.recipient.notify_on_message?
			begin
				Notifications.deliver_new_message(@message, last_user_conversation_page_url(:username => @message.sender.username, :anchor => "message-#{@message.id}"))
			rescue
				logger.error "Message to #{@message.recipient.full_email} could not be sent."
			end
		end
		flash[:notice] = "Your message was sent"
		redirect_to last_user_conversation_page_url(:username => @message.recipient.username, :anchor => "message-#{@message.id}")
	end

end
