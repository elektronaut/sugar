# encoding: utf-8

# = Category
#
# All discussions must belong to a category. There's not much functionality
# attached to categories, except that discussions can be browsed by category,
# and categories can be set as only visible to trusted users.
#
# === Trusted categories
# Categories can be flagged as <tt>trusted</tt>, only admins and users set
# as trusted can view these. Use <tt>viewable_by?</tt> to
# determine if a category is visible to a user.

class Category < ActiveRecord::Base
  include HumanizableParam
  include Viewable

  has_many :discussions
  validates_presence_of :name
  acts_as_list

  def labels?
    (self.trusted?) ? true : false
  end

  def labels
    labels = []
    labels << "Trusted" if self.trusted?
    return labels
  end

  def to_param
    self.humanized_param(self.name)
  end

end
