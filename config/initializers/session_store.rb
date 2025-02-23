# frozen_string_literal: true

Rails.application.config.session_store(
  :cookie_store,
  key: "_sugar_session",
  expire_after: 3.years
)
