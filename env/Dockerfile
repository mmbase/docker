FROM adoptopenjdk/openjdk8:debian-slim AS buildffmeg

# we need ffmpeg for streams contribution. This is the most expensive step. Do it first.
RUN apt-get -y update && apt-get -y install git make gcc nasm pkg-config libx264-dev libxext-dev libxfixes-dev zlib1g-dev && \
    git clone  --branch n4.4  https://github.com/FFmpeg/FFmpeg.git  && \
    cd FFmpeg/ && ./configure --enable-nonfree --enable-gpl --enable-libx264 --enable-zlib  && \
    make install


FROM adoptopenjdk/openjdk8:debian-slim

LABEL org.mmbase.authors="michiel@mmbase.org"
LABEL org.mmbase.description="MMBase environment which can be used for building and running it"

# graphviz, figlet: used by some tools in mmbase
# libxrender1 libxtst6 libxi6: used by awt (used by tagstripper)
# maven: to build
# nodejs: build @ github
# make: used to download samples in streams
#
RUN  apt-get -y update && apt-get -y upgrade && apt-get -y install imagemagick graphviz figlet libxrender1 libxtst6 libxi6 libx264-155 && \
    apt-get clean && rm -rf /var/cache/apt/lists

COPY --from=buildffmeg  /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg



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
