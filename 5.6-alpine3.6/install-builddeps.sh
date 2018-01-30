#!/bin/sh

set -eux

# TODO: Fix package version
apk add --no-cache \
    apache2="2.4.27-r1" \
    autoconf="2.69-r0" \
    bash="4.3.48-r1" \
    bzip2-dev="1.0.6-r5" \
    ca-certificates="20161130-r2" \
    coreutils="8.27-r0" \
    curl="7.57.0-r0" \
    curl-dev="7.57.0-r0" \
    dpkg="1.18.23-r2" \
    dpkg-dev="1.18.23-r2" \
    file="5.32-r0" \
    g++="6.3.0-r4" \
    gcc="6.3.0-r4" \
    git="2.13.5-r0" \
    gnupg="2.1.20-r0" \
    icu-dev="58.2-r2" \
    libc-dev="0.7.1-r0" \
    libedit-dev="20170329.3.1-r2" \
    libevent-dev="2.1.8-r1" \
    libjpeg-turbo-dev="1.5.1-r0" \
    libmcrypt-dev="2.5.8-r7" \
    libpng-dev="1.6.29-r1" \
    libxml2-dev="2.9.5-r0" \
    libxslt-dev="1.1.29-r3" \
    m4="1.4.18-r0" \
    make="4.2.1-r0" \
    mercurial="4.3.1-r0" \
    openssl="1.0.2n-r0" \
    openssh="7.5_p1-r2" \
    patch="2.7.5-r1" \
    php5-dev="5.6.32-r0" \
    pkgconf="1.3.7-r0" \
    re2c="0.16-r0" \
    readline-dev="6.3.008-r5" \
    sqlite-dev="3.20.1-r0" \
    subversion="1.9.7-r0" \
    tar="1.29-r1" \
    tidyhtml-dev="5.2.0-r1" \
    tidyhtml-libs="5.2.0-r1" \
    xz="5.2.3-r0"

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
