FROM eclipse-temurin:8u452-b09-jdk-noble AS buildffmeg

# we need ffmpeg for streams contribution. This is the most expensive step. Do it first.
RUN apt-get -y update && apt-get -y install git make gcc nasm pkg-config libx264-dev libxext-dev libxfixes-dev zlib1g-dev && \
    git clone  --branch n4.4.5  https://github.com/FFmpeg/FFmpeg.git  --single-branch && \
    cd FFmpeg/ && ./configure --enable-nonfree --enable-gpl --enable-libx264 --enable-zlib  && \
    make install
