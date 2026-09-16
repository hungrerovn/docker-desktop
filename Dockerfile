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
        xauth \
        ca-certificates \
        openssl \
        vim \
        icewm \
        xfce4-terminal \
        tango-icon-theme \
        xrdp \
        xorgxrdp \
        xserver-xorg-core \
        dbus-x11 \
        thunar \
        thunar-volman \
        gvfs \
        gvfs-backends \
    && mkdir -p /var/run/sshd /var/run/xrdp \
    && adduser xrdp ssl-cert

COPY entrypoint.sh /usr/local/bin/init.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisor.conf
RUN chmod +x /usr/local/bin/init.sh
RUN install -d -m 0755 /etc/apt/keyrings \
    && wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null \
    && printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' > /etc/apt/preferences.d/mozilla \
    && apt-get update \
    && apt-get install -y --no-install-recommends firefox \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 22 3389

ENTRYPOINT ["tini", "--", "/usr/local/bin/init.sh"]
