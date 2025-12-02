FROM eclipse-temurin:8u472-b08-jdk-noble

# avoid warnings about that from debconf
ENV DEBIAN_FRONTEND=noninteractive

# graphviz, figlet: used by some tools in mmbase
# libxrender1 libxtst6 libxi6: used by awt (used by tagstripper)
# maven: to build
# nodejs: build @ github
# make: used to download samples in streams
# unzip: used to unzip the war
#
RUN  apt-get -y update && apt-get -y upgrade && apt-get -y install imagemagick graphviz figlet libxrender1 libxtst6 libxi6 libx264-164  && \
    apt-get clean && rm -rf /var/cache/apt/lists

COPY --from=ghcr.io/mmbase/ffmpeg:latest /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=ghcr.io/mmbase/ffmpeg:latest /DOCKER.BUILD /tmp/ffmpeg.DOCKER.BUILD

# This makes ${USER.HOME} /
ENV HOME=/

# Have a workable shell
SHELL ["/bin/bash", "-c"]

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
  mkdir -p /work && mkdir -p /data && \
  cat /tmp/ffmpeg.DOCKER.BUILD >> /DOCKER.BUILD



# With bearable key bindings:
COPY inputrc /etc
# And a nicer bash prompt
COPY bashrc /.bashrc
# ' Failed to source defaults.vim' (even an empty vi config file like that avoid it)
COPY exrc /.exrc

# Clean up default /etc/bash.bashrc a bit (no call to groups)
COPY bash.bashrc /etc/bash.bashrc

WORKDIR /work
ENTRYPOINT ["/bin/bash"]

LABEL org.mmbase.authors="michiel@mmbase.org"
LABEL org.mmbase.description="MMBase environment which can be used for building and running it"
