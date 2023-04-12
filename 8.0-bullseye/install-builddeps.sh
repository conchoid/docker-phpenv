#!/bin/sh

set -eux

apt-get update && apt-get -y --allow-downgrades install  \
  autoconf2.13 \
  coreutils \
  dpkg \
  dpkg-dev \
  file \
  g++ \
  gcc \
  gnupg \
  icu-devtools \
  libicu-dev \
  libssl1.1 \
  libxml2="2.9.10+dfsg-6.7+deb11u3" \
  libxml2-dev="2.9.10+dfsg-6.7+deb11u3" \
  libssl-dev \
  libzip4 \
  libzip-dev \
  sqlite3 \
  libsqlite3-dev \
  libonig-dev \
  zlib1g-dev \
  libbz2-dev \
  libjpeg-dev \
  libpng-dev \
  libmcrypt-dev \
  libreadline-dev \
  libcurl4-gnutls-dev \
  libxslt1-dev \
  libtidy-dev \
  re2c

# buffio.h is deprecated but needed for building php prior to 7.2.
curl -o /usr/include/buffio.h https://raw.githubusercontent.com/htacg/tidy-html5/5.6.0/include/buffio.h

# bison 2.x is required for building php5.x
WORK_DIR="/tmp/bison/"
BISON_VERSION="2.6.4"
mkdir -p ${WORK_DIR}/downloads ${WORK_DIR}/src
wget http://ftp.gnu.org/gnu/bison/bison-${BISON_VERSION}.tar.gz -P ${WORK_DIR}/downloads/
tar -zxf ${WORK_DIR}/downloads/bison-${BISON_VERSION}.tar.gz -C ${WORK_DIR}/src
(
  cd ${WORK_DIR}/src/bison-${BISON_VERSION}/
  ./configure --prefix=/usr/local/lib/bison-${BISON_VERSION}
  make && make install
  ln -s /usr/local/lib/bison-${BISON_VERSION}/bin/bison /usr/local/bin/bison
)
rm -rf ${WORK_DIR}
ln -s /usr/include/x86_64-linux-gnu/curl /usr/include/curl
