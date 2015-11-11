# Base image
FROM centos:centos6

# Maintainer
MAINTAINER Alban Montaigu <alban.montaigu@gmail.com>

# Basic packages
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm \
  && yum -y install passwd sudo git wget ruby gcc gcc-c++ openssl

# Redis
RUN yum install -y redis

# RabbitMQ
RUN yum install -y erlang \
  && rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc \
  && rpm -Uvh http://www.rabbitmq.com/releases/rabbitmq-server/v3.1.4/rabbitmq-server-3.1.4-1.noarch.rpm \
  && git clone git://github.com/joemiller/joemiller.me-intro-to-sensu.git \
  && cd joemiller.me-intro-to-sensu/ && ./ssl_certs.sh clean && ./ssl_certs.sh generate \
  && mkdir /etc/rabbitmq/ssl \
  && cp /joemiller.me-intro-to-sensu/server_cert.pem /etc/rabbitmq/ssl/cert.pem \
  && cp /joemiller.me-intro-to-sensu/server_key.pem /etc/rabbitmq/ssl/key.pem \
  && cp /joemiller.me-intro-to-sensu/testca/cacert.pem /etc/rabbitmq/ssl/
ADD ./files/rabbitmq.config /etc/rabbitmq/
RUN rabbitmq-plugins enable rabbitmq_management

# Sensu server
ADD ./files/sensu.repo /etc/yum.repos.d/
RUN yum install -y sensu
ADD ./files/config.json /etc/sensu/
ADD ./files/handler_mailer.json /etc/sensu/conf.d/handler_mailer.json
RUN mkdir -p /etc/sensu/ssl \
  && cp /joemiller.me-intro-to-sensu/client_cert.pem /etc/sensu/ssl/cert.pem \
  && cp /joemiller.me-intro-to-sensu/client_key.pem /etc/sensu/ssl/key.pem \
  && /opt/sensu/embedded/bin/gem install sensu-plugin \
  && /opt/sensu/embedded/bin/gem install sensu-plugins-mailer \
  && wget -O /etc/sensu/handlers/mailer.rb https://raw.github.com/sensu/sensu-community-plugins/master/handlers/notification/mailer.rb \
  && wget -O /etc/sensu/conf.d/mailer.json https://raw.github.com/sensu/sensu-community-plugins/master/handlers/notification/mailer.json

# uchiwa
RUN yum install -y uchiwa
ADD ./files/uchiwa.json /etc/sensu/

# supervisord
RUN wget http://peak.telecommunity.com/dist/ez_setup.py;python ez_setup.py \
  && easy_install supervisor
ADD files/supervisord.conf /etc/supervisord.conf

EXPOSE 3000 4567 5671 15672

CMD ["/usr/bin/supervisord"]
