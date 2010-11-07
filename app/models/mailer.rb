class Mailer < ActionMailer::Base
  
	def self.default_sender
		Sugar.config(:mail_sender)
	end

	# Send an invite
	def invite(invite, login_url)
		@invite    = invite
		@login_url = login_url
		mail(
			:to      => @invite.email,
			:from    => Mailer.default_sender,
			:subject => "#{@invite.user.realname_or_username} has invited you to #{Sugar.config(:forum_name)}!"
		)
	end

	# Notifies user on new message
	# TODO: This is not in use
	def new_message(message, url)
		@message = message
		@url     = url
		if message.subject?
			subject = "Message from #{@message.sender.username}: #{@message.subject}"
		else
			subject = "Message from #{@message.sender.username}"
		end
		mail(
			:to      => @message.recipient.full_email,
			:from    => Mailer.default_sender,
			:subject => subject
		)
	end

	# Send a welcome mail to a new user
	def new_user(user, login_url)
		@user      = user
		@login_url = login_url
		mail(
			:to      => @user.full_email,
			:from    => Mailer.default_sender,
			:subject => "Welcome to #{Sugar.config(:forum_name)}!"
		)
    end
    
	# Send a password reminder
	def password_reminder(user, login_url)
		@user      = user
		@login_url = login_url
		mail(
			:to      => @user.full_email,
			:from    => Mailer.default_sender,
			:subject => "Your login details at #{Sugar.config(:forum_name)}"
		)
	end
	
	# Deliver welcome message
	# TODO: This is not in use
	def welcome(user)
		@user = user
		mail(
			:to      => @user.full_email,
			:from    => Mailer.default_sender,
			:subject => "Welcome to #{Sugar.config(:forum_name)}!"
		)
    end

end
