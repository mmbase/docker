ARG TAG=latest

FROM ghcr.io/mmbase/env:${TAG}

ARG VERSION=1.9-SNAPSHOT
ARG GROUP=org.mmbase
ARG ARTIFACT=mmbase-commandserver

ENTRYPOINT [java, -jar, /mmbase-commandserver.jar ]


RUN \
  apt-get update && apt-get -y  install xsltproc && \
  curl -O https://raw.githubusercontent.com/mmprogrami/sonatype-snapshot-action/refs/heads/main/get-url.xslt &&\
  cat get-url.xslt

RUN  \
   export METADATA_URL="https://central.sonatype.com/repository/maven-snapshots/${GROUP}/${ARTIFACT}/${VERSION}/maven-metadata.xml" &&\
   echo "mu: ${METADATA_URL}" &&\
   export URL=$(curl  -s ${METADATA_URL} | xsltproc get-url.xslt -) &&\
   echo $URL &&\
   curl $URL > /mmbase-commandserver.jar