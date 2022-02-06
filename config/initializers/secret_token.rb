# frozen_string_literal: true

Dotenv.require_keys("SUGAR_SECRET_KEY_BASE")

Sugar::Application.config.secret_key_base = ENV["SUGAR_SECRET_KEY_BASE"]
