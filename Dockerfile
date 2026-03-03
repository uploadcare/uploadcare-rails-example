FROM ruby:3.4.8-slim-trixie

RUN apt-get update -qq && \
    apt-get install -y  --no-install-recommends \
        build-essential libpq-dev libyaml-dev nodejs postgresql-client && \
    apt-get install -y npm && \
    npm install --global yarn

WORKDIR /uploadcare-rails-example
COPY Gemfile /uploadcare-rails-example/Gemfile
COPY Gemfile.lock /uploadcare-rails-example/Gemfile.lock
RUN bundle install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]
