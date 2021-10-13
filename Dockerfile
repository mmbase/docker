#FROM nortthon/java5
FROM adoptopenjdk/openjdk8:debian-slim

RUN apt-get -y update && apt-get -y upgrade

# we need ffmpeg for streams contribution. This is the most expensive step. Do it first.
RUN apt-get -y install git make gcc nasm pkg-config libx264-dev libxext-dev libxfixes-dev zlib1g-dev && \
    git clone  --branch n4.4  https://github.com/FFmpeg/FFmpeg.git  && \
    cd FFmpeg/ && ./configure --enable-nonfree --enable-gpl --enable-libx264 --enable-zlib && \
    make install


RUN rm -rf FFmpeg

RUN apt-get -y upgrade && \
    apt-get -y install imagemagick graphviz figlet less curl maven nodejs


# the maven2 package of this debian doesn't work with java 5
#RUN curl   https://archive.apache.org/dist/maven/binaries/apache-maven-2.2.1-bin.tar.gz -o apache-maven.tar.gz && \
#    tar zxf apache-maven.tar.gz && \
#    ln -s  /apache-maven-2.2.1 /opt/apache-maven && \
#    curl https://downloads.bouncycastle.org/java/bcprov-ext-jdk15on-169.jar -o /jdk1.5.0_22/jre/lib/ext/bcprov-ext-jdk15on-169.jar

#COPY java.security /jdk1.5.0_22/jre/lib/security
#ENV PATH="/opt/apache-maven/bin:${PATH}"


RUN useradd -ms /bin/bash maven

#USER maven
#WORKDIR /home/maven

#RUN mkdir -p /home/maven/.m2/repository/org/apache
#ADD maven /home/maven/.m2/repository/org/apache
