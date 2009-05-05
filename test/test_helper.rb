ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

require File.expand_path(File.dirname(__FILE__) + "/blueprint")

class ActiveSupport::TestCase
	#self.use_transactional_fixtures = true
	self.use_instantiated_fixtures  = false
	#fixtures :all

	def populate_application(options={})
		regular_categories = (1..5).map{ Category.make }
		trusted_categories = (1..2).map{ Category.make(:trusted) }
		all_categories = regular_categories + trusted_categories
	end

	def login_session(user=User.make)
		@current_user = user
		session[:user_id] = @current_user.id
		session[:hashed_password] = @current_user.hashed_password
		session[:ips] = ['0.0.0.0']
	end
	
	setup { Sham.reset }
end
