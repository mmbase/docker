ARG REGISTRY=ghcr.io/

FROM ${REGISTRY}mmbase/env:2

ARG MAVEN_VERSION=3.9.10

RUN apt-get -y update && apt-get -y install nodejs git make gpg && apt-get clean && rm -rf /var/cache/apt/lists && apt-get -y auto-remove

# apt-get maven will install java 11, we have already a java
RUN cd / && curl  https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz  | tar zxf - && \
    ln -s /apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn

ENTRYPOINT ["/usr/local/bin/mvn"]

#USER maven

LABEL org.mmbase.authors="michiel@mmbase.org"
LABEL org.mmbase.description="Docker image for building MMBase (at github). Installs nodejs and maven"
