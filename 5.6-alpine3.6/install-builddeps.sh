#!/bin/sh

set -eux

if ls /var/cache/apk/*.apk 1>/dev/null 2>&1; then
  # use cache if exists
  apk add /var/cache/apk/*.apk
  rm /var/cache/apk/*.apk
else
  mkdir -p /var/cache/apk && ln -s /var/cache/apk /etc/apk/cache

  apk add --no-cache \
      autoconf="2.69-r0" \
      bash="4.3.48-r1" \
      bzip2-dev="1.0.6-r5" \
      ca-certificates="20161130-r2" \
      coreutils="8.27-r0" \
      curl="7.61.1-r0" \
      curl-dev="7.61.1-r0" \
      dpkg="1.18.23-r2" \
      dpkg-dev="1.18.23-r2" \
      file="5.32-r0" \
      g++="6.3.0-r4" \
      gcc="6.3.0-r4" \
      git="2.13.7-r1" \
      gnupg="2.1.20-r1" \
      icu-dev="58.2-r2" \
      libc-dev="0.7.1-r0" \
      libedit-dev="20170329.3.1-r2" \
      libevent-dev="2.1.8-r1" \
      libjpeg-turbo-dev="1.5.3-r2" \
      libltdl="2.4.6-r1" \
      libmcrypt-dev="2.5.8-r7" \
      libpng-dev="1.6.29-r1" \
      libxml2-dev="2.9.8-r1" \
      libxslt-dev="1.1.29-r3" \
      m4="1.4.18-r0" \
      make="4.2.1-r0" \
      mercurial="4.5.2-r0" \
      openssl="1.0.2o-r1" \
      openssl-dev="1.0.2o-r1" \
      openssh="7.5_p1-r3" \
      patch="2.7.5-r3" \
      php5-dev="5.6.37-r0" \
      pkgconf="1.3.7-r0" \
      python2="2.7.15-r0" \
      python2-dev="2.7.15-r0" \
      re2c="0.16-r0" \
      readline-dev="6.3.008-r5" \
      sqlite-dev="3.20.1-r2" \
      subversion="1.9.7-r0" \
      tar="1.29-r1" \
      tidyhtml-dev="5.2.0-r1" \
      tidyhtml-libs="5.2.0-r1" \
      xz="5.2.3-r0"

  rm /etc/apk/cache
fi

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

ln -s -f "$(which php5)" "$(dirname $(which php5))/php"
ln -s -f "$(which php-config5)" "$(dirname $(which php-config5))/php-config"
