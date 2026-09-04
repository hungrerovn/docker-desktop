#!/bin/bash
set -e

SSH_USER=${SSH_USER:-ubuntu}
SSH_PORT=${SSH_PORT:-22}
RDP_PORT=${RDP_PORT:-3389}
RDP_PASSWORD=${RDP_PASSWORD:-ubuntu}

if ! id "$SSH_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$SSH_USER"
    usermod -aG sudo "$SSH_USER"
fi

echo "$SSH_USER:$RDP_PASSWORD" | chpasswd
passwd -l root >/dev/null 2>&1 || true

echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$SSH_USER
chmod 440 /etc/sudoers.d/$SSH_USER

cat > /home/$SSH_USER/.xsession << 'EOF'
#!/bin/bash
rm -f "$HOME/.ICEauthority" "$HOME/.Xauthority"
exec dbus-run-session -- startxfce4
EOF
chmod +x /home/$SSH_USER/.xsession
chown $SSH_USER:$SSH_USER /home/$SSH_USER/.xsession

mkdir -p /run/user/1000
chown -R $SSH_USER:$SSH_USER /run/user/1000
chmod 700 /run/user/1000

if [ -n "$PUBLIC_KEY" ]; then
    mkdir -p /home/$SSH_USER/.ssh
    echo "$PUBLIC_KEY" > /home/$SSH_USER/.ssh/authorized_keys
    chown -R $SSH_USER:$SSH_USER /home/$SSH_USER/.ssh
    chmod 700 /home/$SSH_USER/.ssh
    chmod 600 /home/$SSH_USER/.ssh/authorized_keys
fi

sed -i "s/^#\?Port .*/Port $SSH_PORT/" /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sed -i 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' /etc/ssh/sshd_config

sed -i "s/port=3389/port=$RDP_PORT/g" /etc/xrdp/xrdp.ini
rm -f /var/run/xrdp/xrdp.pid /var/run/xrdp/xrdp-sesman.pid

ssh-keygen -A
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
