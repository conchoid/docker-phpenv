#!/bin/sh

set -eux

apt-get update && apt-get -y install  \
  autoconf \
  coreutils \
  dpkg \
  dpkg-dev \
  file \
  g++ \
  gcc \
  gnupg \
  libbz2-dev \
  libcurl3 \
  libcurl4-gnutls-dev \
  libedit-dev \
  libevent-dev \
  libghc-readline-dev \
  libjpeg62-turbo-dev \
  libmcrypt-dev \
  libpng-dev \
  libtidy-dev \
  libxml2-dev \
  libxslt1-dev \
  m4 \
  make \
  mercurial \
  patch \
  pkgconf \
  python \
  python-dev \
  re2c \
  sqlite3 \
  tar \
  tidy 


# openssl1.0.x and related libssl packages are required for installing php5.x by phpenv.
echo "deb http://ftp.br.debian.org/debian/ jessie main" > /etc/apt/sources.list.d/jessie.list 
apt-get update && apt-get -y install --allow-downgrades \
  openssl="1.0.1t-1+deb8u8" \
  libssl1.0.2="1.0.2l-2+deb9u3" \
  libssl-dev="1.0.1t-1+deb8u8" 
rm -f /etc/apt/sources.list.d/jessie.list 

apt-get clean
rm -rf /var/lib/apt/lists/*

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
