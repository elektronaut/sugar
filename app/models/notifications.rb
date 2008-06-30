class Notifications < ActionMailer::Base
  
	def self.default_sender
		"Butt3rscotch <no-reply@butt3rscotch.org>"
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
		@subject    = "Your login details at B3S"
		@body       = { :user => user, :login_url => login_url }
		@recipients = user.full_email
	end
	
	def welcome(user)
	    default_options
		@subject    = "Welcome to B3S 2.0!"
		@body       = { :user => user }
		@recipients = user.full_email
    end

end
