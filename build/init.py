#!/bin/env python
from unibuild import Setup  # pyright: ignore[reportImplicitRelativeImport]
from pathlib import Path


def main():
    setup = Setup(verbose=True)

    setup.core.vprint(r"# ----****#####****---- ")
    setup.core.vprint(r"#                       ")
    setup.core.vprint(r"#      _ _  _ _/_. _    ")
    setup.core.vprint(r"#     / / //_'/ /_\     ")
    setup.core.vprint(r"#                       ")
    setup.core.vprint(r"# ----****#####****---- ")
    setup.core.vprint()

    setup.core.vprint(f"# INFO: Verbose mode is {'on' if setup.verbose else 'off'}.")
    setup.core.vprint(f"# INFO: Image based on: Fedora {setup.identity.fedora_release()}.")

    # Set basic branding.
    #
    setup.identity.set_basic_identity_info(
        image_vendor="jahinzee",
        image_name="metis",
        image_pretty_name="Metis",
        use_github_conventions=True,
        base_image_name="Kinoite",
        base_image_url="ghcr.io/ublue-os/kinoite-main",
    )

    # Swap: fedora-logos -> generic-logos.
    #
    setup.pkgs.swap(
        "fedora-logos",
        "generic-logos",
    )

    # Remove: ujust, Firefox
    #
    setup.pkgs.uninstall(
        "ublue-os-just",
        "firefox",
    )

    # Setup: Terra
    #
    setup.repos.enable_url_repo("terra", "https://github.com/terrapkg/subatomic-repos/raw/main")
    setup.pkgs.install("terra-release")

    # Install: desktop apps and tweaks
    #
    with setup.repos.ctx_copr("matinlotfali", "KDE-Rounded-Corners"):
        setup.pkgs.install(
            "elisa",
            "gwenview",
            "haruna",
            "kalk",
            "kamoso",
            "kclock",
            "kcm_systemd",
            "kcolorchooser",
            "kolourpaint",
            "krdc",
            "ksystemlog",
            "kwin-effect-roundcorners",
            "merkuro",
            "okular",
            "plasma-browser-integration",
        )

    # region .disabled-01
    # with setup.repos.ctx_copr("errornointernet", "walker"):
    #     setup.pkgs.install(
    #         "elephant",
    #         "elephant-calc",
    #         "elephant-desktopapplications",
    #         "elephant-files",
    #         "elephant-symbols",
    #         "elephant-unicode",
    #         "elephant-windows",
    #         "walker",
    #     )
    #
    # endregion

    # Install: command-line and core applications
    #
    setup.pkgs.install(
        "bat",
        "btop",
        "@development-tools",
        "distrobox",
        "eza",
        "fastfetch",
        "fd",
        "fish",
        "ghostty",
        "helix",
        "just",
        "lm_sensors",
        "podman-docker",
        "podman-compose",
        "ripgrep",
        "rclone",
        "starship",
        "topgrade",
        "vim",
        "xlsclients",
        "zoxide",
    )

    # Install: virtualisation stack (libvirt/QEMU/KVM)
    #
    setup.pkgs.install("@virtualization")

    # Install: IMEs (jp/bn)
    #
    with setup.repos.ctx_copr("badshah", "openbangla-keyboard"):
        setup.pkgs.install(
            "fcitx5",
            "fcitx5-mozc",
            "kcm-fcitx5",
            "fcitx5-openbangla",
        )

    # Install: Syncthing and SyncthingTray (Plasmoid/KIO/CLI)
    #
    with setup.repos.ctx_obs_repo("home:mkittler"):
        setup.pkgs.install(
            "syncthing",
            "syncthingplasmoid-qt6",
            "syncthingfileitemaction-qt6",
            "syncthingctl-qt6",
        )

    # Install: printer drivers (brlaser)
    #
    setup.pkgs.install("printer-driver-brlaser")

    # Install: browsers (Zen, Helium)
    #
    # FIX: The zen-browser package needs to throw some stuff in /opt, which doesn't exist, so we'll
    #      manually (re)make the /opt directory (replacing the existing one which is just a symlink
    #      to /var/opt)
    #
    path = Path("/opt")
    setup.core.assert_condition(
        path.is_symlink(), failure_message=f"Failed to apply /opt patch: {path} is not a symlink."
    )
    path.unlink()
    path.mkdir()
    setup.core.vprint("# Applied /opt patch.")

    with setup.repos.ctx_copr("sneexy", "zen-browser"):
        setup.pkgs.install(
            "zen-browser",
            "helium-browser-bin",
        )

    # Install: Tailscale
    #
    with setup.repos.ctx_url_repo("tailscale", "https://pkgs.tailscale.com/stable/fedora"):
        setup.pkgs.install("tailscale")

    # Finalisation
    #
    setup.core.vprint(r"# ----****#####****---- ")
    setup.core.vprint(r"#    Setup complete!    ")
    setup.core.vprint(r"# ----****#####****---- ")

    setup.core.finalise()


if __name__ == "__main__":
    main()
