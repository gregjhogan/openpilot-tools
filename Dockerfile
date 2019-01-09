# for raspberry pi: --build-arg BASE_IMAGE=armv7/armhf-ubuntu:16.04
ARG BASE_IMAGE=ubuntu:16.04
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
        apt-transport-https \
        build-essential \
        autoconf \
        automake \
        clang \
        clang-3.8 \
        libtool \
        pkg-config \
        python \
        python-dev \
        python-setuptools \
        python-pip \
        git \
        curl \
        ffmpeg \
        libavformat-dev \
        libavcodec-dev \
        libavdevice-dev \
        libavutil-dev \
        libswscale-dev \
        libavresample-dev \
        libavfilter-dev \
        libarchive-dev \
        libpng-dev \
        libfreetype6-dev \
        python-qt4 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /tmp \
    && curl -LO https://capnproto.org/capnproto-c++-0.6.1.tar.gz \
    && tar -zxf /tmp/capnproto-c++-0.6.1.tar.gz \
    && cd capnproto-c++-0.6.1 \
    && ./configure --prefix=/usr CPPFLAGS=-DPIC CFLAGS=-fPIC CXXFLAGS=-fPIC LDFLAGS=-fPIC --disable-shared --enable-static \
    && make -j4 \
    && make install \
    && cd /tmp \
    && rm -rf capnproto-c++-0.6.1.tar.gz capnproto-c++-0.6.1

RUN cd /tmp \
    && git clone -b arm https://github.com/gregjhogan/c-capnproto.git \
    && cd c-capnproto \
    && git submodule update --init --recursive \
    && autoreconf -f -i -s \
    && CFLAGS="-fPIC" ./configure --prefix=/usr/local \
    && make -j4 \
    && make install \
    && cd /tmp \
    && rm -rf c-capnproto

RUN cd /tmp \
    && curl -LO https://github.com/zeromq/libzmq/releases/download/v4.2.3/zeromq-4.2.3.tar.gz \
    && tar -zxf zeromq-4.2.3.tar.gz \
    && cd zeromq-4.2.3 \
    && ./autogen.sh \
    && ./configure CPPFLAGS=-DPIC CFLAGS=-fPIC CXXFLAGS=-fPIC LDFLAGS=-fPIC --disable-shared --enable-static \
    && make \
    && make install \
    && cd /tmp \
    && rm -rf zeromq-4.2.3.tar.gz zeromq-4.2.3

COPY requirements.txt /tmp/requirements.txt
RUN cd /tmp \
    && pip install --no-cache-dir -r requirements.txt \
    && rm requirements.txt

RUN cd /tmp \
    && curl -LO https://raw.githubusercontent.com/commaai/openpilot/devel/requirements_openpilot.txt \
    && pip install --no-cache-dir -r requirements_openpilot.txt \
    && rm requirements_openpilot.txt

# create on host machine and mount into container:
# mkdir -p mkdir /data/params && chown $USER /data/params
VOLUME /data
