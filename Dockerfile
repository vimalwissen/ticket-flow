FROM ruby:3.2.2-slim

ENV RAILS_ENV=production
ENV RACK_ENV=production

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential git curl \
    libpq-dev postgresql postgresql-contrib \
    supervisor && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test' && \
    bundle install

COPY . .

RUN bundle exec bootsnap precompile app/ lib/
RUN bundle exec rails assets:precompile

RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql && \
    su postgres -c "/usr/lib/postgresql/15/bin/initdb -D /var/lib/postgresql/data"

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY init-rails.sh /init-rails.sh
RUN chmod +x /init-rails.sh

EXPOSE 3000

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
