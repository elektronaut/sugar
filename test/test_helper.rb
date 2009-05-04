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

	setup { Sham.reset }
end
