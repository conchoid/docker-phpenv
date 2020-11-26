#!/bin/sh

set -eux
# php install build deps
apt-get update && apt-get -y --allow-downgrades install  \
  autoconf \
  coreutils \
  dpkg \
  dpkg-dev \
  file \
  g++ \
  gnupg \
  libbz2-dev \
  libcurl3 \
  libcurl4-gnutls-dev \
  libedit-dev \
  libevent-dev \
  libjpeg62-turbo-dev \
  libkrb5-dev \
  libmcrypt-dev \
  libonig-dev \
  libpng-dev \
  libreadline-dev \
  libsqlite3-dev \
  libtidy-dev \
  libxml2-dev="2.9.4+dfsg1-2.2+deb9u2" \
  libxml2="2.9.4+dfsg1-2.2+deb9u2" \
  libxslt1-dev \
  libzip-dev \
  mercurial \
  patch \
  pkgconf \
  python \
  python-dev \
  re2c \
  sqlite3 \
  tidy

# openssl1.0.x and related libssl packages are required for installing php5.x by phpenv.
echo "deb http://ftp.br.debian.org/debian/ jessie main" > /etc/apt/sources.list.d/jessie.list 
apt-get update && apt-get -y install --allow-downgrades \
  openssl="1.0.1t-1+deb8u8" \
  libssl1.0.2="1.0.2u-1~deb9u1" \
  libssl-dev="1.0.1t-1+deb8u8" 
rm -f /etc/apt/sources.list.d/jessie.list 

apt-get clean
rm -rf /var/lib/apt/lists/*
