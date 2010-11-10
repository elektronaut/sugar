module Authentication
	class << self
		# Applies functionality to a controller
		def setup_controller(controller)
			controller.send :extend,  Authentication::Filters
			controller.send :include, Authentication::Facebook
			controller.send :include, Authentication::OpenID
			controller.send :include, Authentication::Controller
		end
		
		def included(base)
			setup_controller(base)
		end
	end
end