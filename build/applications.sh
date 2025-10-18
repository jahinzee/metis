#!/bin/bash
# shellcheck disable=SC1091
set -ouex pipefail
. /ctx/common.sh

#  ··· Base Applications
#      + install base system applications
#

# ››› Desktop applications
#
install elisa \
        gwenview \
        haruna \
        kalk \
        kclock \
        kcm_systemd \
        kcolorchooser \
        kolourpaint \
        krdc \
        ksystemlog \
        merkuro \
        okular \
        plasma-browser-integration \
        yakuake 

# ››› Command-line and core applications
#
install bat \
        btop \
        distrobox \
        fastfetch \
        fd \
        fish \
        helix \
        pipx \
        podman-docker \
        podman-compose \
        qalculate \
        ripgrep \
        vim \
        xlsclients \
        zoxide

install-from-copr atim/starship \
                  starship
#  (i) `eza` is not available in the stock Fedora repos, so we're installing from a COPR.
#       See: <https://github.com/eza-community/eza/blob/main/INSTALL.md#fedora>
install-from-copr dturner/eza \
                  eza
install-from-copr lilay/topgrade \
                  topgrade

# ››› Virtualisation (libvirt/QEMU/KVM)
#
install @virtualization

# ››› IMEs (jp/bn)
#
install fcitx5 \
        fcitx5-mozc \
        kcm-fcitx5
install-from-copr badshah/openbangla-keyboard \
                  fcitx-openbangla

# ››› Homebrew (support packages)
#
#   (i)  Since Homebrew is a user-level tool, integrating it on the system layer doesn't make a lot
#        of sense, but installing the dependencies is fine.
install @development-tools \
        procps-ng \
        curl \
        file

# ››› Syncthing + SyncthingTray (Plasmoid/KIO/CLI)
#
install syncthing
install-from-obs-repo home:mkittler \
                      syncthingplasmoid-qt6 \
                      syncthingfileitemaction-qt6 \
                      syncthingctl-qt6

# ››› Printing (brlaser)
#
install printer-driver-brlaser

# ››› Zen Browser
#   (i)  The zen-browser package needs to throw some stuff in /opt, which doesn't exist, so we'll
#        manually (rem)make the /opt directory (replacing the existing one which is just a symlink
#        to /var/opt)
rm /opt && mkdir /opt
install-from-copr sneexy/zen-browser \
                  zen-browser