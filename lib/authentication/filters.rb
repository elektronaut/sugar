# encoding: utf-8

module Authentication
  module Filters
    # Requires a user unless public browsing is on
    def requires_authentication(*args)
      self.send(:before_filter, *args) do |controller|
        unless Sugar.public_browsing?
          controller.send(:require_user_account)
        end
      end
    end

    # Requires a logged in user
    def requires_user(*args)
      self.send(:before_filter, *args) do |controller|
        controller.send(:require_user_account)
      end
    end

    # Requires a logged in admin
    def requires_admin(*args)
      self.send(:before_filter, *args) do |controller|
        controller.send(:verify_user, :admin => true)
      end
    end

    # Requires a logged in moderator
    def requires_moderator(*args)
      self.send(:before_filter, *args) do |controller|
        controller.send(:verify_user, :moderator => true)
      end
    end

    # Requires a logged in user admin
    def requires_user_admin(*args)
      self.send(:before_filter, *args) do |controller|
        controller.send(:verify_user, :user_admin => true)
      end
    end
  end
end
