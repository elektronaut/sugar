# frozen_string_literal: true

Rails.application.config.session_store(
  :cookie_store,
  key: (ENV["SUGAR_SESSION_KEY"] || "_sugar_session"),
  expire_after: 3.years
)
