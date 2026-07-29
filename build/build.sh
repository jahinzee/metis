#!/bin/bash
set -ouex pipefail

echo "--**## Building Metis... ##**--"

# --------------------------------------------------------

# Install: Basic tools and apps
#
dnf5 copr enable -y imput/helium
dnf5 copr enable -y badshah/openbangla-keyboard
dnf5 copr enable -y scottames/ghostty
rm /opt && mkdir /opt
dnf5 install -y \
    @development-tools \
    @virtualization \
    distrobox \
    fcitx-openbangla \
    fcitx5-mozc \
    fcitx5 \
    ghostty \
    helium-bin \
    podman-compose \
    podman-docker \
    podman \
    syncthing \
    yakuake
dnf5 copr disable -y imput/helium
dnf5 copr disable -y badshah/openbangla-keyboard
dnf5 copr disable -y scottames/ghostty 

# Install: Nix
#
dnf5 install -y nix nix-daemon
systemctl enable nix-daemon.service

# Setup: /var/nix mount (for atomic compatibility)
#
cat << EOF > /usr/lib/systemd/system/nix.mount
[Unit]
Description=Bind mount /var/nix to /nix

[Mount]
What=/var/nix
Where=/nix
Type=none
Options=bind

[Install]
WantedBy=local-fs.target
EOF
systemctl enable nix.mount

# Setup: Tailscale
dnf5 install -y tailscale
systemctl enable tailscaled.service

# Install: Drivers/Elan Fingerprint
#
dnf5 copr enable -y skaldebane/libfprint-elanmoc2
dnf5 swap -y libfprint libfprint-elanmoc2
dnf5 copr disable -y skaldebane/libfprint-elanmoc2

# Install: Drivers/Brother printers
#
dnf5 install -y printer-driver-brlaser

# --------------------------------------------------------

echo "--**## Build complete! ##**--"