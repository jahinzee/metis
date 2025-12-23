#!/bin/bash
# shellcheck disable=SC1091
set -ouex pipefail

. /ctx/common.sh

#  ··· Base Applications
#      + install base system applications
#

# ››› Remove: ujust and Firefox
#
remove ublue-os-just
remove firefox

# ››› Setup: Terra
#
enable-terra

# ››› Desktop applications
#
install \
    elisa \
    gwenview \
    haruna \
    kalk \
    kamoso \
    kclock \
    kcm_systemd \
    kcolorchooser \
    kolourpaint \
    krdc \
    ksystemlog \
    lm_sensors \
    merkuro \
    okular \
    plasma-browser-integration \
    yakuake 

# ››› Command-line and core applications
#
install \
    bat \
    btop \
    distrobox \
    eza \
    fastfetch \
    fd \
    fish \
    fortune-mod \
    gh-act \
    helix \
    hyperfine \
    pipx \
    podman-docker \
    podman-compose \
    qalculate \
    ripgrep \
    starship \
    topgrade \
    vim \
    xlsclients \
    zoxide

# ››› Virtualisation (libvirt/QEMU/KVM)
#
install @virtualization

# ››› IMEs (jp/bn)
#
enable-coprs badshah/openbangla-keyboard
install \
    fcitx5 \
    fcitx5-mozc \
    kcm-fcitx5 \
    fcitx-openbangla

# ››› Homebrew (support packages)
#
# INFO: Since Homebrew is a user-level tool, integrating it on the system layer doesn't make a lot
#       of sense, but installing the dependencies is fine.
install \
    @development-tools \
    procps-ng \
    curl \
    file

# ››› Syncthing and SyncthingTray (Plasmoid/KIO/CLI)
#
enable-obs-repos home:mkittler
install \
    syncthing \
    syncthingplasmoid-qt6 \
    syncthingfileitemaction-qt6 \
    syncthingctl-qt6

# ››› Printing (brlaser)
#
install printer-driver-brlaser

# ››› Zen Browser
#
# FIX: The zen-browser package needs to throw some stuff in /opt, which doesn't exist, so we'll
#      manually (rem)make the /opt directory (replacing the existing one which is just a symlink
#      to /var/opt)
rm /opt && mkdir /opt
enable-coprs sneexy/zen-browser
install zen-browser

# ››› Helium Browser
install helium-browser-bin

# ››› Tailscale
#
enable-other-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo
install tailscale