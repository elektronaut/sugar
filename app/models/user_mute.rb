# frozen_string_literal: true

class UserMute < ApplicationRecord
  belongs_to :user
  belongs_to :muted_user, class_name: "User"
  belongs_to :exchange, optional: true

  validates :muted_user_id,
            uniqueness: { scope: %i[user_id exchange_id] }
end
