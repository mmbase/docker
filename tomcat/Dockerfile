ARG REGISTRY=ghcr.io/

FROM ${REGISTRY}mmbase/env:latest

ENV TOMCAT_VERSION=9.0.100
ENV CATALINA_BASE=/catalina-base
ENV CATALINA_HOME=/tomcat

#ENV org.apache.tomcat.util.digester.PROPERTY_SOURCE=org.apache.tomcat.util.digester.Digester$EnvironmentPropertySource.

RUN apt-get update && apt-get -y upgrade && apt-get -y install inotify-tools unzip apache2-utils && \
    apt-get clean && rm -rf /var/cache/apt/lists

# We want to split off catalina base, default it's catalina_home
ADD catalina_base ${CATALINA_BASE}/

RUN cd / && curl https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz | tar zxf - && \
    ln -s apache-tomcat-$TOMCAT_VERSION ${CATALINA_HOME} && \
    find ${CATALINA_HOME} -type d -exec chmod o+x {} + && \
    chmod o+x ${CATALINA_HOME}/bin/*.sh && \
    curl https://repo1.maven.org/maven2/com/sun/mail/javax.mail/1.6.2/javax.mail-1.6.2.jar -o ${CATALINA_HOME}/lib/javax.mail-1.6.2.jar

EXPOSE 8080
WORKDIR $CATALINA_BASE

ENTRYPOINT ["/catalina-base/bin/start.sh"]

LABEL org.mmbase.authors="michiel@mmbase.org"
LABEL org.mmbase.description="MMBase environment with (an empty) tomcat"

RUN echo Catalina base: ${CATALINA_BASE} && \
  rm -rf ${CATALINA_HOME}/webapps.dist && \
  chmod -R o-w ${CATALINA_HOME} && \
  chmod -R g=o ${CATALINA_HOME} && \
  chmod -R o-w ${CATALINA_BASE} && \
  chmod -R g=o ${CATALINA_BASE} && \
  mkdir -p  ${CATALINA_BASE}/conf/Catalina/localhost && \
  chmod 755 ${CATALINA_BASE}/conf/Catalina/localhost && \
  for directory in 'webapps' 'work'; do \
      mkdir -p ${CATALINA_BASE}/$directory && \
      rm -rf ${CATALINA_HOME}/$directory; \
  done && \
  chmod 755 ${CATALINA_BASE}/webapps && \
  chmod 775 ${CATALINA_BASE}/work && \
  (cd ${CATALINA_HOME} && rm -rf temp && rm -rf logs) && \
  mkdir -p /data/logs && \
  chmod 2775 /data /data/logs && \
  (cd ${CATALINA_BASE} && ln -s /data/logs logs) && \
  sed -E -i "s|^(tomcat.util.scan.StandardJarScanFilter.jarsToScan[ \t]*=)(.*)$|\1${JARS_TO_SCAN}|g"  ${CATALINA_BASE}/conf/catalina.properties && \
  mkdir ${CATALINA_BASE}/lib && \
  (echo -e "mmbase/tomcat git version=${CI_COMMIT_SHA}\t${CI_COMMIT_REF_NAME}\t${CI_COMMIT_TIMESTAMP}\t${CI_COMMIT_TITLE}") > /DOCKER.BUILD && \
  (echo -n "mmbase/tomcat build time=" ; date -Iseconds) >> /DOCKER.BUILD



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
     ls -lag /tmp/app.war && \
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
  (echo "${NAME} version=${PROJECT_VERSION}") >> /DOCKER.BUILD && \
  (echo -e "${NAME} git version=${CI_COMMIT_SHA}\t${CI_COMMIT_REF_NAME}\t${CI_COMMIT_TIMESTAMP}\t${CI_COMMIT_TITLE}") >> /DOCKER.BUILD && \
  (echo -n "${NAME} build time=" ; date -Iseconds) >> /DOCKER.BUILD



