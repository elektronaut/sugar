# encoding: utf-8

Sugar::Application.config.session_store(
  :cookie_store,
  :key          => (ENV['SUGAR_SESSION_KEY'] || "_sugar_session"),
  :expire_after => 3.years
)
