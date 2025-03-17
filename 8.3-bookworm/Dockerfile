FROM php:8.3.13-cli-bookworm

# Preset locale to en_US.UTF-8
# https://docs.docker.com/samples/library/debian/#locales
RUN apt-get update && apt-get install -y locales && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    wget curl git git-lfs subversion \
    build-essential autoconf dpkg-dev file g++ gcc libc-dev make pkg-config libtool \
    bison re2c libxml2-dev libsqlite3-dev libssl-dev libcurl4-openssl-dev libonig-dev \
    zlib1g-dev libbz2-dev libpng-dev libjpeg-dev libreadline-dev libtidy-dev \
    libxslt-dev libzip-dev apt-transport-https lsb-release ca-certificates \
   && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install bz2 xml

# Installing Composer.
# Refer to https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
# NOTE: Do not set COMPOSER_ALLOW_SUPERUSER=1 as Composer should be used
# only by non-root users in plugins.
ENV PATH="/composer/vendor/bin:$PATH"
ENV COMPOSER_HOME=/composer
ENV ROCRO_COMPOSER_VERSION=2.1.14
RUN EXPECTED_SIGNATURE="$(curl -q https://composer.github.io/installer.sig)" \
    && curl -sfLo /tmp/installer.php https://getcomposer.org/installer \
    && ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', '/tmp/installer.php');")" \
    && if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then echo 'ERROR: Invalid installer signature' && rm /tmp/installer.php && exit 1; fi \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${ROCRO_COMPOSER_VERSION} \
    && rm /tmp/installer.php \
    && composer --ansi --version --no-interaction

# Install phpenv
ENV PHPENV_ROOT=/opt/phpenv
ENV PATH="${PHPENV_ROOT}/shims:${PHPENV_ROOT}/bin:${PATH}"
ENV ROCRO_PHP_CFLAGS="-lssl -lcrypto"
RUN ROCRO_PHPENV_VERSION=cb3f33f9f9ff257c95b24ce9786b23a91e51cd4d \
    && PHP_BUILD_VERSION=c30036b3757308abb46360e920cb8849b30211db \
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

ENV ROCRO_PHP_CONFIGURE_OPTS="--disable-fpm --disable-cgi"
ENV PHP_AUTOCONF=/usr/bin/autoconf

# Install all latest versions excludes older than one year since EOL.
# https://www.php.net/supported-versions.php
ENV PREINSTALLED_VERSIONS="\
8.0.30\n\
8.1.30\n\
8.2.25"
# 8.3.13 system installed

RUN phpenv global system \
    && system_php_ver=$(php -v | head -1 | sed -e "s/^PHP \([0-9.]*\).*$/\1/") \
    && version_bin_dir="${PHPENV_ROOT}/versions/${system_php_ver}/bin" \
    && mkdir -p "${version_bin_dir}" \
    && cp "$(phpenv which php)" "${version_bin_dir}" \
    && cp "$(phpenv which php-config)" "${version_bin_dir}" \
    && cp "$(phpenv which phar)" "${version_bin_dir}" \
    && cp "$(phpenv which phar.phar)" "${version_bin_dir}" \
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
RUN wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz \
    && tar -xzf openssl-1.0.2u.tar.gz \
    && rm openssl-1.0.2u.tar.gz

WORKDIR /usr/local/src/openssl-1.0.2u
RUN ./config --prefix=/opt/openssl-1.0.2 --openssldir=/opt/openssl-1.0.2 \
    && make -j$(nproc) \
    && make install

ENV PATH="/opt/openssl-1.0.2/bin:${PATH}"
ENV OPENSSL_CONF="/opt/openssl-1.0.2/openssl.cnf"

WORKDIR /
