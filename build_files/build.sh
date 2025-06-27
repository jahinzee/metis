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
echo "ID_LIKE=\"${IMAGE_LIKE}\"" >> /usr/lib/os-release


# Fix issues caused by ID no longer being fedora
sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg

# Switch to generic logos, because why not
dnf swap fedora-logos generic-logos -y

## ----------------------------------------------------------------------------
##    Packages
## ----------------------------------------------------------------------------

## === IN: KDE Utilities

dnf5 install -y \
  kclock \
  kcolorchooser \
  yakuake \
  kolourpaint \
  haruna \
  elisa \
  gwenview \
  kalk \
  krdc \
  okular \

## === IN: Coolutils

# Like `coreutils`, but cooler!

# * fish
#   you'll have to change the login shell from `bash` yourself
dnf5 install -y \
  fish

# * Basic tools
dnf5 install -y \
  helix \
  neovim \
  bat \
  btop \
  zoxide \
  ripgrep \
  fd \
  topgrade

# * pipx
#   manage ""Python"" packages
dnf5 install -y \
  pipx

# * eza
#   better `ls` (COPR)
#   TODO: drop the copr repo and install from main repos
#         when F42 has it back in stock.
dnf5 -y copr enable \
  dturner/eza 
dnf5 install -y \
  eza
dnf5 -y copr disable \
  dturner/eza

# * topgrade
#   system update utility (COPR)
dnf5 -y copr enable \
  lilay/topgrade
dnf5 install -y \
  topgrade
dnf5 -y copr disable \
  lilay/topgrade

## == IN: Virtualisataion

dnf5 install -y \
  @virtualization

## == IN: ..put Methods

# * jp
#   Japanese/日本語
dnf5 install -y \
  fcitx5-mozc

# * bn
#   Bengali/বাংলা (COPR)
dnf5 -y copr enable \
  badshah/openbangla-keyboard
dnf5 install -y \
  fcitx-openbangla
dnf5 -y copr disable \
  badshah/openbangla-keyboard 

## == IN: Miscellaneous

# * Thunderbird
#   I find this to be more reliable than the Flatpak version :\
dnf5 install -y \
  thunderbird

# * Homebrew support packages
#   Since Homebrew is a user-level tool, integrating it on the system
#   layer doesn't make a lot of sense, but installing its dependencies
#   is fine.
dnf5 install -y \
  @development-tools \
  procps-ng \
  curl \
  file