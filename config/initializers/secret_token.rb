# frozen_string_literal: true

unless ENV["SUGAR_SECRET_KEY_BASE"] || ENV["SUGAR_SECRET_TOKEN"]
  raise "SUGAR_SECRET_KEY_BASE environment variable hasn't been set."
end

Sugar::Application.config.secret_token    = ENV["SUGAR_SECRET_TOKEN"]
Sugar::Application.config.secret_key_base = ENV["SUGAR_SECRET_KEY_BASE"]
