#!/bin/sh
set -e

echo "Waiting for PostgreSQL..."

until /usr/lib/postgresql/15/bin/pg_isready -h 127.0.0.1 -p 5432; do
  sleep 1
done

echo "PostgreSQL is ready!"

echo "Creating user if needed..."
su postgres -c "psql -tc \"SELECT 1 FROM pg_roles WHERE rolname='app_user'\" | grep -q 1 || psql -c \"CREATE USER app_user WITH PASSWORD 'app_password';\""

echo "Creating database if needed..."
su postgres -c "psql -tc \"SELECT 1 FROM pg_database WHERE datname='app_production'\" | grep -q 1 || psql -c \"CREATE DATABASE app_production OWNER app_user;\""

echo "Running rails db:prepare..."
bundle exec rails db:prepare

echo "Done!"
