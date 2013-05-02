# encoding: utf-8

# = Category
#
# All discussions must belong to a category. There's not much functionality
# attached to categories, except that discussions can be browsed by category,
# and categories can be set as only visible to trusted users.
#
# === Trusted categories
# Categories can be flagged as <tt>trusted</tt>, only admins and users set
# as trusted can view discussions in these. Use <tt>viewable_by?</tt> to
# determine if a category is visible to a user.

class Category < ActiveRecord::Base
  include HumanizableParam
  include Viewable

  has_many :discussions
  validates_presence_of :name
  acts_as_list

  # Flag for trusted status, which will update after save if it has been changed.
  attr_accessor :update_trusted

  before_update do |category|
    category.update_trusted = true if category.trusted_changed?
  end

  after_save do |category|
    if category.update_trusted
      category.discussions.update_all(:trusted => category.trusted?)
    end
  end

  # Returns true if this category has any labels
  def labels?
    (self.trusted?) ? true : false
  end

  # Returns an array of labels (for use in the thread title)
  def labels
    labels = []
    labels << "Trusted" if self.trusted?
    return labels
  end

  # Humanized ID for URLs.
  def to_param
    self.humanized_param(self.name)
  end

end
