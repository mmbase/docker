FROM mmbase/tomcat:latest

RUN curl -L 'https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=org.mmbase&a=example-webapp&v=1.9-SNAPSHOT&p=war' -o /$CATALINA_BASE/webapps/ROOT.war
