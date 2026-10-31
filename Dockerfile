# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=4.0.9
FROM docker.io/library/ruby:$RUBY_VERSION-slim

ENV APP_HOME="/portfolio"
ENV APP_PORT="3000"

WORKDIR $APP_HOME

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="development"
ENV BUNDLER_VERSION="4.0.23"
RUN gem install bundler --version "$BUNDLER_VERSION" --no-document

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev node-gyp pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ARG NODE_VERSION=26.13.0
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    rm -rf /tmp/node-build-master
RUN npm install --global "yarn@$YARN_VERSION"

COPY Gemfile Gemfile.lock .tool-versions ./
RUN BUNDLE_FROZEN=true bundle install

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --network-timeout 3600000

COPY . .

EXPOSE $APP_PORT

CMD ["bundle", "exec", "rails", "server", "-p", "3000", "-b", "0.0.0.0"]
