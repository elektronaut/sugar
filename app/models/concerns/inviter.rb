module Inviter
  extend ActiveSupport::Concern

  included do
    belongs_to :inviter, :class_name => 'User'
    has_many   :invitees, :class_name => 'User', :foreign_key => 'inviter_id', :order => 'username ASC'
    has_many   :invites, :dependent => :destroy, :order => 'created_at DESC' do
      def active
        self.select{|i| !i.expired?}
      end
    end
  end

  # Returns true if this user has invited someone.
  def invites?
    self.invites.count > 0
  end

  # Returns true if this user has invitees.
  def invitees?
    self.invitees.count > 0
  end

  # Returns true if this user has invited someone or has invitees.
  def invites_or_invitees?
    self.invites? || self.invitees?
  end

  # Returns true if this user can invite someone.
  def available_invites?
    self.user_admin? || self.available_invites > 0
  end

  # Number of remaining invites. User admins always have at least one invite.
  def available_invites
     number = self[:available_invites]
     self.user_admin? ? 1 : self[:available_invites]
  end

  # Revokes invites from a user, default = 1. Pass :all as an argument to revoke all invites.
  def revoke_invite!(number=1)
    return self.available_invites if self.user_admin?
    number = self.available_invites if number == :all
    new_invites = self.available_invites - number
    new_invites = 0 if new_invites < 0
    self.update_column(:available_invites, new_invites)
    self.available_invites
  end

  # Grants a number of invites to a user.
  def grant_invite!(number=1)
    return self.available_invites if self.user_admin?
    new_number = (self.available_invites + number)
    self.update_column(:available_invites, new_number)
    self.invites
  end

end