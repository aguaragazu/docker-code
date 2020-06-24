FROM ubuntu:18.04

LABEL maintainer="Jose Carlos Gallo <josecgallo@jjsoft.com.ar>"

ENV DEBIAN_FRONTEND noninteractive
ENV MYSQL_ALLOW_EMPTY_PASSWORD=yes
ENV DOMAIN=SSL_DOMAIN

RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    openssl \
    net-tools \
    locales \
    sudo \
    git \
    jq \
    nano \
    curl \
    wget \ 
    gnupg \
    tzdata \
    ca-certificates \
    zip \
    unzip -y \
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
    


RUN \
    echo "**** Install zimfw exa ****" && \
    pt-get update && \
    apt-get install -y zsh bash-completion fzf && \
    curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

RUN curl https://sh.rustup.rs -sSf | sh \
    && wget -c https://github.com/ogham/exa/releases/download/v0.9.0/exa-linux-x86_64-0.9.0.zip
RUN unzip exa-linux-x86_64-0.9.0.zip \
    && mv exa-linux-x86_64 /usr/local/bin/exa


# Add add-apt-repository command
RUN apt-get update && \
    apt-get install -y software-properties-common

ENV LANGUAGE=es_AR:es_ES:es
RUN echo America/Argentina/Buenos_Aires > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN \
    echo "**** Install php common extension ****" && \
    LC_ALL=es_AR.UTF-8 add-apt-repository ppa:nginx/stable && \
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
        php7.3-zip

RUN \
    echo "**** install composer ****" && \
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer


COPY conf/my.cnf /etc/mysql/my.cnf
COPY conf/default.conf /etc/nginx/sites-enabled/default.conf
COPY conf/php.ini /etc/php/7.3/fpm/php.ini
COPY conf/laravel.ini /etc/php/7.3/fpm/conf.d/laravel.ini
COPY docker-run.sh /docker-run.sh

VOLUME ["/var/lib/mysql", "/var/www/html", "/etc/nginx/ssl"]

# Install Code-Server (Visual Studio Code)
RUN \
    echo "**** install code-server ****" && \
    curl -fsSL https://code-server.dev/install.sh | sh

RUN \
    echo "**** clean up ****" && \
    apt-get purge --auto-remove -y \
        build-essential \
        libx11-dev \
        libxkbfile-dev \
        libsecret-1-dev \
        pkg-config && \
    apt-get clean && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*

USER coder

EXPOSE 8080
EXPOSE 4200
EXPOSE 80 443

CMD ["/bin/bash", "docker-run.sh"]

ENTRYPOINT ["code-server"]
