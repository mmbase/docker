FROM mmbase/env:latest
ENV TOMCAT_VERSION=9.0.54
ENV CATALINA_BASE=/catalina_base

RUN curl https://dlcdn.apache.org/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz | tar zxf - && \
    ln -s apache-tomcat-$TOMCAT_VERSION tomcat && \
    mkdir $CATALINA_BASE && \
    adduser --disabled-password --gecos '' tomcat && \
    chown -R tomcat $CATALINA_BASE && \
    chmod -R o+r /tomcat && \
    rm -rf /tomcat/webapps /tomcat/logs /tomcat/temp && \
    find /tomcat/ -type d -exec chmod o+x {} + && \
    chmod o+x /tomcat/bin/*.sh

USER tomcat
COPY  --chown=tomcat:tomcat catalina /$CATALINA_BASE

EXPOSE 8080

ENTRYPOINT /tomcat/bin/catalina.sh run

