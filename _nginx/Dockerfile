FROM nginx
RUN apt-get update -qq && apt-get -y install apache2-utils && apt-get -y install python-certbot-nginx && apt-get -y install cron
ENV RAILS_ROOT /var/www/rails_app
WORKDIR $RAILS_ROOT
RUN rm -Rf ./*
RUN mkdir -p log
RUN mkdir -p public
COPY _nginx/app.conf /tmp/docker_example.nginx
RUN envsubst '$RAILS_ROOT' < /tmp/docker_example.nginx > /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["sh", "-c", "cron && crontab /etc/cron.d/certbot && nginx -g 'daemon off;'" ]
