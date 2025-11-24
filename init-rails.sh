#!/bin/bash
set -e

echo "Waiting for PostgreSQL to accept connections..."
# Wait up to 30 seconds for PG to start
timeout=30
while ! /usr/lib/postgresql/15/bin/pg_isready -h 127.0.0.1 -p 5432 > /dev/null 2> /dev/null; do
  timeout=$((timeout - 1))
  if [ $timeout -eq 0 ]; then
    echo "PostgreSQL timed out."
    exit 1
  fi
  sleep 1
done
echo "PostgreSQL is ready!"

# Create user if not exists
echo "Checking for database user..."
su postgres -c "psql -tc \"SELECT 1 FROM pg_roles WHERE rolname='app_user'\" | grep -q 1 || psql -c \"CREATE USER app_user WITH PASSWORD 'app_password' SUPERUSER;\""

# Create main DBs
for DB in ticket_flow_production ticket_flow_cable ticket_flow_cache ticket_flow_queue; do
  echo "Ensuring database $DB exists..."
  su postgres -c "psql -tc \"SELECT 1 FROM pg_database WHERE datname='${DB}'\" | grep -q 1 || psql -c \"CREATE DATABASE ${DB} OWNER app_user;\""
done

echo "Installing extra migrations..."
bundle exec rails solid_cable:install:migrations RAILS_ENV=production || true
bundle exec rails solid_cache:install:migrations RAILS_ENV=production || true
bundle exec rails solid_queue:install:migrations RAILS_ENV=production || true

echo "Running migrations..."
bundle exec rails db:migrate RAILS_ENV=production

echo "Running seeds..."
bundle exec rails db:seed RAILS_ENV=production || true

echo "Initialization complete!"
exit 0