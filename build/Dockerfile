ARG REGISTRY=ghcr.io/
ARG TAG=latest

FROM ${REGISTRY}mmbase/env:${TAG}

ARG MAVEN_VERSION=3.9.11

RUN apt-get -y update && apt-get -y install nodejs git make gpg && apt-get clean && rm -rf /var/cache/apt/lists && apt-get -y auto-remove

# apt-get maven will install java 11, we have already a java
RUN cd / && curl  https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz  | tar zxf - && \
    ln -s /apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn && \
    useradd -ms /bin/bash -d /work runner && \
    mkdir -p /work/.m2 && \
    chown -R runner:runner /work


# This makes ${USER.HOME} /
ENV HOME=/work

USER runner

COPY settings.xml /work/.m2/settings.xml

ENTRYPOINT ["/usr/local/bin/mvn"]

COPY --from=ghcr.io/mmbase/ffmpeg:latest /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=ghcr.io/mmbase/ffmpeg:latest /DOCKER.BUILD /tmp/ffmpeg.DOCKER.BUILD

RUN cat /tmp/ffmpeg.DOCKER.BUILD >> /DOCKER.BUILD


#USER maven

LABEL org.mmbase.authors="michiel@mmbase.org"
LABEL org.mmbase.description="Docker image for building MMBase (at github). Installs nodejs and maven"
