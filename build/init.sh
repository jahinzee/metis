#!/bin/bash
# shellcheck disable=SC1091
set -ouex pipefail

. /ctx/common.sh 
. /ctx/branding.sh
. /ctx/applications.sh

clean-all
ostree container commit