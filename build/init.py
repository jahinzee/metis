#!/bin/env python
from pathlib import Path

from unibuild import Setup


def main():
    setup = Setup(verbose=True)

    setup.core.vprint("# --**## Metis ##**-- ")
    setup.core.vprint(f"# INFO: Verbose mode is {'on' if setup.verbose else 'off'}.")
    setup.core.vprint(f"# INFO: Image based on: Fedora {setup.identity.fedora_release()}.")

    # BRANDING: set basic branding and swap logos.
    #
    setup.identity.set_basic_identity_info(
        use_github_conventions=True,
        image_vendor="jahinzee",
        image_name="metis",
        image_pretty_name="Metis",
        base_image_name="Kinoite",
        base_image_url="ghcr.io/ublue-os/kinoite-main")  # fmt: skip
    setup.pkgs.swap("fedora-logos", "generic-logos")

    # PATCH: Fix /opt for Helium browser
    #
    Path("/opt").unlink()
    Path("/opt").mkdir()
    setup.core.assert_condition(Path("/opt").is_dir(), "/opt patch failed.")
    setup.core.vprint("# /opt patch successful.")

    # INSTALL: Base packages
    #
    setup.repos.enable_copr("badshah", "openbangla-keyboard")
    setup.repos.enable_copr("imput", "helium")
    setup.pkgs.install(
        "@development-tools",
        "@virtualization",
        "distrobox",
        "fcitx-openbangla",
        "fcitx5-mozc",
        "fcitx5",
        "helium-bin",
        "nix",
        "pipx",
        "podman-compose",
        "podman-docker",
        "podman",
        "syncthing",
        "tailscale",
        "yakuake")  # fmt: skip
    setup.repos.disable_copr("badshah", "openbangla-keyboard")
    setup.repos.disable_copr("imput", "helium")

    # INSTALL: Base services
    #
    with open("/usr/lib/systemd/system/nix.mount", "w") as f:
        f.writelines((
            "[Unit]\n",
            "Description=Bind mount /var/nix to /nix for atomic system compatibility.\n",
            "\n",
            "[Mount]\n",
            "What=/var/nix\n",
            "Where=/nix\n",
            "Type=none\n",
            "Options=bind\n",
            "\n",
            "[Install]\n",
            "WantedBy=local-fs.target"))  # fmt: skip
    setup.core.vprint("# Created systemd service for /nix mount.")
    setup.core.vcat("/usr/lib/systemd/system/nix.mount")
    setup.systemd.enable_unit("nix.mount")
    setup.systemd.enable_unit("nix-daemon.service")
    setup.systemd.enable_unit("tailscaled.service")

    # FINALISE
    #
    setup.core.finalise()
    setup.core.vprint("# --**## Setup complete! ##**-- ")


if __name__ == "__main__":
    main()
