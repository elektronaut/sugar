# frozen_string_literal: true

module Authentication
  class << self
    # Applies the functionality to a controller
    def setup_controller(controller)
      controller.send :extend,  Authentication::Filters
      controller.send :include, Authentication::Controller
      controller.send :include, Authentication::VerifyUser
    end

    def included(base)
      setup_controller(base)
    end
  end
end
