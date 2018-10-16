#!/bin/sh

set -eux

apt-get -y install apt-transport-https="1.4.8" \
&& apt-get -y install --allow-downgrades openssl="1.0.1t-1+deb8u8" \
  libssl1.0.2="1.0.2l-2+deb9u3" \
  libssl-dev="1.0.1t-1+deb8u8" \
  libssl-doc="1.0.1t-1+deb8u8" \
&& apt-get -y install  \
  autoconf="2.69-10" \
  ca-certificates="20161130+nmu1+deb9u1" \
  coreutils="8.26-3" \
  curl="7.52.1-5+deb9u6" \
  dpkg-dev="1.18.25" \
  dpkg="1.18.25" \
  file="1:5.30-1+deb9u2" \
  g++="4:6.3.0-4" \
  gcc="4:6.3.0-4" \
  git \
  gnupg="2.1.18-8~deb9u2" \
  libbz2-dev="1.0.6-8.1" \
  libcurl4-gnutls-dev="7.52.1-5+deb9u7" \
  libedit-dev="3.1-20160903-3" \
  libevent-dev="2.0.21-stable-3" \
  libghc-readline-dev="1.0.3.0-7" \
  libjpeg62-turbo-dev="1:1.5.1-2" \
  libmcrypt-dev="2.5.8-3.3" \
  libpng-dev="1.6.28-1" \
  libtidy-dev="1:5.2.0-2+0~20180714172546.1+stretch~1.gbpc7c60a" \
  libxml2-dev="2.9.4+dfsg1-2.2+deb9u2" \
  libxslt1-dev="1.1.29-2.1" \
  m4="1.4.18-1" \
  make="4.1-9.1" \
  mercurial="4.0-1+deb9u1" \
  patch="2.7.5-1+deb9u1" \
  php5.6-dev \
  pkgconf="0.9.12-6" \
  python-dev="2.7.13-2" \
  python="2.7.13-2" \
  re2c="0.16-2" \
  sqlite3="3.16.2-5+deb9u1" \
  subversion="1.9.5-1+deb9u2" \
  tar="1.29b-1.1" \
  tidy="1:5.2.0-2+0~20180714172546.1+stretch~1.gbpc7c60a" \
  libcurl3="7.52.1-5+deb9u6" \
  wget="1.18-5+deb9u2"
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
