# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.

SESSION_KEY_NAME = YAML.load_file(File.join(File.dirname(__FILE__), '../sugar_conf.yml'))['session_key']
SESSION_KEY      = File.read(File.join(File.dirname(__FILE__), '../session_key'))

ActionController::Base.session = {
	:session_key  => SESSION_KEY_NAME,
	:secret       => SESSION_KEY,
	:expire_after => 3.years
}
 
# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store