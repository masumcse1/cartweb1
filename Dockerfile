#MAINTAINER Sophia Parafina <sophia.parafina@docker.com>


FROM maven:3.6-jdk-11-slim AS build-servlets
 
ARG SCM="scm:git:ssh://git@github.com:masumcse1/cartweb.git"

WORKDIR /usr/src/catweb

COPY . .

RUN mvn clean package -Dscm.url=${SCM} -DskipTests

####################################


FROM openjdk:11.0.7-jdk-slim-buster

###################

### ------------------------- base ------------------------- ###
# Install packages necessary
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https ca-certificates curl jsvc unzip \
# procps : for 'free' command
        procps \
# iputils-ping : for 'ping' command
        iputils-ping \
# iproute2 : for 'ip' command
        iproute2 \
# postgresql-client : for 'pg_isready' command
        postgresql-client \
# java.lang.UnsatisfiedLinkError: /usr/local/openjdk-11/lib/libfontmanager.so: libfreetype.so.6: cannot open shared object file: No such file or directory
# java.lang.NoClassDefFoundError: Could not initialize class sun.awt.X11FontManager
# https://github.com/docker-library/openjdk/pull/235#issuecomment-424466077
        fontconfig libfreetype6 \
    && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
##########

RUN mkdir /opt/tomcat/



WORKDIR /opt/tomcat
RUN curl -O http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.40/bin/apache-tomcat-8.5.40.tar.gz
RUN tar xvfz apache*.tar.gz
RUN mv apache-tomcat-8.5.40/* /opt/tomcat/.

WORKDIR /opt/tomcat/webapps

COPY  --from=build-servlets /usr/src/catweb/target/cartweb-0.0.1-SNAPSHOT.war CatWeb.war

EXPOSE 8080
WORKDIR /opt/tomcat/bin/
CMD ["/opt/tomcat/bin/catalina.sh", "run"]

