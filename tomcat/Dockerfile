FROM ghcr.io/mmbase/env:latest

# seems to be removed as soon as newer version available?
ARG TOMCAT_VERSION=9.0.99
ENV CATALINA_BASE=/catalina_base

RUN apt-get update && apt-get -y upgrade


# note that this is unused in helm, it then uses container.command
CMD ["/usr/local/catalina-base/bin/start.sh"]
#CMD ["catalina.sh", "run"]

# We want to split off catalina base, default it's catalina_home
ADD catalina_base ${CATALINA_BASE}/

RUN curl https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz | tar zxf - && \
    ln -s apache-tomcat-$TOMCAT_VERSION tomcat && \
    rm -rf /tomcat/webapps /tomcat/logs /tomcat/temp && \
    find /tomcat/ -type d -exec chmod o+x {} + && \
    chmod o+x /tomcat/bin/*.sh && \
    mkdir $CATALINA_BASE/lib && \
    curl https://repo1.maven.org/maven2/com/sun/mail/javax.mail/1.6.2/javax.mail-1.6.2.jar -o $CATALINA_BASE/lib/javax.mail-1.6.2.jar && \
    mkdir $CATALINA_BASE/webapps

EXPOSE 8080

ENTRYPOINT ["/tomcat/bin/catalina.sh", "run"]

LABEL org.mmbase.authors="michiel@mmbase.org"
LABEL org.mmbase.description="MMBase environment with (an empty) tomcat"


# The onbuild commands to install the application when this image is overlaid

ONBUILD ARG PROJECT_VERSION
ONBUILD ARG NAME
ONBUILD ARG CONTEXT
ONBUILD ENV CONTEXT=${CONTEXT}

# Link to use in 404 page of tomcat
ONBUILD ARG DOCLINK
ONBUILD ENV DOCLINK=${DOCLINK}




ONBUILD ARG JARS_TO_SCAN=UNSET
ONBUILD ARG CLUSTERING
ONBUILD ARG COPY_TESTS
ONBUILD ARG CI_COMMIT_REF_NAME
ONBUILD ARG CI_COMMIT_SHA
ONBUILD ARG CI_COMMIT_TITLE
ONBUILD ARG CI_COMMIT_TIMESTAMP
ONBUILD ADD target/*${PROJECT_VERSION}.war /tmp/app.war


# if clustering, it also makes some sense to have a peristent work dir (to write sessions in)
ONBUILD RUN (\
     if [ -z "$CONTEXT" ] ; then \
        CONTEXT=ROOT; \
     fi && \
     cd ${CATALINA_BASE}/webapps && \
     mkdir -p ${CONTEXT} && \
     chmod 755 ${CONTEXT} && \
     cd ${CONTEXT} && \
     unzip -q /tmp/app.war && \
     rm /tmp/app.war &&\
     if [ "$CLUSTERING" == "true" ] ; then  \
         (cd ${CATALINA_BASE} && rm -r work && mkdir /data/work && chmod 2775 /data/work && ln -s /data/work work) && \
         cp -f /tmp/clustering/context.xml ${CATALINA_BASE}/conf/context.xml && \
         sed -E -i -f /tmp/clustering/add-cluster.sed  ${CATALINA_BASE}/conf/server.xml && \
         if [ "$COPY_TESTS" == "true" ] ; then cp /tmp/clustering/test-clustering.jspx .; fi ; \
     fi && \
     rm -rf /tmp/* \
     )


ONBUILD LABEL version="${PROJECT_VERSION}"

# We need regular security patches. E.g. on every build of the application
ONBUILD RUN apt-get update && apt-get -y upgrade && \
  apt-get clean && rm -rf /var/lib/apt/lists/* && \
  ( if [ "$JARS_TO_SCAN" != 'UNSET' ] ; then sed -E -i "s|^(tomcat.util.scan.StandardJarScanFilter.jarsToScan[ \t]*=)(.*)$|\1${JARS_TO_SCAN}|g"   ${CATALINA_BASE}/conf/catalina.properties ; fi ) && \
  for errorfile in ${CATALINA_BASE}/errorpages/*.html  ; do \
    sed -E -i "s|class='doclink' href='(.*?)'|class='doclink' href='${DOCLINK:-https://wiki.vpro.nl/}'|g" ${errorfile} && \
    ( if [ "$CONTEXT" != 'ROOT' ] ; then sed -E -i "s|class='home' href='(.*?)'|class='home' href='/${CONTEXT}'|g" ${errorfile} ; fi ) ; \
  done && \
  (echo "${NAME} version=${PROJECT_VERSION}") >> /DOCKER.BUILD && \
  (echo -e "${NAME} git version=${CI_COMMIT_SHA}\t${CI_COMMIT_REF_NAME}\t${CI_COMMIT_TIMESTAMP}\t${CI_COMMIT_TITLE}") >> /DOCKER.BUILD && \
  (echo -n "${NAME} build time=" ; date -Iseconds) >> /DOCKER.BUILD



