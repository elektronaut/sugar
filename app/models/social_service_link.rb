class SocialServiceLink < ApplicationRecord
  belongs_to :user
  belongs_to :social_service

  scope :enabled, -> { with_service.where(social_services: { enabled: true }) }
  scope :sorted, -> { with_service.order("social_services.name ASC") }
  scope :with_service, -> { joins(:social_service) }

  def link?
    !link_url.blank?
  end

  def link_text
    username? ? username : social_service.name
  end

  def link_url
    if social_service.custom_url? && url?
      url
    elsif social_service.url_pattern?
      social_service.url_pattern.gsub(/%username%/, username)
    end
  end
end
