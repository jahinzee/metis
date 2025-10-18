# metis

An atomic distro for an audience of one (me).

> [!WARNING]
> This image is made for my own personal use. If you choose to use this for whatever reason, I
> cannot help you if something breaks.

## Further Links

- The original [image-template README][] for reference.

[image-template README]: /docs/old-readme.md

## Usage

### Rebasing to Metis

ISO building is not set up at this moment, so we'll be using the good ol' "rebase from another
install" method.

1. Install another Fedora Atomic or Universal Blue image, I recommend [Kinoite][] for optimal
   rebasing.

   [Kinoite]: https://fedoraproject.org/atomic-desktops/kinoite/

   > [!NOTE]
   > If you are rebasing from Kinoite, there's a chance there may be some Flatpaks preinstall that
   > overlap with the base images' apps. You should remove them before continuing:
   > 
   > ```sh
   > flatpak list --columns=application | xargs flatpak uninstall -y
   > ```
   > 
   > You can manually (re)add any Flatpak you want after you rebase.

2. Open Konsole and run this command to rebase to the unsigned variant of this image (we'll
   re-rebase to the signed one later, but we have to go unsigned for a moment.)

   ```sh
   rpm-ostree rebase ostree-unverified-registry:ghcr.io/jahinzee/metis
   ```

3. Reboot the system.

   ```sh
   systemctl reboot # or use the power options from the desktop.
   ```

4. Open Konsole again and run this command to now rebase onto the signed variant.

   ```sh
   rpm-ostree rebase ostree-image-signed:docker://ghcr.io/jahinzee/metis
   ```

5. Reboot once again.

## Post-Install Notes

### Default Shell

You can switch your default shell to `fish` with `usermod` (`chsh` is not installed):

```sh
sudo usermod --shell /bin/fish "$(whoami)"
```

### IME Setup

For proper IME support, open the *Virtual Keyboard* page in System Settings, and select and
apply *Fcitx 5 Wayland Launcher (Experimental)*.
  
Afterwards, log out and log in again to activate the IME.

### Homebrew

There are support packages for Homebrew, but Homebrew itself is not installed.

Visit [the Homebrew website](https://brew.sh/) for up-to-date installation instructions.

The post-install instructions require you to set your shell environment to load Homebrew, but these
instructions are given for Bash only. For Fish, add [this code][] to your [Fish config][].

[this code]: https://github.com/orgs/Homebrew/discussions/4412#discussioncomment-8314181
[Fish config]: https://fishshell.com/docs/current/index.html#configuration

### `pipx`

`pipx` requires additional user-level shell support to access installed packages. This is easily
done with this command:

```sh
pipx ensurepath
```

This will work for both Bash and Fish.

### Syncthing

Enable the Syncthing service for your current user with:

```sh
systemctl enable "syncthing@$(whoami).service" --now
```

Alternatively, create an Autostart entry in System Settings.


