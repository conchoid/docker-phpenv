# Docker Hub: conchoid/docker-phpenv:v1-1-8.5.8-trixie-arm64
FROM php:8.5.8-cli-trixie

# Preset locale to en_US.UTF-8
# https://docs.docker.com/samples/library/debian/#locales
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    wget curl git subversion \
    build-essential autoconf dpkg-dev file g++ gcc libc-dev make pkg-config libtool \
    bison re2c libxml2-dev libsqlite3-dev libssl-dev libcurl4-openssl-dev libonig-dev \
    zlib1g-dev libbz2-dev libpng-dev libjpeg-dev libreadline-dev libtidy-dev \
    libxslt-dev libzip-dev libicu-dev apt-transport-https lsb-release ca-certificates \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=conchoid/debian:trixie-slim-arm64 /usr/local/bin/git-lfs /usr/local/bin/git-lfs
RUN git lfs install

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN docker-php-ext-install bz2 xml

# Installing Composer.
# Refer to https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
# NOTE: Do not set COMPOSER_ALLOW_SUPERUSER=1 as Composer should be used
# only by non-root users in plugins.
ENV PATH="/composer/vendor/bin:$PATH"
ENV COMPOSER_HOME=/composer
ENV ROCRO_COMPOSER_VERSION=2.9.3
RUN EXPECTED_SIGNATURE="$(curl -fsSL --proto '=https' --tlsv1.2 https://composer.github.io/installer.sig)" \
    && curl -fsSL --proto '=https' --tlsv1.2 -o /tmp/installer.php https://getcomposer.org/installer \
    && ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', '/tmp/installer.php');")" \
    && if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then echo 'ERROR: Invalid installer signature' && rm /tmp/installer.php && exit 1; fi \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${ROCRO_COMPOSER_VERSION} \
    && rm /tmp/installer.php \
    && mkdir -p "${COMPOSER_HOME}" \
    && composer --ansi --version --no-interaction

# Install phpenv
ENV PHPENV_ROOT=/opt/phpenv
ENV PATH="${PHPENV_ROOT}/shims:${PHPENV_ROOT}/bin:${PATH}"
ENV ROCRO_PHP_CFLAGS="-lssl -lcrypto -Wno-error"
RUN ROCRO_PHPENV_VERSION=adc99a7a64564c8ad942b4ee1b3ad630a5b1cf96 \
    && PHP_BUILD_VERSION=068169fd17f54e3105620d525c6653399345090f \
    && git clone https://github.com/phpenv/phpenv.git ${PHPENV_ROOT} \
    && (cd ${PHPENV_ROOT} && git checkout ${ROCRO_PHPENV_VERSION}) \
    && git clone https://github.com/php-build/php-build ${PHPENV_ROOT}/plugins/php-build \
    && (cd ${PHPENV_ROOT}/plugins/php-build && git checkout ${PHP_BUILD_VERSION}) \
    && phpenv rehash \
    && rm -r ${PHPENV_ROOT}/.git ${PHPENV_ROOT}/plugins/php-build/.git \
    # Because the our phpenv container doesn't install apache2-dev package (to avoid conflict between openssl and libressl), put the
    # dummy "apxs" module and avoid the "phpenv global" command returning exit code 1. See below for where "apxs" in "phpenv global":
    # https://github.com/madumlao/phpenv/blob/085261129f7231fcd3b34401ad4af84b21df62eb/libexec/phpenv-global#L45
    && touch ${PHPENV_ROOT}/bin/apxs && chmod +x ${PHPENV_ROOT}/bin/apxs

ENV ROCRO_PHP_CONFIGURE_OPTS="--disable-fpm --disable-cgi --disable-intl"
ENV PHP_AUTOCONF=/usr/bin/autoconf

# Install all latest versions excludes older than one year since EOL.
# https://www.php.net/supported-versions.php
ENV PREINSTALLED_VERSIONS="\
8.2.30\n\
8.3.30\n\
8.4.19"
# 8.5.x system installed

RUN phpenv global system \
    && system_php_ver=$(php -v | head -1 | sed -e "s/^PHP \([0-9.]*\).*$/\1/") \
    && version_bin_dir="${PHPENV_ROOT}/versions/${system_php_ver}/bin" \
    && mkdir -p "${version_bin_dir}" \
    && cp "$(phpenv which php)" "${version_bin_dir}" \
    && cp "$(phpenv which php-config)" "${version_bin_dir}" \
    && cp "$(phpenv which phar)" "${version_bin_dir}" \
    && cp "$(phpenv which phar.phar)" "${version_bin_dir}" \
    && cp /usr/bin/composer "${version_bin_dir}" \
    && export CONFIGURE_OPTS="${ROCRO_PHP_CONFIGURE_OPTS}" \
    && export CFLAGS="${ROCRO_PHP_CFLAGS}" \
    && echo "${PREINSTALLED_VERSIONS}" | while read version;do \
        if [ ! -e "${PHPENV_ROOT}/versions/${version}" ];then \
            phpenv install $version \
            && phpenv global $version \
            && php --ini | grep 'Loaded Configuration File' | awk -F':' '{ print $2 }' | xargs -i /bin/sh -c 'echo "[Date]\ndate.timezone = UTC" >> {}' \
            && [ $(php --ini 2>&1 >/dev/null | wc -l) = "0" ] || exit 1 \
        ; fi \
    ; done \
    && phpenv global system

WORKDIR /usr/local/src
ENV OPENSSL_102U_SHA256=ecd0c6ffb493dd06707d38b14bb4d8c2288bb7033735606569d8f90f89669d16
RUN wget -O openssl-1.0.2u.tar.gz https://github.com/openssl/openssl/releases/download/OpenSSL_1_0_2u/openssl-1.0.2u.tar.gz \
    && echo "${OPENSSL_102U_SHA256}  openssl-1.0.2u.tar.gz" | sha256sum -c - \
    && tar -xzf openssl-1.0.2u.tar.gz \
    && (cd openssl-1.0.2u && ./config --prefix=/opt/openssl-1.0.2 --openssldir=/opt/openssl-1.0.2 && make clean && make -j1 && make install) \
    && rm -rf openssl-1.0.2u openssl-1.0.2u.tar.gz

ENV PATH="/opt/openssl-1.0.2/bin:${PATH}"
ENV OPENSSL_CONF="/opt/openssl-1.0.2/openssl.cnf"

WORKDIR /
