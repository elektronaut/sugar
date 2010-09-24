ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
	#self.use_transactional_fixtures = true
	self.use_instantiated_fixtures  = false
	#fixtures :all

	def populate_application(options={})
		@normal_category = Factory(:category)
		@trusted_category = Factory(:category, :trusted => true)
		3.times{ Factory(:discussion, :category => @normal_category) }
		3.times{ Factory(:discussion, :category => @trusted_category) }
	end

	def login_session(user=Factory(:user))
		@current_user = user
		session[:user_id] = @current_user.id
		session[:hashed_password] = @current_user.hashed_password
		session[:ips] = ['0.0.0.0']
	end
	
end