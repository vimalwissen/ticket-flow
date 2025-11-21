#!/bin/bash
set -e

# 1. Generate SECRET_KEY_BASE if not set
if [ -z "$SECRET_KEY_BASE" ]; then
  echo "Generating SECRET_KEY_BASE..."
  export SECRET_KEY_BASE=$(ruby -e "require 'securerandom'; print SecureRandom.hex(64)")

  # Also write it to .env so manual 'docker exec' sessions can find it
  echo "SECRET_KEY_BASE=$SECRET_KEY_BASE" > /app/.env
fi

# 2. Ensure Postgres permissions
mkdir -p /var/lib/postgresql/data
chown -R postgres:postgres /var/lib/postgresql

# 3. Initialize Postgres if empty
if [ -z "$(ls -A /var/lib/postgresql/data)" ]; then
  echo "Initializing Database..."
  su postgres -c "/usr/lib/postgresql/15/bin/initdb -D /var/lib/postgresql/data"
fi

# 4. Pass the SECRET_KEY_BASE to the next command (Supervisor)
exec "$@"