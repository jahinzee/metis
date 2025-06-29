#!/bin/bash

set -ouex pipefail

## ----------------------------------------------------------------------------
##    Branding
## ----------------------------------------------------------------------------

# This section adapted from:
#    https://github.com/winblues/blue95/blob/main/files/scripts/00-image-info.sh
# Authors:
#    jahinzee, ledif
# Changes: added metis branding, custom hostname, and generic logos

IMAGE_VENDOR="jahinzee"
IMAGE_NAME="metis"
IMAGE_PRETTY_NAME="Metis"
IMAGE_LIKE="fedora"
HOME_URL="https://github.com/jahinzee/metis"
DOCUMENTATION_URL="https://github.com/jahinzee/metis/blob/main/README.md"
SUPPORT_URL="https://github.com/jahinzee/metis/issues"
BUG_SUPPORT_URL="https://github.com/jahinzee/metis/issues"

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"

FEDORA_MAJOR_VERSION=$(awk -F= '/VERSION_ID/ {print $2}' /etc/os-release)
BASE_IMAGE_NAME="Kinoite $FEDORA_MAJOR_VERSION"
BASE_IMAGE="ghcr.io/ublue-os/kinoite-main"

DEFAULT_HOSTNAME="localhost"

cat >$IMAGE_INFO <<EOF
{
  "image-name": "$IMAGE_NAME",
  "image-vendor": "$IMAGE_VENDOR",
  "image-ref": "$IMAGE_REF",
  "image-tag":"latest",
  "base-image-name": "$BASE_IMAGE",
  "fedora-version": "$FEDORA_MAJOR_VERSION"
}
EOF

# OS Release File
sed -i "s/^VARIANT_ID=.*/VARIANT_ID=$IMAGE_NAME/" /usr/lib/os-release
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"${IMAGE_PRETTY_NAME} (FROM Fedora ${BASE_IMAGE_NAME^})\"/" /usr/lib/os-release
sed -i "s/^NAME=.*/NAME=\"$IMAGE_PRETTY_NAME\"/" /usr/lib/os-release
sed -i "s/^ID=.*/ID=\"$IMAGE_NAME\"/" /usr/lib/os-release
sed -i "s|^HOME_URL=.*|HOME_URL=\"$HOME_URL\"|" /usr/lib/os-release
sed -i "s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"$DOCUMENTATION_URL\"|" /usr/lib/os-release
sed -i "s|^SUPPORT_URL=.*|SUPPORT_URL=\"$SUPPORT_URL\"|" /usr/lib/os-release
sed -i "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"$BUG_SUPPORT_URL\"|" /usr/lib/os-release
sed -i "s|^CPE_NAME=\"cpe:/o:fedoraproject:fedora|CPE_NAME=\"cpe:/o:winblues:${IMAGE_PRETTY_NAME,}|" /usr/lib/os-release
sed -i "s/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME=\"${DEFAULT_HOSTNAME,}\"/" /usr/lib/os-release
sed -i "s/^ID=fedora/ID=${IMAGE_PRETTY_NAME,}\nID_LIKE=\"${IMAGE_LIKE}\"/" /usr/lib/os-release
sed -i "/^REDHAT_BUGZILLA_PRODUCT=/d; /^REDHAT_BUGZILLA_PRODUCT_VERSION=/d; /^REDHAT_SUPPORT_PRODUCT=/d; /^REDHAT_SUPPORT_PRODUCT_VERSION=/d" /usr/lib/os-release

# Add ID_LIKE tag to allow external apps to properly identify that this
# is based on Fedora Atomic
echo "ID_LIKE=\"${IMAGE_LIKE}\"" >> /usr/lib/os-release

# Fix issues caused by ID no longer being fedora
sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg

# Switch to generic logos, because why not
dnf swap fedora-logos generic-logos -y

## ----------------------------------------------------------------------------
##    Packages
## ----------------------------------------------------------------------------

install() {
  echo "[install] $1"
  dnf5 install "$1" -y
}

install-from-copr() {
  echo "[install] (copr:$1) $2"
  dnf5 copr enable "$1" -y
  dnf5 install "$2" -y
  dnf5 copr disable "$1" -y
}

## === IN: KDE Utilities

# install kclock
# install kcolorchooser
# install yakuake
# install kclock
# install kcolorchooser
# install yakuake
# install kolourpaint
# install haruna
# install elisa
# install gwenview
# install kalk
# install krdc
# install okular

## === IN: Coolutils

# Like `coreutils`, but cooler!

# * fish
#   you'll have to change the login shell from `bash` yourself
install fish

# * Basic tools
install helix
install neovim
install bat
install btop
install zoxide
install ripgrep
install fd
install fastfetch

# * pipx
#   manage ""Python"" packages
install pipx

# * eza
#   better `ls` (COPR)
#   TODO: drop the copr repo and install from main repos
#         when F42 has it back in stock.
install-from-copr dturner/eza eza

# * topgrade
#   system update utility (COPR)
install-from-copr lilay/topgrade topgrade

## == IN: Virtualisation

install @virtualization

## == IN: ..put Methods

# * jp
#   Japanese/日本語
install fcitx5-mozc

# * bn
#   Bengali/বাংলা (COPR)
install-from-copr badshah/openbangla-keyboard fcitx-openbangla

## == IN: Miscellaneous

# * Thunderbird
#   I find this to be more reliable than the Flatpak version :\
install thunderbird

# * Homebrew support packages
#   Since Homebrew is a user-level tool, integrating it on the system
#   layer doesn't make a lot of sense, but installing its dependencies
#   is fine.
install @development-tools
install procps-ng
install curl
install file

# * Syncthing
install syncthing