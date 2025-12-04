ARG TAG=latest

FROM debian:bookworm-slim AS getjar
ARG VERSION=1.9-SNAPSHOT
ARG GROUP=org/mmbase
ARG ARTIFACT=mmbase-commandserver

RUN apt-get update && apt-get install -y xsltproc curl && \
    curl -O https://raw.githubusercontent.com/mmprogrami/sonatype-snapshot-action/refs/heads/main/get-url.xslt

RUN  \
   export METADATA_URL="https://central.sonatype.com/repository/maven-snapshots/${GROUP}/${ARTIFACT}/${VERSION}/maven-metadata.xml" && \
   export URL=$(curl  -s ${METADATA_URL} | xsltproc --stringparam extension jar get-url.xslt -) && \
   curl $URL > /mmbase-commandserver.jar

FROM ghcr.io/mmbase/env:${TAG}

COPY --from=getjar /mmbase-commandserver.jar /mmbase-commandserver.jar

ENTRYPOINT ["java", "-jar", "/mmbase-commandserver.jar", "1679" ]

RUN apt-get update && apt-get -y  install ffmpeg

