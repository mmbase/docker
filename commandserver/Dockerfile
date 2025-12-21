ARG TAG=latest

FROM debian:bookworm-slim AS getjar
ARG VERSION=1.9-SNAPSHOT
ARG GROUP=org/mmbase
ARG ARTIFACT=mmbase-commandserver

RUN apt-get update && \
    apt-get install -y xsltproc curl && \
    curl -O https://raw.githubusercontent.com/mmprogrami/sonatype-snapshot-action/refs/heads/main/get-url.xslt && \
    export METADATA_URL="https://central.sonatype.com/repository/maven-snapshots/${GROUP}/${ARTIFACT}/${VERSION}/maven-metadata.xml" && \
    export URL=$(curl -s ${METADATA_URL} | xsltproc --stringparam extension jar get-url.xslt -) && \
    curl $URL > /mmbase-commandserver.jar && \
    rm -rf /var/lib/apt/lists/*

FROM ghcr.io/mmbase/env:${TAG}

ENV JPDA_ADDRESS=*:8001

RUN apt-get update && \
    apt-get -y  install ffmpeg && \
    rm -rf /var/lib/apt/lists/*

COPY --from=getjar /mmbase-commandserver.jar /mmbase-commandserver.jar

ENTRYPOINT ["java", "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=${JPDA_ADDRESS}", "-jar", "/mmbase-commandserver.jar", "1679" ]


