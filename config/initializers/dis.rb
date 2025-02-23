# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

require "fog/aws/storage"

Dis::Storage.layers << Dis::Layer.new(
  Fog::Storage.new(provider: "Local", local_root: Rails.root.join("db/dis")),
  path: Rails.env
)

if Rails.env.production?
  Rails.application.credentials.tap do |credentials|
    Dis::Storage.layers << Dis::Layer.new(
      Fog::Storage.new(
        provider: "AWS",
        aws_access_key_id: credentials.dig(:aws, :access_key_id),
        aws_secret_access_key: credentials.dig(:aws, :secret_access_key)
      ),
      path: "b3s",
      delayed: true,
      readonly: !Rails.env.production?
    )
  end
end
