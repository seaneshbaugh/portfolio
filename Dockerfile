# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=4.0.9
ARG NODE_VERSION=26.13.0
FROM node:${NODE_VERSION}-bookworm-slim AS node
RUN npm install --global yarn@1.22.22

FROM ruby:${RUBY_VERSION}-slim

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libyaml-dev \
      libvips \
      postgresql-client \
      pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Node is used by CMS validators and the browser asset vendoring tool.
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules/yarn /opt/yarn
RUN ln -s /usr/local/bin/node /usr/local/bin/nodejs && \
    ln -s /opt/yarn/bin/yarn.js /usr/local/bin/yarn

ARG BUNDLER_VERSION=4.0.23
RUN gem install bundler --version "${BUNDLER_VERSION}" --no-document && \
    gem install foreman --version 0.90.0 --no-document

COPY Gemfile Gemfile.lock .tool-versions ./
RUN BUNDLE_FROZEN=true bundle install
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .

EXPOSE 3000
CMD ["bin/dev"]
