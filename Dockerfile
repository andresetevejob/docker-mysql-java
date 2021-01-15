# Java 8 (Oracle) Dockerfile
# Base image: Ubuntu
# Installs: Java 8
  
FROM ubuntu:bionic-20190612

RUN apt-get update && \
	apt-get install -y openjdk-8-jdk && \
	apt-get install -y ant && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;
	
# Fix certificate issues, found as of 
# https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/983302
RUN apt-get update && \
	apt-get install -y ca-certificates-java && \
	apt-get clean && \
	update-ca-certificates -f && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;

RUN apt-get update
RUN apt-get install -y  supervisor

# Setup JAVA_HOME, this is useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV  PATH $JAVA_HOME/bin:$PATH
RUN export PATH
#Install Mysql
ENV MYSQL_USER=mysql \
    MYSQL_VERSION=5.7.31 \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server=${MYSQL_VERSION}* \
 && rm -rf ${MYSQL_DATA_DIR} \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /init-mysql-data.d

COPY schema-mysql.sql /init-mysql-data.d/schema-mysql.sql
VOLUME /var/lib/mysql

COPY entrypoint.sh /entrypoint.sh
COPY foreground.sh /opt/foreground.sh
COPY demo.jar    /opt/demo.jar
COPY supervisord.conf /etc/supervisord.conf
RUN chmod 755 /entrypoint.sh
RUN chmod 755 /opt/foreground.sh
#RUN mkdir /var/log/supervisor/

EXPOSE 8080/tcp

#ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/bin/bash", "/entrypoint.sh"]
