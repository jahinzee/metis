# metis

An atomic distro for an audience of one (me).

> [!WARNING]
> This image is made for my own personal use. If you choose to use this for
> whatever reason, I cannot help you if something breaks.

## Further Links

- The original [image-template](/docs/old-readme.md) README for reference.
- [Package notes](/docs/package-notes.md), mainly for documenting COPRs in use.

## Usage

### Rebasing to Metis

ISO building is very flaky at the moment, so we'll be using the good ol'
"rebase from another install" method.

1. Install another Fedora Atomic or Universal Blue image, I recommend
   [Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/).


> [!NOTE]
> If you are rebasing from Kinoite, there's a chance there may be some Flatpaks
> preinstall that overlap with the base images' apps. You should remove them
> before continuing:
> 
> ```
> flatpak list --columns=application | xargs flatpak uninstall -y
> ```
> 
> You can manually (re)add any Flatpak you want after you rebase.

2. Open Konsole and run this command to rebase to the unsigned variant of this
   image (we'll re-rebase to the signed one later, but we have to go unsigned
   for a moment.)

   ```sh
   rpm-ostree rebase ostree-unverified-registry:ghcr.io/jahinzee/metis
   ```

3. Reboot the system.

   ```sh
   systemctl reboot # or use the power options from the desktop.
   ```

4. Open Konsole again and run this command to now rebase onto the signed
   variant.

   ```sh
   rpm-ostree rebase ostree-image-signed:docker://ghcr.io/
   ```

5. Reboot once again.

### Post-Install Notes

- You can switch your default shell to `fish` with `usermod` (`chsh` does not
  exist here):

  ```
  sudo usermod --shell /bin/fish <username>
  ```

- For proper IME support, open the *Virtual Keyboard* page in System Settings,
  and select and apply *Fcitx 5 Wayland Launcher (Experimental)*.
  
  Afterwards, log out and log in again to activate the IME.

- There are support packages for Homebrew, but Homebrew itself is not
  installed.

  Visit [the Homebrew website](https://brew.sh/) for up-to-date installation
  instructions.