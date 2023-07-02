# frozen_string_literal: true

module HumanizableParam
  include ActiveSupport::Inflector
  extend ActiveSupport::Concern

  def humanized_param(slug)
    return id.to_s if slug.blank?

    "#{id}-" + transliterate(slug).split(/[^\w\d]+/).compact_blank.join("-")
  end
end
