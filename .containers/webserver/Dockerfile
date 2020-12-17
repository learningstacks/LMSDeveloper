ARG PHP_VERSION=7.2

FROM thecodingmachine/php:${PHP_VERSION}-v3-apache
USER docker
RUN sudo apt-get update \
    && sudo apt-get install -y locales locales-all python2.7 wget \
    && sudo update-locale en_AU.UTF8

# Install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

# Install Powershell
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
    sudo dpkg -i packages-microsoft-prod.deb && \
    sudo apt-get update && \
    # sudo add-apt-repository universe && \
    sudo apt-get install -y powershell && \
    pwsh -command "install-module powershell-yaml -force"

# Setup app directories
# RUN sudo mkdir -p /lms/app/moodle /lms/moodledata /lms/moodledata_t /lms/moodledata_b && \
#     sudo chown -R docker:docker /lms

RUN sudo mkdir -p /appdata/moodledata && \
    sudo mkdir -p /appdata/phpunitdata && \
    sudo mkdir -p /appdata/behatdata && \
    # sudo mkdir -p /appdata/behatfaildumps && \
    # sudo mkdir -p /appdata/phpunit_logs && \
    # sudo mkdir -p /appdata/behat_logs && \
    sudo chown -R docker:docker /appdata

ENV APACHE_DOCUMENT_ROOT "/app/lms/moodle"
ENV PHP_EXTENSION_GD 1
ENV PHP_EXTENSION_INTL 1
ENV PHP_EXTENSION_XMLRPC 1
ENV PHP_EXTENSION_XDEBUG 1
ENV COMPOSER_ALLOW_XDEBUG 1
