#!/bin/bash

set -ouex pipefail

# ### Install packages

# # Packages can be installed from any enabled yum repo on the image.
# # RPMfusion repos are available by default in ublue main images
# # List of rpmfusion packages can be found here:
# # https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# # this installs a package from fedora repos
# dnf5 install -y tmux

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

# Fix issues caused by ID no longer being fedora
sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg

# Switch to generic logos, because why not
dnf swap fedora-logos generic-logos -y

## ----------------------------------------------------------------------------
##    Packages
## ----------------------------------------------------------------------------

## Multimedia

sudo dnf install -y \
	haruna \
	elisa
