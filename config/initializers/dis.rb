# Be sure to restart your server when you modify this file.

Dis::Storage.layers << Dis::Layer.new(
  Fog::Storage.new({ provider: 'Local', local_root: Rails.root.join('db', 'dis') }),
  path: Rails.env
)

if Sugar.aws_s3?
  Dis::Storage.layers << Dis::Layer.new(
    Fog::Storage.new({
      provider:              'AWS',
      aws_access_key_id:     Sugar.config.amazon_aws_key,
      aws_secret_access_key: Sugar.config.amazon_aws_secret
    }),
    path: Sugar.config.amazon_s3_bucket,
    delayed: true
  )
end
