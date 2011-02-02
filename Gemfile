# Edit this Gemfile to bundle your application's dependencies.
# This preamble is the current preamble for Rails 3 apps; edit as needed.
source 'http://rubygems.org'

gem 'rails', '3.0.3'

# database and jruby stuff
if defined?(JRUBY_VERSION)
  gem 'activerecord-jdbc-adapter',  '1.0.2'
  gem 'jdbc-postgres',              '8.4.702', :require => false
  gem 'jruby-openssl'
  gem 'jruby-rack'
  gem 'ffi-ncurses'
else
  gem 'pg',             '~> 0.9.0'
end

gem 'haml',           '~> 3.0.23'
gem 'will_paginate',  '~> 3.0.pre2'
gem 'net-ldap',       '~> 0.1.1'
gem 'compass',        '~> 0.10.6'
gem 'jquery-rails',   '~> 0.2.5'
gem 'authlogic',      :git => 'git://github.com/odorcicd/authlogic.git', :branch => 'rails3'
gem 'whenever'
gem "meta_where"

group :development do
  gem 'awesome_print'
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'warbler', '1.3.0.beta1' if defined?(JRUBY_VERSION)
end

