include ../docker.mk
GROUP=org/mmbase
ARTIFACT=example-webapp
VERSION=1.9-SNAPSHOT
NAME=mmbase/$(ARTIFACT)
DEPS := Dockerfile target/example.war ../docker.mk


build: $(DEPS)

target/get-url.xslt:
	mkdir -p target
	curl -s https://raw.githubusercontent.com/mmprogrami/sonatype-snapshot-action/refs/heads/main/get-url.xslt > $@


target/example.war: target/get-url.xslt
	mkdir -p target
	curl $$(curl  -s https://central.sonatype.com/repository/maven-snapshots/$(GROUP)/$(ARTIFACT)/$(VERSION)/maven-metadata.xml | xsltproc target/get-url.xslt -) > $@



#run: docker
#	docker run --name mmbase-example-webapp -p 8080:8080 $(NAME)
