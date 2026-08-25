FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    SSH_USER=ubuntu \
    SSH_PORT=22 \
    RDP_PORT=3389 \
    RDP_PASSWORD=ubuntu \
    PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMWzSUJP9M/CdbyFJrvmcrVe83+4givFPry52NXl8Jxb Hrv Clan"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        supervisor \
        rsyslog \
        cron \
        htop \
        sudo \
        curl \
        tini \
        wget \
        net-tools \
        iputils-ping \
        ca-certificates \
        openssl \
        git \
        vim \
        unzip \
        zip \
        xfce4 \
        xfce4-goodies \
        xrdp \
        dbus-x11 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/sshd /var/run/xrdp \
    && adduser xrdp ssl-cert

COPY entrypoint.sh /usr/local/bin/init.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisor.conf
RUN chmod +x /usr/local/bin/init.sh

EXPOSE 22 3389

ENTRYPOINT ["tini", "--", "/usr/local/bin/init.sh"]