ARG TAG=latest
ARG VERSION=1.9-SNAPSHOT

FROM ghcr.io/mmbase/tomcat:${TAG}


RUN curl -O https://raw.githubusercontent.com/mmprogrami/sonatype-snapshot-action/refs/heads/main/get-url.xslt & \
    curl $(curl  -s https://central.sonatype.com/repository/maven-snapshots/$(GROUP)/$(ARTIFACT)/$(VERSION)/maven-metadata.xml | xsltproc get-url.xslt -) > example.war

    xsltproc get-url.txt


LABEL org.mmbase.authors="michiel@mmbase.org"
LABEL org.mmbase.description="Tomcat with the MMBase Example Webapp"
