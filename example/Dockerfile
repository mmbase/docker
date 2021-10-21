FROM mmbase/tomcat:1

ENV VERSION=1.9-SNAPSHOT

RUN curl -L "https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=org.mmbase&a=example-webapp&v=$VERSION&p=war" -o /$CATALINA_BASE/webapps/ROOT.war


LABEL org.mmbase.authors="michiel@mmbase.org"
LABEL org.mmbase.description="Tomcat with the MMBase Example Webapp"
