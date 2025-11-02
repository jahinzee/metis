#!/bin/bash
# shellcheck disable=SC1091
set -ouex pipefail

. /ctx/common.sh

#  ··· Base Applications
#      + install base system applications
#

# ››› Remove: ujust
#
remove ublue-os-just 

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
# INFO: `eza` is not available in the stock Fedora repos, so we're installing from a COPR.
#       See: <https://github.com/eza-community/eza/blob/main/INSTALL.md#fedora>
enable-coprs \
    atim/starship \
    dturner/eza \
    lilay/topgrade
install \
    bat \
    btop \
    distrobox \
    eza \
    fastfetch \
    fd \
    fish \
    fortune-mod \
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
# enable-coprs badshah/openbangla-keyboard
install \
    fcitx5 \
    fcitx5-mozc \
    kcm-fcitx5 \
    # fcitx-openbangla
# TEMPORARY: Using the F42 build of OpenBangla until packaging is ready for Fedora 43.
# DISABLE: Might be causing some issues with Plasma 6.5?
# install "https://download.copr.fedorainfracloud.org/results/badshah/openbangla-keyboard/fedora-42-x86_64/09018418-fcitx-openbangla/fcitx-openbangla_3.0.0-.rpm"

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

# ››› AppImageLauncher
# 
# NOTE: Must be manually bumped when necessary.
#       Current version:  v3.0.0-beta-3
#       Check URL:        https://github.com/TheAssassin/AppImageLauncher/releases
# DISABLED: Might be causing some issues with Plasma 6.5?
# install "https://github.com/TheAssassin/AppImageLauncher/releases/download/v3.0.0-beta-3/appimagelauncher_3.0.0-beta-2-gha287.96cb937_x86_64.rpm"

# ››› KDE-Rounded-Corners
#
# DISABLED: Might be causing some issues with Plasma 6.5?
# enable-coprs matinlotfali/KDE-Rounded-Corners
# install kwin-effect-roundcorners

# ››› Cleanup and finalisation
#
clean-all
commit-ostree
