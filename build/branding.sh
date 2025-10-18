#!/bin/bash
# shellcheck disable=SC1091
set -ouex pipefail
. /ctx/common.sh 

#  ··· Branding
#      + apply custom Metis branding and generic logos.
#
#      Based on:   https://github.com/winblues/blue95/blob/main/files/scripts/00-image-info.sh
#      Authors:    jahinzee, ledif
#      Changes:
#          + added metis/Metis branding
#          + custom hostname
#          + added generic logos
#          + added ID_LIKE fixes
#          + refactored into bash functions

IMAGE_VENDOR="jahinzee"
IMAGE_NAME="metis"
IMAGE_PRETTY_NAME="Metis"
IMAGE_LIKE="fedora"
HOME_URL="https://github.com/$IMAGE_VENDOR/$IMAGE_NAME"
DOCUMENTATION_URL="$HOME_URL/blob/main/README.md"
SUPPORT_URL="$HOME_URL/issues"

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"

FEDORA_MAJOR_VERSION=$(awk -F= '/VERSION_ID/ {print $2}' /etc/os-release)
BASE_IMAGE_NAME="Kinoite $FEDORA_MAJOR_VERSION"
BASE_IMAGE="ghcr.io/ublue-os/kinoite-main"

DEFAULT_HOSTNAME="localhost"

# ››› Customise image-info.json file.
#
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

# ››› Customise os-release file.
#
set-os-release() { for arg in "$@"; do sed -i "$arg" /usr/lib/os-release; done }
set-os-release \
    "s/^VARIANT_ID=.*/VARIANT_ID=$IMAGE_NAME/" \
    "s/^PRETTY_NAME=.*/PRETTY_NAME=\"${IMAGE_PRETTY_NAME} (FROM Fedora ${BASE_IMAGE_NAME^})\"/" \
    "s/^NAME=.*/NAME=\"$IMAGE_PRETTY_NAME\"/" \
    "s/^ID=.*/ID=\"$IMAGE_NAME\"/" \
    "s|^HOME_URL=.*|HOME_URL=\"$HOME_URL\"|" \
    "s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"$DOCUMENTATION_URL\"|" \
    "s|^SUPPORT_URL=.*|SUPPORT_URL=\"$SUPPORT_URL\"|" \
    "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"$SUPPORT_URL\"|" \
    "s|^CPE_NAME=\"cpe:/o:fedoraproject:fedora|CPE_NAME=\"cpe:/o:winblues:${IMAGE_PRETTY_NAME,}|" \
    "s/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME=\"${DEFAULT_HOSTNAME,}\"/" \
    "s/^ID=fedora/ID=${IMAGE_PRETTY_NAME,}\nID_LIKE=\"${IMAGE_LIKE}\"/" \

# Add ID_LIKE tag to allow external apps to properly identify that this is based on Fedora Kinoite
echo "ID_LIKE=\"${IMAGE_LIKE}\"" >> /usr/lib/os-release

# Fix issues caused by ID no longer being fedora
sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg

# ››› Switch to generic-logos.
#
dnf swap fedora-logos generic-logos -y