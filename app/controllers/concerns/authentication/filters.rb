# encoding: utf-8

module Authentication
  module Filters
    def requires_authentication(*args)
      self.send(:before_action, *args) do |controller|
        unless Sugar.public_browsing?
          controller.send(:require_user_account)
        end
      end
    end

    def requires_user(*args)
      self.send(:before_action, *args) do |controller|
        controller.send(:require_user_account)
      end
    end

    def requires_admin(*args)
      self.send(:before_action, *args) do |controller|
        controller.send(:verify_user, admin: true)
      end
    end

    def requires_moderator(*args)
      self.send(:before_action, *args) do |controller|
        controller.send(:verify_user, moderator: true)
      end
    end

    def requires_user_admin(*args)
      self.send(:before_action, *args) do |controller|
        controller.send(:verify_user, user_admin: true)
      end
    end
  end
end
