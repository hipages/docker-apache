FROM debian:jessie

LABEL maintainer "hipages DevOps Team <syd-team-devops@hipagesgroup.com.au>"

RUN sed -i 's/jessie main/jessie main non-free/' /etc/apt/sources.list

#apache setup
RUN apt-get update \
    && apt-get -y --no-install-recommends install apache2 libxml2-dev wget ca-certificates \
    && apt-get -y clean autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#setup needed filesystem locations
RUN mkdir -p /var/lock/apache2 \
             /var/run/apache2 \
             /var/log/apache2 \
    && chown www-data:www-data \
             /var/lock/apache2 \
             /var/run/apache2 \
             /var/log/apache2

#move our configuration into place
COPY build/apache2-foreground /usr/local/bin/
COPY build/vhost.conf /etc/apache2/sites-available/
COPY build/apache2.conf /etc/apache2/conf-available/

#enable/disable all the things
RUN a2enmod rewrite \
    && a2enconf apache2 \
    && a2dissite 000-default \
    && a2enmod actions \
    && a2enmod deflate \
    && a2enmod headers \
    && a2enmod proxy \
    && a2enmod proxy_http \
    && a2enmod proxy_fcgi \
    && a2enmod proxy_balancer \
    && a2enmod proxy_connect \
    && a2enmod rewrite \
    && a2ensite vhost

EXPOSE 80
CMD ["/usr/local/bin/apache2-foreground"]
