#!/bin/sh

bundle install
bin/rails db:prepare
RAILS_ENV=test bin/rails db:prepare
bundle exec rails server -b 0.0.0.0
