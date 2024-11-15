# frozen_string_literal: true

OEmbed::Providers.register_all

MASTODON_PROVIDERS = [
  "fosstodon.org",
  "hachyderm.io",
  "indieweb.social",
  "infosec.exchange",
  "journa.host",
  "mas.to",
  "mastodon.art",
  "mastodon.cloud",
  "mastodon.ie",
  "mastodon.online",
  "mastodon.sdf.org",
  "mastodon.social",
  "mastodon.world",
  "mstdn.ca",
  "mstdn.party",
  "mstdn.social",
  "octodon.social",
  "ruby.social",
  "snabelen.no",
  "techhub.social",
  "news.twtr.plus",
  "bne.social"
].freeze

MASTODON_PROVIDERS.each do |host|
  OEmbed::Provider.new("https://#{host}/api/oembed").tap do |provider|
    provider << "http://*.#{host}/*"
    provider << "https://*.#{host}/*"
    OEmbed::Providers.register(provider)
  end
end

OEmbed::Provider.new("https://embed.bsky.app/oembed").tap do |provider|
  provider << "http://*.bsky.app/*"
  provider << "https://*.bsky.app/*"
  OEmbed::Providers.register(provider)
end
