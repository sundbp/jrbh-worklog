# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_jrbh-worklog_session',
  :secret      => 'b08d3f60caac72723d01b8d74da3310df6e54092a187f687daee9e4c103e681665cfa07992b0494bc5ed5b35ab0e07c1995e498a3af5b0dbee54a61cd842904f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
