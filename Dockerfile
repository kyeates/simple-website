FROM ubuntu:14.04

MAINTAINER Kieran Yeates <kieran.yeates@4mation.com.au>

RUN apt-get update --fix-missing
RUN apt-get -y upgrade

# Install apache, PHP, and supplimentary programs. curl and lynx-cur are for debugging the container.
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 libapache2-mod-php5 php5-mysql php5-gd php-pear php-apc php5-curl curl lynx-cur openssh-server mysql-client

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Enable apache mods.
# turn on php5
RUN a2enmod php5
# mod_rewrite
RUN a2enmod rewrite
# enable ssl
RUN a2enmod ssl

#enable xdebug
RUN echo "xdebug.remote_enable=on" >> /etc/php5/apache2/conf.d/xdebug.ini
RUN echo "xdebug.remote_host=172.17.42.1 " >> /etc/php5/apache2/conf.d/xdebug.ini
RUN echo "xdebug.remote_connect_back=Off" >> /etc/php5/apache2/conf.d/xdebug.ini

#add local url to hosts for loop back calls
RUN echo "127.0.0.1 local.canteen.org.au" >> /etc/hosts;

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

RUN a2ensite default-ssl

EXPOSE 80
EXPOSE 443

#remove the www so we can mount from a volume
RUN rm -rf /var/www

ENTRYPOINT /usr/sbin/apache2ctl -D FOREGROUND
