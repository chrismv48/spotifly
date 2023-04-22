#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake db:setup
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake poll_spotify