ARG REGISTRY=ghcr.io/
ARG TAG=8-latest

FROM ${REGISTRY}mmbase/env:${TAG}

ARG MAVEN_VERSION=3.9.12

RUN apt-get -y update && apt-get -y install nodejs git make gpg ant curl  && apt-get clean && rm -rf /var/cache/apt/lists && apt-get -y auto-remove

# apt-get maven will install java 11, we have already a java
RUN cd / && curl  https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz  | tar zxf - && \
    ln -s /apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn && \
    mkdir -p /work/.m2


COPY --from=ghcr.io/mmbase/ffmpeg:4 /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=ghcr.io/mmbase/ffmpeg:4 /DOCKER.BUILD /tmp/ffmpeg.DOCKER.BUILD

RUN cat /tmp/ffmpeg.DOCKER.BUILD >> /DOCKER.BUILD

COPY settings.xml /work/.m2/settings.xml

ENTRYPOINT ["/usr/local/bin/mvn"]
WORKDIR /work

LABEL org.mmbase.authors="michiel@mmbase.org"
LABEL org.mmbase.description="Docker image for building MMBase (at github). Installs nodejs and maven"
