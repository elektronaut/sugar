# Be sure to restart your server when you modify this file.

# Create a random secret token if the file doesn't exist
if !File.exist?(File.join(File.dirname(__FILE__), '../session_key')) && ENV['RAILS_ENV'] != "production"
    session_key = ''
    seed = [0..9,'a'..'z','A'..'Z'].map(&:to_a).flatten.map(&:to_s)
    128.times{ session_key += seed[rand(seed.length)] }
    File.open(File.join(File.dirname(__FILE__), '../session_key'), "w"){ |fh| fh.write(session_key)}
end

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Sugar::Application.config.secret_token = File.read(File.join(File.dirname(__FILE__), '../session_key'))