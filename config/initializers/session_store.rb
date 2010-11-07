# Be sure to restart your server when you modify this file.

Sugar::Application.config.session_store(
	:cookie_store, 
	:key          => (Sugar.config(:session_key) rescue '_sugar_session'), 
	:expire_after => 3.years
)

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Sugar3::Application.config.session_store :active_record_store
