class Notifications < ActionMailer::Base
  
	def self.default_sender
		Sugar.config(:mail_sender)
	end

	def default_options
		@recipients ||= Notifications.default_sender
		@from       ||= Notifications.default_sender
		@cc         ||= ""
		@bcc        ||= ""
		@subject    ||= ""
		@body       ||= {}
		@headers    ||= {}
		@charset    ||= "utf-8"
		@sent_on    ||= Time.now
	end

    def password_reminder(user, login_url)
        default_options
		@subject    = "Your login details at #{Sugar.config(:forum_name)}"
		@body       = { :user => user, :login_url => login_url }
		@recipients = user.full_email
	end
	
	def invite(invite, login_url)
		default_options
		@subject    = "#{invite.user.realname_or_username} has invited you to #{Sugar.config(:forum_name)}!"
		@body       = {:invite => invite, :login_url => login_url}
		@recipients = invite.email
	end

    def new_user(user, login_url)
        default_options
		@subject    = "Welcome to #{Sugar.config(:forum_name)}!"
		@body       = { :user => user, :login_url => login_url}
		@recipients = user.full_email
    end
    
	def welcome(user)
	    default_options
		@subject    = "Welcome to #{Sugar.config(:forum_name)}!"
		@body       = { :user => user }
		@recipients = user.full_email
    end

	def new_message(message, url)
		default_options
		if message.subject?
			@subject = "Message from #{message.sender.username}: #{message.subject}"
		else
			@subject = "Message from #{message.sender.username}"
		end
		@body       = {:message => message, :url => url}
		@recipients = message.recipient.full_email
	end

end
