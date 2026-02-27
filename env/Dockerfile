ARG JAVA_VERSION=8u482-b08-jdk-noble
FROM eclipse-temurin:${JAVA_VERSION}


# avoid warnings about that from debconf
ENV DEBIAN_FRONTEND=noninteractive

# graphviz, figlet: used by some tools in mmbase
# libxrender1 libxtst6 libxi6: used by awt (used by tagstripper)
# maven: to build
# nodejs: build @ github
# make: used to download samples in streams
# unzip: used to unzip the war
# less: everybody will use this to view files
#
RUN  apt-get -y update && apt-get -y upgrade && apt-get -y install imagemagick graphviz figlet libxrender1 libxtst6 libxi6 libx264-164 less  && \
    apt-get clean && rm -rf /var/cache/apt/lists


ARG JAVA_MAJOR
ENV JAVA_MAJOR=${JAVA_MAJOR}

ARG CI_COMMIT_REF_NAME
ARG CI_COMMIT_SHA
ARG CI_COMMIT_REF_NAME
ARG CI_COMMIT_TITLE

# This makes ${USER.HOME} /
ENV HOME=/

ENV TZ=Europe/Amsterdam
ENV PGTZ=Europe/Amsterdam


# 'When invoked as an interactive shell with the name sh, Bash looks for the variable ENV, expands its value if it is defined, and uses the expanded value as the name of a file to read and execute'
ENV ENV=/.binbash
COPY binbash /.binbash

# - Setting up timezone and stuff
RUN echo "dash dash/sh boolean false" | debconf-set-selections &&  dpkg-reconfigure dash && \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
  dpkg-reconfigure --frontend noninteractive tzdata && \
  locale-gen nl_NL && \
  mkdir -p /work && mkdir -p /data


# compute Java major version at build time and expose it to interactive shells
RUN JV=$(java -version 2>&1 | awk -F[\".] '/version/ {print ($2 == 1 ? $3 : $2)}') && \
    (echo  "mmbase/env git version=${CI_COMMIT_SHA}\t${CI_COMMIT_REF_NAME}\t${CI_COMMIT_TIMESTAMP}\t${CI_COMMIT_TITLE}") > /DOCKER.BUILD && \
    (echo  -n "mmbase/env build time=" ; date -Iseconds) >> /DOCKER.BUILD


# With bearable key bindings:
COPY inputrc /etc
# And a nicer bash prompt
COPY bashrc /.bashrc
# ' Failed to source defaults.vim' (even an empty vi config file like that avoid it)
COPY exrc /.exrc

# Clean up default /etc/bash.bashrc a bit (no call to groups)
COPY bash.bashrc /etc/bash.bashrc

ENV HISTFILE=/work/.bash_history
ENV LESSHISTFILE=/work/.lesshst

WORKDIR /work
ENTRYPOINT ["/bin/bash"]

LABEL org.mmbase.authors="michiel@mmbase.org"
LABEL org.mmbase.description="MMBase environment which can be used for building and running it"
