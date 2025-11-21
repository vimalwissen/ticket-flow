FROM ruby:3.2.2-slim

ENV RAILS_ENV=production
ENV RACK_ENV=production

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential git curl \
    libpq-dev postgresql postgresql-contrib \
    supervisor && \
    rm -rf /var/lib/apt/lists/*

# Gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test' && \
    bundle install

# Copy App
COPY . .

# --- FIX 1: Add a dummy key for build-time precompilation ---
# Rails needs A key to boot for precompilation, but it doesn't need to be the real one.
RUN SECRET_KEY_BASE=dummy bundle exec bootsnap precompile app/ lib/

# Setup Directories
RUN mkdir -p /var/lib/postgresql/data /var/log/supervisor

# Copy Configs
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY init-rails.sh /usr/bin/init-rails.sh
COPY entrypoint.sh /usr/bin/entrypoint.sh

# Permissions
RUN sed -i 's/\r$//' /usr/bin/init-rails.sh && chmod +x /usr/bin/init-rails.sh
RUN sed -i 's/\r$//' /usr/bin/entrypoint.sh && chmod +x /usr/bin/entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]