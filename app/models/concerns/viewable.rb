module Viewable
  extend ActiveSupport::Concern

  module ClassMethods
    def viewable_by(user)
      if user && user.trusted?
        all
      else
        where(trusted: false)
      end
    end
  end

  # Returns true if the user can view this record
  def viewable_by?(user)
    if self.trusted?
      (user && user.trusted?) ? true : false
    else
      (Sugar.public_browsing? || user) ? true : false
    end
  end
end
