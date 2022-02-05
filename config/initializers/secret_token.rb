# frozen_string_literal: true

unless ENV["SUGAR_SECRET_KEY_BASE"]
  raise "SUGAR_SECRET_KEY_BASE environment variable hasn't been set."
end

Sugar::Application.config.secret_key_base = ENV["SUGAR_SECRET_KEY_BASE"]
