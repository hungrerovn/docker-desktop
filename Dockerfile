FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    SSH_USER=ubuntu \
    SSH_PORT=22 \
    RDP_PORT=3389 \
    RDP_PASSWORD=123 \
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
        ca-certificates \
        openssl \
        vim \
        xfce4 \
        xfce4-terminal \
        tango-icon-theme \
        gnome-icon-theme \
        xrdp \
        xorgxrdp \
        xserver-xorg-core \
        dbus-x11 \
    && mkdir -p /var/run/sshd /var/run/xrdp \
    && adduser xrdp ssl-cert

COPY entrypoint.sh /usr/local/bin/init.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisor.conf
RUN chmod +x /usr/local/bin/init.sh
RUN wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends /tmp/google-chrome.deb \
    && rm -f /tmp/google-chrome.deb \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 22 3389

ENTRYPOINT ["tini", "--", "/usr/local/bin/init.sh"]
