ARG TAG=latest
ARG VERSION=1.9-SNAPSHOT
ARG GROUP=mmbase
ARG ARTIFACT=example-webapp

FROM ghcr.io/mmbase/tomcat:${TAG}


RUN \
  apt-get update & apt-get -y  install xsltproc

RUN \
   curl -O https://raw.githubusercontent.com/mmprogrami/sonatype-snapshot-action/refs/heads/main/get-url.xslt & \
   curl $(curl  -s https://central.sonatype.com/repository/maven-snapshots/${GROUP}/${ARTIFACT}/${VERSION}/maven-metadata.xml | xsltproc get-url.xslt -) > /tmp/app.war


LABEL org.mmbase.authors="michiel@mmbase.org"
LABEL org.mmbase.description="Tomcat with the MMBase Example Webapp"
