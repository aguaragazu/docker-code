FROM ubuntu:18.04
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
	mariadb-server \
	mariadb-client \
    python3.7 \
    python3.7-dev \
    python3.7-venv \
    python3-venv && \
    adduser --disabled-password --ingroup sudo --gecos '' coder && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo "user ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user && \
    locale-gen en_US.UTF-8 && \
    curl -kL https://bootstrap.pypa.io/get-pip.py | python3.7 && \
    chown -R coder:sudo /home/coder && \
    curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y nodejs && \
    npm i -g npx yarn

# Add add-apt-repository command
RUN apt-get update && \
    apt-get install -y software-properties-common

# Add Repo ppa:ondrej/php
# Install php common extension
# zip and unzip is essential component for composer to run 
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y php7.3-fpm \
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


ENV LANG=en_US.UTF-8
ENV CDR_VER 1.1156-vsc1.33.1

WORKDIR /home/coder/project

ADD https://github.com/codercom/code-server/releases/download/${CDR_VER}/code-server${CDR_VER}-linux-x64.tar.gz /tmp
RUN tar zxvf /tmp/code-server${CDR_VER}-linux-x64.tar.gz -C /tmp \
    && mv /tmp/code-server${CDR_VER}-linux-x64/code-server /usr/local/bin/code-server \
    && rm -rf /tmp/code-server-*

USER coder
EXPOSE 8443

ENTRYPOINT ["code-server"]
