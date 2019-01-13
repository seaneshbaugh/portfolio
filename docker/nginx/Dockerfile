FROM jonasal/nginx-certbot:latest

ENV APP_HOME /portfolio

COPY docker/nginx/nginx.conf /tmp/docker.nginx

RUN envsubst '$APP_HOME' < /tmp/docker.nginx > /etc/nginx/conf.d/seaneshbaugh.conf

COPY docker/nginx/dhparam.pem /etc/ssl/certs/dhparam.pem

WORKDIR $APP_HOME

RUN mkdir log

COPY public public/

