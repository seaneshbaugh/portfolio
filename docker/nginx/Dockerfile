FROM nginx

RUN apt-get update -qq && apt-get -y install apache2-utils

ENV APP_HOME /portfolio

WORKDIR $APP_HOME

RUN mkdir log

COPY public public/

COPY docker/nginx/nginx.conf /tmp/docker.nginx

RUN envsubst '$APP_HOME' < /tmp/docker.nginx > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
