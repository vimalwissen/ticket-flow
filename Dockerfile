FROM ruby:3.2.2-slim

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential git curl \
    libpq-dev postgresql postgresql-contrib \
    supervisor && \
    rm -rf /var/lib/apt/lists/*

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy app
COPY . .

# Precompile bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# Init Postgres data directory
RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql && \
    su postgres -c "/usr/lib/postgresql/15/bin/initdb -D /var/lib/postgresql/data"

# Copy supervisor & scripts
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY init-rails.sh /init-rails.sh
RUN chmod +x /init-rails.sh

EXPOSE 3000

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
