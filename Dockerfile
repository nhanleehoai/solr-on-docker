FROM alpine:3.8

MAINTAINER Nhan Le <nhanleehoai@yahoo.com>

RUN apk --update add  curl wget gnupg bash libgcc && rm -rf /var/cache/apk/* && \
curl -Ls https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.21-r2/glibc-2.21-r2.apk > /tmp/glibc-2.21-r2.apk && \
    apk add --allow-untrusted /tmp/glibc-2.21-r2.apk && \
	rm /tmp/glibc-2.21-r2.apk


## Install Oracle JDK ##

# Go to Oracle website and grab the link to JDK TAR 
# http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.tar.gz

ENV JDK_URL http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.tar.gz
ENV JDK_FOLDER jdk1.8.0_181	

# Download and unarchive Java
RUN mkdir /opt && \
cd /opt && \
wget -q -nv  --no-check-certificate --output-document=/opt/jdk.tar.gz --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjre8-downloads-2133155.html; oraclelicense=accept-securebackup-cookie" ${JDK_URL} && \
    tar -zxf jdk.tar.gz && \
    ln -s /opt/${JDK_FOLDER} /opt/jdk && \
    rm -rf /opt/jdk/*src.zip \
           /opt/jdk/lib/missioncontrol \
           /opt/jdk/lib/visualvm \
           /opt/jdk/lib/*javafx* \
           /opt/jdk/jre/lib/plugin.jar \
           /opt/jdk/jre/lib/ext/jfxrt.jar \
           /opt/jdk/jre/bin/javaws \
           /opt/jdk/jre/lib/javaws.jar \
           /opt/jdk/jre/lib/desktop \
           /opt/jdk/jre/plugin \
           /opt/jdk/jre/lib/deploy* \
           /opt/jdk/jre/lib/*javafx* \
           /opt/jdk/jre/lib/*jfx* \
           /opt/jdk/jre/lib/amd64/libdecora_sse.so \
           /opt/jdk/jre/lib/amd64/libprism_*.so \
           /opt/jdk/jre/lib/amd64/libfxplugins.so \
           /opt/jdk/jre/lib/amd64/libglass.so \
           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jdk/jre/lib/amd64/libjavafx*.so \
           /opt/jdk/jre/lib/amd64/libjfx*.so && \
	rm 	/opt/jdk.tar.gz   

# Set environment
ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin


## Install SOLR ##

ENV SOLR_USER root
ENV SOLR_UID 8983

#Download the public key for GPG to verify the tar.asc file.  If you dont know the key, comment out the next 2 lines, there will be error with RSA KEY
#Look for the key if you got the errro meassge like "gpg: Signature made Thu Sep  1 20:10:33 2016 UTC using RSA key ID A3A13A7F"

ENV SOLR_KEY 051A0FAF76BC6507
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$SOLR_KEY"

# The SHA1 checksum "06cc41fb937b8b89f92d161289e201374726d5a6" is grabbed from the website.

ENV SOLR_VERSION 7.4.0
ENV SOLR_SHA1 18ac829bcda555de3ff679a0ccd4e263ed9d49a8


RUN mkdir -p /opt/solr && \
  wget -q -nv --output-document=/opt/solr.tgz http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz && \
  wget -q -nv --output-document=/opt/solr.tgz.asc http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz.asc && \
  gpg --verify /opt/solr.tgz.asc && \
  echo "$SOLR_SHA1 */opt/solr.tgz" | sha1sum -c - && \
  cd /opt && \
  tar xzf solr.tgz && \
  mv solr-$SOLR_VERSION/* solr/ && \
  rm /opt/solr.tgz* && \
  mkdir -p /opt/solr/server/solr/lib && \
  chown -R $SOLR_USER:$SOLR_USER /opt/solr && \
  rmdir solr-$SOLR_VERSION

# COPY COR1 /opt/solr/server/solr/COR1/
# 

EXPOSE 8983
WORKDIR /opt/solr
USER $SOLR_USER

CMD ["/opt/solr/bin/solr", "start","-force","-f"]
