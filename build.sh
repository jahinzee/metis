#!/bin/bash
set -ouex pipefail

dnf5 copr enable -y imput/helium
rm /opt && mkdir /opt
dnf5 install -y \
    distrobox \
    helium-bin \
    podman \
    nix \
    nix-daemon
dnf5 remove -y firefox
dnf5 copr disable -y imput/helium

cat << EOF2 > /usr/lib/systemd/system/nix.mount
[Unit]
Description=Bind mount /var/nix to /nix

[Mount]
What=/var/nix
Where=/nix
Type=none
Options=bind

[Install]
WantedBy=local-fs.target
EOF2

systemctl enable nix.mount
systemctl enable nix-daemon.service