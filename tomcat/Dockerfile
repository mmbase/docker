ARG REGISTRY=ghcr.io/
ARG TAG=latest

FROM ${REGISTRY}mmbase/env:${TAG}

ENV TOMCAT_VERSION=9.0.113
 # Same as in official tomcat image, referred to in server.xml
ENV TOMCAT_MAJOR=9

ENV JAVA_MAIL_VERSION=1.6.2
ENV JAVA_ACTIVATION=1.2.0

ARG CI_COMMIT_REF_NAME
ARG CI_COMMIT_SHA
ARG CI_COMMIT_TITLE
ARG CI_COMMIT_TIMESTAMP

ENV CATALINA_BASE=/catalina-base
ENV CATALINA_HOME=/tomcat

#ENV org.apache.tomcat.util.digester.PROPERTY_SOURCE=org.apache.tomcat.util.digester.Digester$EnvironmentPropertySource.

RUN apt-get update && apt-get -y upgrade && apt-get -y install inotify-tools unzip apache2-utils psmisc curl && \
    apt-get clean && rm -rf /var/cache/apt/lists

# We want to split off catalina base, default it's catalina_home
ADD catalina_base ${CATALINA_BASE}/

RUN cd / && curl https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz | tar zxf - && \
    ln -s apache-tomcat-$TOMCAT_VERSION ${CATALINA_HOME} && \
    rm -rf ${CATALINA_HOME}/webapps.dist && \
    (cd ${CATALINA_HOME} && rm -rf temp && rm -rf logs) && \
    chmod -R g+r ${CATALINA_HOME}/conf && \
    chmod g+x ${CATALINA_HOME}/conf && \
    chmod -R o=g ${CATALINA_HOME}/ && \
    curl https://repo1.maven.org/maven2/com/sun/mail/javax.mail/${JAVA_MAIL_VERSION}/javax.mail-${JAVA_MAIL_VERSION}.jar -o ${CATALINA_HOME}/lib/javax.mail-$JAVA_MAIL_VERSION.jar



RUN if [ "$JAVA_MAJOR" -ge "9" ] ; then \
       echo "Downloading activation for java 9 or higher" && \
       curl https://repo1.maven.org/maven2/com/sun/activation/javax.activation/${JAVA_ACTIVATION}/javax.activation-${JAVA_ACTIVATION}.jar -o ${CATALINA_HOME}/lib/javax.activation-${JAVA_ACTIVATION}.jar ; \
    else \
       echo "No need for activation"; \
    fi

EXPOSE 8080 8000
WORKDIR $CATALINA_BASE

ENV HISTFILE=/data/.bash_history
ENV PSQL_HISTORY=/data/.pg_history
#ENV PSQL_EDITOR=/usr/bin/vi
ENV LESSHISTFILE=/data/.lesshst


ENTRYPOINT ["/catalina-base/bin/start.sh"]

LABEL org.mmbase.authors="michiel@mmbase.org"
LABEL org.mmbase.description="MMBase environment with (an empty) tomcat"

RUN useradd -u 10001 mmbase

RUN echo Catalina base: ${CATALINA_BASE} && \
  chmod -R o-w ${CATALINA_BASE} && \
  chmod -R g=o ${CATALINA_BASE} && \
  mkdir -p  ${CATALINA_BASE}/conf/Catalina/localhost && \
  chmod 755 ${CATALINA_BASE}/conf/Catalina/localhost && \
  for directory in 'webapps' 'work'; do \
      mkdir -p ${CATALINA_BASE}/$directory ; \
  done && \
  chmod 755 ${CATALINA_BASE}/webapps && \
  mkdir -p /data/logs && \
  chmod 2775 /data /data/logs /work && \
  chown mmbase:mmbase /data /data/logs /work && \
  (cd ${CATALINA_BASE} && ln -s /data/logs logs && rm -rf work && ln -s /work work) && \
  sed -E -i "s|^(tomcat.util.scan.StandardJarScanFilter.jarsToScan[ \t]*=)(.*)$|\1${JARS_TO_SCAN}|g"  ${CATALINA_BASE}/conf/catalina.properties && \
  mkdir ${CATALINA_BASE}/lib && \
  (echo "mmbase/tomcat git version=${CI_COMMIT_SHA}\t${CI_COMMIT_REF_NAME}\t${CI_COMMIT_TIMESTAMP}\t${CI_COMMIT_TITLE}") >> /DOCKER.BUILD && \
  (echo -n "mmbase/tomcat build time=" ; date -Iseconds) >> /DOCKER.BUILD


# some files which might be needed during build
COPY --parents clustering ajp /tmp/


USER mmbase

# The onbuild commands to install the application when this image is overlaid

ONBUILD USER root

ONBUILD ARG PROJECT_VERSION
ONBUILD ARG NAME
ONBUILD ARG CONTEXT
ONBUILD ENV CONTEXT=${CONTEXT}

# Link to use in 404 page of tomcat
ONBUILD ARG DOCLINK
ONBUILD ENV DOCLINK=${DOCLINK}


ONBUILD ARG JARS_TO_SCAN=UNSET
ONBUILD ARG CLUSTERING
ONBUILD ARG AJP
ONBUILD ARG COPY_TESTS
ONBUILD ARG CI_COMMIT_REF_NAME
ONBUILD ARG CI_COMMIT_SHA
ONBUILD ARG CI_COMMIT_TITLE
ONBUILD ARG CI_COMMIT_TIMESTAMP

ONBUILD ADD target/*${PROJECT_VERSION}.war /tmp/app.war

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
     mv WEB-INF/data/* /data/ 2>/dev/null ; \
     rm WEB-INF/data -rf && \
     ln -s /data WEB-INF/data && \
     rm /tmp/app.war &&\
     if [ "$CLUSTERING" == "true" ] ; then  \
         sed -E -i -f /tmp/clustering/add-cluster.sed  ${CATALINA_BASE}/conf/server.xml && \
         if [ "$COPY_TESTS" == "true" ] ; then cp /tmp/clustering/test-clustering.jspx .; fi ; \
     fi && \
     if [ "$AJP" == "true" ] ; then  \
         sed -E -i -f /tmp/ajp/add-ajp.sed  ${CATALINA_BASE}/conf/server.xml ; \
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





ONBUILD USER mmbase

