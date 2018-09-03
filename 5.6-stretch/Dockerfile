FROM debian:stretch

RUN PHP_VERSION="5.6.37-1+0~20180725093819.2+stretch~1.gbp606419" \
    && apt-get update \
    && apt-get install -y \
        apt-transport-https="1.4.8" \
        ca-certificates="20161130+nmu1+deb9u1" \
        curl="7.52.1-5+deb9u6" \
        gnupg="2.1.18-8~deb9u2" \
    && curl -s https://packages.sury.org/php/apt.gpg | apt-key add - \
    && echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install -y \
        php5.6="${PHP_VERSION}" \
        php5.6-bz2="${PHP_VERSION}" \
        php5.6-xml="${PHP_VERSION}" \
    && apt-get remove -y \
        apt-transport-https="1.4.8" \
        ca-certificates="20161130+nmu1+deb9u1" \
        curl="7.52.1-5+deb9u6" \
        gnupg="2.1.18-8~deb9u2" \
    && apt-get clean

ENV CONCHOID_DOCKER_PHPENV_HOME /conchoid/docker-phpenv
COPY . ${CONCHOID_DOCKER_PHPENV_HOME}
RUN ${CONCHOID_DOCKER_PHPENV_HOME}/install-builddeps.sh

RUN curl -SL http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz | tar -xz -C ~/ \
	&& rm /usr/bin/iconv \
	&& mv ~/libiconv-1.15 ~/libiconv \
	&& ~/libiconv/configure --prefix=/usr/bin \
	&& make && make install

ENV LD_PRELOAD /usr/bin/lib/preloadable_libiconv.so

# Installing Composer.
# Refer to https://github.com/composer/docker/blob/master/1.4/Dockerfile
#
# NOTE: Do not set COMPOSER_ALLOW_SUPERUSER=1 as Composer should be used
# only by non-root users in plugins.
ENV PATH "/composer/vendor/bin:$PATH"
ENV COMPOSER_HOME /composer
ENV COMPOSER_VERSION 1.4.2

RUN curl -s -f -L -o /tmp/installer.php https://raw.githubusercontent.com/composer/getcomposer.org/da290238de6d63faace0343efbdd5aa9354332c5/web/installer \
    && php -r " \
        \$signature = '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410'; \
        \$hash = hash('SHA384', file_get_contents('/tmp/installer.php')); \
        if (!hash_equals(\$signature, \$hash)) { \
            unlink('/tmp/installer.php'); \
            echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
            exit(1); \
        }" \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
    && rm /tmp/installer.php \
    && composer --ansi --version --no-interaction

# Install phpenv
ENV PHPENV_ROOT /opt/phpenv
ENV PATH "${PHPENV_ROOT}/shims:${PHPENV_ROOT}/bin:${PATH}"
ENV PHP_CFLAGS "-lssl -lcrypto"

RUN set -x \
    && PHPENV_VERSION=085261129f7231fcd3b34401ad4af84b21df62eb \
    && PHP_BUILD_VERSION=41948c122834ff51d13f240a2d53ec3e032fab98 \
    && git clone https://github.com/madumlao/phpenv.git ${PHPENV_ROOT} \
    && (cd ${PHPENV_ROOT} && git checkout ${PHPENV_VERSION}) \
    && git clone https://github.com/php-build/php-build ${PHPENV_ROOT}/plugins/php-build \
    && (cd ${PHPENV_ROOT}/plugins/php-build && git checkout ${PHP_BUILD_VERSION}) \
    && phpenv rehash \
    && rm -r ${PHPENV_ROOT}/.git ${PHPENV_ROOT}/plugins/php-build/.git \
    # Because the our phpenv container doesn't install apache2-dev package (to avoid conflict between openssl and libressl), put the
    # dummy "apxs" module and avoid the "phpenv global" command returning exit code 1. See below for where "apxs" in "phpenv global":
    # https://github.com/madumlao/phpenv/blob/085261129f7231fcd3b34401ad4af84b21df62eb/libexec/phpenv-global#L45
    && touch ${PHPENV_ROOT}/bin/apxs && chmod +x ${PHPENV_ROOT}/bin/apxs \
    && cp ${CONCHOID_DOCKER_PHPENV_HOME}/patches/xp_ssl.c.2.patch ${PHPENV_ROOT}/plugins/php-build/share/php-build/patches/ \
    && sed -ie '0,/configure_option/a patch_file\ "xp_ssl.c.2.patch"' ${PHPENV_ROOT}/plugins/php-build/share/php-build/definitions/5.3.29 \
    && sed -ie '0,/configure_option/a patch_file\ "xp_ssl.c.2.patch"' ${PHPENV_ROOT}/plugins/php-build/share/php-build/definitions/5.4.45

