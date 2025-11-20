cat > init-rails.sh << 'EOF'
#!/bin/sh
set -e

echo "Waiting for PostgreSQL..."
until /usr/lib/postgresql/15/bin/pg_isready -h 127.0.0.1 -p 5432; do
  sleep 1
done

echo "PostgreSQL ready!"

echo "Creating production user if needed..."
su postgres -c "psql -tc \"SELECT 1 FROM pg_roles WHERE rolname='app_user'\" | grep -q 1 || psql -c \"CREATE USER app_user WITH PASSWORD 'app_password';\""

echo "Creating production database if needed..."
su postgres -c "psql -tc \"SELECT 1 FROM pg_database WHERE datname='ticket_flow_production'\" | grep -q 1 || psql -c \"CREATE DATABASE ticket_flow_production OWNER app_user;\""

echo "Running rails db:prepare in production..."
bundle exec rails db:prepare RAILS_ENV=production

echo "Running rails db:seed in production..."
bundle exec rails db:seed RAILS_ENV=production

echo "Production DB ready with seed data!"
exit 0
EOF
