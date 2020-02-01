# frozen_string_literal: true

class SocialService < ApplicationRecord
  has_many :social_service_links, dependent: :destroy
  has_many :users, through: :social_service_links

  scope :sorted, -> { order("name ASC") }

  validates :name, presence: true, uniqueness: true
  validates :label, presence: true
end
