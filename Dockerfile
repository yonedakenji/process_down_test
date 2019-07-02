FROM yonedakenji/base

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

MAINTAINER yonedakenji <yon_ken@yahoo.co.jp>

ARG SYS_DIR=/system/MW
WORKDIR ${SYS_DIR}

### JDK ###
RUN ln -s /usr/lib/jvm/java/ ${SYS_DIR}/java
ENV JAVA_HOME ${SYS_DIR}/java
ENV PATH $JAVA_HOME/bin:$PATH
ENV CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar

### httpd ###
ARG HTTPD_VER=2.2.34
ARG HTTPD_FILE=httpd-${HTTPD_VER}.tar.gz
RUN curl -LO https://archive.apache.org/dist/httpd/${HTTPD_FILE} && \
    tar xzf ${HTTPD_FILE} && \
    rm -f ${HTTPD_FILE} && \
    cd httpd-${HTTPD_VER} && \
    ./configure --prefix=${SYS_DIR}/apache && \
    make && \
    make install && \
    cd ${WORKDIR}
ENV PATH ${SYS_DIR}/apache/bin:$PATH

### tomcat ###
ARG TOMCAT_VER=8.0.53
ARG TOMCAT_FILE=apache-tomcat-${TOMCAT_VER}.tar.gz
ENV CATALINA_HOME ${SYS_DIR}/tomcat
RUN curl -LO https://archive.apache.org/dist/tomcat/tomcat-8/v8.0.53/bin/${TOMCAT_FILE} && \
    tar xfz ${TOMCAT_FILE} && \
    rm -f ${TOMCAT_FILE} && \
    ln -s apache-tomcat-${TOMCAT_VER} tomcat
ENV PATH ${CATALINA_HOME}/bin:$PATH

### MySQL ###
RUN /usr/bin/mysql_install_db

### set up deamons ###
RUN mkdir /etc/service/httpd && \
    mkdir /etc/service/tomcat && \
    mkdir /etc/service/mysql
COPY service/httpd/run /etc/service/httpd
COPY service/tomcat/run /etc/service/tomcat
COPY service/mysql/run /etc/service/mysql

### clean up ###

### port expose ###
EXPOSE 80
