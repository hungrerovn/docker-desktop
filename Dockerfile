FROM alpine:latest

ENV SSH_USER=ubuntu \
     SSH_PORT=22 \
     RDP_PORT=3389 \
     RDP_PASSWORD=123 \
     PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMWzSUJP9M/CdbyFJrvmcrVe83+4givFPry52NXl8Jxb Hrv Clan"

RUN sed -i 's/#http/http/g' /etc/apk/repositories && \
    apk update && apk add --no-cache \
    vim \
    bash \
    sudo \
    curl \
    tini \
    wget \
    htop \
    xrdp \
    dbus \
    xauth \
    shadow \
    icewm \
    thunar \
    openssh \
    openssl \
    firefox \
    dbus-x11 \
    supervisor \
    xorgxrdp \
    xorg-server \
    xfce4-terminal \
    ca-certificates \
    faenza-icon-theme 

COPY entrypoint.sh /usr/local/bin/init.sh
COPY supervisord.conf /etc/supervisor/supervisord.conf
RUN chmod +x /usr/local/bin/init.sh
EXPOSE 22 3389

ENTRYPOINT ["tini", "--", "/usr/local/bin/init.sh"]
