# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

require "fog/aws/storage"

Dis::Storage.layers << Dis::Layer.new(
  Fog::Storage.new(provider: "Local", local_root: Rails.root.join("db/dis")),
  path: Rails.env
)

if Sugar.aws_s3? && !Rails.env.test?
  Dis::Storage.layers << Dis::Layer.new(
    Fog::Storage.new(
      provider: "AWS",
      aws_access_key_id: ENV["S3_KEY_ID"],
      aws_secret_access_key: ENV["S3_SECRET"]
    ),
    path: ENV["S3_BUCKET"],
    delayed: true,
    readonly: !Rails.env.production?
  )
end
