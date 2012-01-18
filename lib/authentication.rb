# encoding: utf-8

# To include the authentication subsystem, all you have to do is
# include it in your ApplicationController:
#
#  class ApplicationController < ActionController::Base
#    include Authentication
#  end

module Authentication
	class << self
		# Applies the functionality to a controller
		def setup_controller(controller)
			controller.send :extend,  Authentication::Filters
			controller.send :include, Authentication::OpenID
			controller.send :include, Authentication::Controller
		end

		def included(base)
			setup_controller(base)
		end
	end
end