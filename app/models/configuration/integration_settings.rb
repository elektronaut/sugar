# frozen_string_literal: true

class Configuration
  module IntegrationSettings
    extend ActiveSupport::Concern
    included do
      setting :google_analytics, :string
      setting :amazon_associates_id, :string
      setting :amazon_aws_key, :string
      setting :amazon_aws_secret, :string
      setting :amazon_s3_bucket, :string
      setting :facebook_app_id, :string
      setting :facebook_api_secret, :string
    end
  end
end
