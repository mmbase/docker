FROM williamyeh/java7

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install maven2 imagemagick graphviz figlet
