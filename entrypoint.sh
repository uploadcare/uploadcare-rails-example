#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /uploadcare-rails-example/tmp/pids/server.pid

# Create database and run migrations if needed
bundle exec rails db:create 2>/dev/null || true
bundle exec rails db:migrate

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
