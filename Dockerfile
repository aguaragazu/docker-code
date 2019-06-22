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
    iputils-ping \
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
