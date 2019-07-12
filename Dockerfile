FROM ubuntu:18.04

LABEL maintainer="Jose Carlos Gallo <josecgallo@jjsoft.com.ar>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    openssl \
    net-tools \
    locales \
    sudo \
    vim \
    git \
    curl \
    wget \ 
    gnupg \
    tzdata \
	mariadb-server \
	mariadb-client \
    ca-certificates \
    python3.7 \
    python3.7-dev \
    python3.7-venv \
    python3-venv && \
    adduser --disabled-password --ingroup sudo --gecos '' coder && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo "user ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user && \
    locale-gen es_AR.UTF-8 && \
    curl -kL https://bootstrap.pypa.io/get-pip.py | python3.7 && \
    chown -R coder:sudo /home/coder && \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y nodejs && \
    npm i -g npx yarn

# Add add-apt-repository command
RUN apt-get update && \
    apt-get install -y software-properties-common

ENV LANGUAGE=es_AR:es_ES:es
RUN echo America/Argentina/Buenos_Aires > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

# Add Repo ppa:nginx/stable
# Add Repo ppa:ondrej/php
# Install php common extension
# zip and unzip is essential component for composer to run 
RUN LC_ALL=es_AR.UTF-8 add-apt-repository ppa:nginx/stable && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y nginx \
        php7.3-fpm \
        php7.3-common \
        php7.3-mysql \
        php7.3-pdo \
        php7.3-xml \
        php7.3-xmlrpc \
        php7.3-curl \
        php7.3-gd \
        php7.3-imagick \
        php7.3-cli \
        php7.3-dev \
        php7.3-imap \
        php7.3-mbstring \
        php7.3-opcache \
        php7.3-soap \
        php7.3-imap \
        php7.3-zip \
        zip \
        unzip -y

# Install composer
# how can a PHP developer miss the Composer :)
RUN curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

COPY conf/default.conf /etc/nginx/sites-enabled/default.conf
COPY conf/php.ini /etc/php/7.3/fpm/php.ini

COPY conf/laravel.ini /etc/php/7.3/fpm/conf.d/laravel.ini

RUN /etc/init.d/php7.3-fpm restart

RUN mkdir /tmp/certgen
WORKDIR /tmp/certgen
RUN openssl genrsa -des3 -passout pass:x -out server.pass.key 2048 \
    && openssl rsa -passin pass:x -in server.pass.key -out server.key \
    && rm server.pass.key \
    && openssl req -new -key server.key -out server.csr -subj "/CN=jjsoftsistemas.com" \
    && openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt \
    && cp server.crt /etc/ssl/certs/ \
    && cp server.key /etc/ssl/private/ \
    && rm -rf /tmp/certgen

# Install Code-Server (Visual Studio Code)
ENV CDR_VER 1.1156-vsc1.33.1

WORKDIR /home/coder/project

ADD https://github.com/codercom/code-server/releases/download/${CDR_VER}/code-server${CDR_VER}-linux-x64.tar.gz /tmp
RUN tar zxvf /tmp/code-server${CDR_VER}-linux-x64.tar.gz -C /tmp \
    && mv /tmp/code-server${CDR_VER}-linux-x64/code-server /usr/local/bin/code-server \
    && rm -rf /tmp/code-server-*

USER coder
EXPOSE 8443 80 443

ENTRYPOINT ["code-server"]
