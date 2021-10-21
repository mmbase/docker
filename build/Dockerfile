FROM mmbase/env:latest

LABEL org.mmbase.authors="michiel@mmbase.org"
LABEL org.mmbase.description="MMBase for building. Installs nodejs and maven"

ARG MAVEN_VERSION=3.8.3

RUN apt-get -y update && apt-get -y install nodejs && apt-get clean && rm -rf /var/cache/apt/lists

RUN cd / && curl  https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz  | tar zxf - && \
    ln -s /apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn
