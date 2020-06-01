FROM ruby:1.9.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs imagemagick
RUN apt-get install -y default-jre
RUN mkdir /rails_app
WORKDIR /rails_app
COPY ./Gemfile /rails_app/Gemfile
COPY ./Gemfile.lock /rails_app/Gemfile.lock
RUN bundle install --full-index
COPY . /rails_app
RUN rm -rf /rails_app/_nginx
EXPOSE 3000
EXPOSE 8982
CMD rm -f /app/tmp/pids/server.pid && bundle exec rake sunspot:solr:start && bundle exec puma -C config/puma.rb