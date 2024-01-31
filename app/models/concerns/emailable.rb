# frozen_string_literal: true

module Emailable
  extend ActiveSupport::Concern

  included do
    validates :email,
              email: true,
              presence: true,
              uniqueness: { case_sensitive: false }

    normalizes :email, with: ->(email) { email.strip }
  end
end
