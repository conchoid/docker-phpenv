#!/bin/sh
set -eux
apk add --no-cache \
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
    openssl-dev \
    openssh \
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
