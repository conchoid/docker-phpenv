#!/bin/sh

set -eux

# TODO: Fix package version
apk add --no-cache \
    apache2-dev \
    autoconf \
    bash \
    bzip2-dev \
    ca-certificates \
    coreutils \
    curl \
    curl-dev \
    dpkg \
    dpkg-dev \
    file \
    g++ \
    gcc \
    git \
    gnupg \
    icu-dev \
    libc-dev \
    libedit-dev \
    libevent-dev \
    libjpeg-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libxml2-dev \
    libxslt-dev \
    m4 \
    make \
    mercurial \
    openssl \
    openssh \
    patch \
    php5-dev \
    pkgconf \
    re2c \
    readline-dev \
    sqlite-dev \
    subversion \
    tar \
    tidyhtml-dev \
    tidyhtml-libs \
    xz

curl -o lemon.c http://www.sqlite.org/src/raw/tool/lemon.c?name=7f7735326ca9c3b48327b241063cee52d35d44e20ebe1b3624a81658052a4d39
gcc -o lemon lemon.c
mv lemon /usr/local/bin/
rm lemon.c

# buffio.h is deprecated but needed for building php prior to 7.2.
curl -o /usr/include/buffio.h https://raw.githubusercontent.com/htacg/tidy-html5/5.6.0/include/buffio.h

# bison 2.x is required for building php5.x
WORK_DIR="/tmp/bison/"
BISON_VERSION="2.6.4"
mkdir -p $WORK_DIR/downloads $WORK_DIR/src
wget http://ftp.gnu.org/gnu/bison/bison-$BISON_VERSION.tar.gz -P $WORK_DIR/downloads/
tar -zxf $WORK_DIR/downloads/bison-$BISON_VERSION.tar.gz -C $WORK_DIR/src
(
  cd $WORK_DIR/src/bison-$BISON_VERSION/
  ./configure --prefix=/usr/local/lib/bison-$BISON_VERSION
  make && make install
  ln -s /usr/local/lib/bison-$BISON_VERSION/bin/bison /usr/local/bin/bison
)
rm -rf $WORK_DIR
