FROM debian:stretch AS build-base
RUN apt-get update && apt-get install -y \
    bzip2 curl gcc m4 make tar \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

FROM build-base AS build-libiconv
RUN curl -SL http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz | tar -xz -C ~/ \
    && ~/libiconv-1.15/configure --prefix=/usr/bin \
    && make && make install

# bison 2.x is required for building php5.x
FROM build-base AS build-bison
RUN WORK_DIR="/tmp/bison/" \
    BISON_VERSION="2.6.4" \
    && mkdir -p ${WORK_DIR}/downloads ${WORK_DIR}/src \
    && curl -SL -o ${WORK_DIR}/downloads/bison-${BISON_VERSION}.tar.gz http://ftp.gnu.org/gnu/bison/bison-${BISON_VERSION}.tar.gz \
    && tar -zxf ${WORK_DIR}/downloads/bison-${BISON_VERSION}.tar.gz -C ${WORK_DIR}/src \
    && cd ${WORK_DIR}/src/bison-${BISON_VERSION}/ \
    && ./configure --prefix=/usr/local/lib/bison \
    && make && make install

FROM build-base
# Preset locale to en_US.UTF-8
# https://docs.docker.com/samples/library/debian/#locales
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    git \
    locales \
    subversion \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY --from=build-libiconv /usr/bin/lib/ /usr/bin/lib
ENV LD_PRELOAD /usr/bin/lib/preloadable_libiconv.so

COPY --from=build-bison /usr/local/lib/bison /usr/local/lib/bison
RUN ln -s /usr/local/lib/bison/bin/bison /usr/local/bin/bison

# buffio.h is deprecated but needed for building php prior to 7.2.
RUN curl -o /usr/include/buffio.h https://raw.githubusercontent.com/htacg/tidy-html5/5.6.0/include/buffio.h

# easy.h should be in <curl-dir>/include/curl/
RUN ln -s /usr/include/x86_64-linux-gnu/curl /usr/include

ENV ROCRO_CONCHOID_DOCKER_PHPENV_HOME /conchoid/docker-phpenv
COPY . ${ROCRO_CONCHOID_DOCKER_PHPENV_HOME}
RUN ${ROCRO_CONCHOID_DOCKER_PHPENV_HOME}/install-builddeps.sh

# Installing PHP 7.4
# https://packages.sury.xyz/php/README.txt
RUN DPKG_NAME="php7.4" \
    && curl -SL -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && sh -c 'echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list'\
    && apt-get update \
    && PHP_DPKG_VERSION=$(apt-cache show "${DPKG_NAME}" | grep -e "^Version: " | cut -d" " -f2) \
    && [ -n "$PHP_DPKG_VERSION" ] \
    && apt-get install -y \
        "${DPKG_NAME}=${PHP_DPKG_VERSION}" \
        "${DPKG_NAME}-bz2=${PHP_DPKG_VERSION}" \
        "${DPKG_NAME}-xml=${PHP_DPKG_VERSION}" \
        "${DPKG_NAME}-dev=${PHP_DPKG_VERSION}" \
   && rm -f /etc/apt/sources.list.d/php.list \
   && apt-get clean && rm -rf /var/lib/apt/lists/*

# Installing Composer.
# Refer to https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
# NOTE: Do not set COMPOSER_ALLOW_SUPERUSER=1 as Composer should be used
# only by non-root users in plugins.
ENV PATH "/composer/vendor/bin:$PATH"
ENV COMPOSER_HOME /composer
ENV ROCRO_COMPOSER_VERSION 1.9.2
RUN EXPECTED_SIGNATURE="$(curl -q https://composer.github.io/installer.sig)" \
    && curl -sfLo /tmp/installer.php https://getcomposer.org/installer \
    && ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', '/tmp/installer.php');")" \
    && if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then echo 'ERROR: Invalid installer signature' && rm /tmp/installer.php && exit 1; fi \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${ROCRO_COMPOSER_VERSION} \
    && rm /tmp/installer.php \
    && composer --ansi --version --no-interaction

# Install phpenv
ENV PHPENV_ROOT /opt/phpenv
ENV PATH "${PHPENV_ROOT}/shims:${PHPENV_ROOT}/bin:${PATH}"
ENV ROCRO_PHP_CFLAGS "-lssl -lcrypto"
RUN ROCRO_PHPENV_VERSION=9b7e4e1c0083c46be69f4c6d063f78c18654aad1 \
    && PHP_BUILD_VERSION=17495066aa12cd9f74ef7acfe41191386741c9aa \
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

ENV ROCRO_PHP_CONFIGURE_OPTS "--disable-fpm --disable-cgi"
ENV PHP_AUTOCONF /usr/bin/autoconf

# Install all latest versions excludes older than one year since EOL.
# https://www.php.net/supported-versions.php
ENV PREINSTALLED_VERSIONS "\
7.1.33\n\
7.2.34\n\
7.3.27\n\
7.4.16"

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