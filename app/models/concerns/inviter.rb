module Inviter
  extend ActiveSupport::Concern

  attr_accessor :invite

  included do
    before_create :set_inviter
    after_create :expire_invite

    belongs_to :inviter,
               class_name: "User"

    has_many :invitees,
             -> { order "username ASC" },
             class_name: "User",
             foreign_key: "inviter_id"

    has_many :invites,
             -> { order "created_at ASC" },
             dependent: :destroy
  end

  def invites?
    invites.count > 0
  end

  def invitees?
    invitees.count > 0
  end

  def invites_or_invitees?
    self.invites? || self.invitees?
  end

  def available_invites?
    self.user_admin? || available_invites > 0
  end

  # Number of remaining invites. User admins always have at least one invite.
  def available_invites
    self.user_admin? ? 1 : self[:available_invites]
  end

  # Revokes invites from a user, default = 1.
  # Pass :all as an argument to revoke all invites.
  def revoke_invite!(number = 1)
    return available_invites if self.user_admin?
    number = available_invites if number == :all
    new_invites = available_invites - number
    new_invites = 0 if new_invites < 0
    update_column(:available_invites, new_invites)
    available_invites
  end

  def grant_invite!(number = 1)
    return available_invites if self.user_admin?
    new_number = (available_invites + number)
    update_column(:available_invites, new_number)
    invites
  end

  protected

  def set_inviter
    if invite
      self.inviter = invite.user
    end
  end

  def expire_invite
    if invite
      invite.expire!
    end
  end
end
