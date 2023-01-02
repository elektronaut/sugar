# frozen_string_literal: true

class UserLink < ApplicationRecord
  URL_PATTERN = %r{\A(https?://)?[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,4}}.freeze

  belongs_to :user

  validates :label, presence: true
  validates :url,
            presence: { unless: :name? },
            format: { with: URL_PATTERN, allow_blank: true }

  acts_as_list scope: :user

  scope :sorted, -> { order("position ASC") }

  class << self
    def labels
      joins(:user)
        .where(user: { status: %i[active memorialized] })
        .pluck(:label).uniq.sort
    end
  end

  def label=(new_label)
    super(new_label&.strip)
  end

  def name=(new_name)
    super(new_name&.strip)
  end

  def url=(new_url)
    super(new_url&.strip)
  end

  def name_or_pretty_url
    return name if name?

    url.gsub(%r{^(f|ht)tps?://}, "")
  end
end
