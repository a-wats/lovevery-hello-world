# syntax=docker/dockerfile:1
FROM ruby:2.7-alpine

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache \
    build-base curl-dev zlib-dev yaml-dev tzdata nodejs sqlite-dev

COPY . /usr/src/app

RUN gem install bundler
RUN bundle config set frozen 1
RUN bundle config set deployment 1
RUN bundle config set without 'development test'
RUN bundle install
RUN bin/rails assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
