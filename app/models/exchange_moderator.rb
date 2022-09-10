# frozen_string_literal: true

class ExchangeModerator < ApplicationRecord
  belongs_to :exchange
  belongs_to :user
  validates :user_id, uniqueness: { scope: :exchange_id }
end
