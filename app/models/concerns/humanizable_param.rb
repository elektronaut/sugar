# frozen_string_literal: true

module HumanizableParam
  include ActiveSupport::Inflector
  extend ActiveSupport::Concern

  def humanized_param(slug)
    return id.to_s unless slug&.present?

    "#{id}-" + transliterate(slug).split(/[^\w\d]+/).reject(&:blank?).join("-")
  end
end
