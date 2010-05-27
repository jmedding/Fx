# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_fx_session',
  :secret      => '58c79800ecb7b3fe6e5fbe80c619fc5b5e77b9203ff132b128dbf7a68fe78b93ea434210c09e4fc68a4b1823cb1250d141387d1db265938f6a8b2e7c73b36b77'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
