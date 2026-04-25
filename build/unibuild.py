#!/bin/env python3

# unibuild -- A single-file Python module for scripting Universal Blue image builds.
#
# Authors:
#     Jahin Z. <git@jahinzee.net>
#

# Copyright 2026 Jahin Z.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import annotations

from typing import TYPE_CHECKING, Callable, Never, final
from pathlib import Path

if TYPE_CHECKING:
    from _typeshed import SupportsWrite

from functools import partial

import sys
import subprocess
import platform
import shlex
import json

type _VoidCallable = Callable[[], None]


@final
class _ContextManager:
    """Simple context manager wrapper around two enter/exit callback functions."""

    __slots__ = ("_enter_callback", "_exit_callback")

    def __init__(self, enter_callback: _VoidCallable, exit_callback: _VoidCallable) -> None:
        self._enter_callback = enter_callback
        self._exit_callback = exit_callback

    def __enter__(self):
        self._enter_callback()

    def __exit__(self, _exc_type: type, _exc: Exception, _exc_tb: object):
        self._exit_callback()


@final
class _Core:
    """Core common functions for submodules and setup code."""

    __slots__ = ("_verbose",)

    def __init__(self, verbose: bool) -> None:
        self._verbose = verbose

    def fatal_error(self, summary: str, details: str = "", exit_code: int = -1) -> Never:
        """
        Print a fatal error message to stderr and exit script.

        Args:
            `summary` (`str`):
                A summary of the error.
            `details` (`str`, optional):
                Any additional information to display. Defaults to `""`.
            `exit_code` (`int`, optional):
                The exit code to exit with. Defaults to `-1`.

        Does not return.
        """
        self.vprint(f"# ! Fatal error: {summary}")
        for line in details.splitlines():
            self.vprint(f"# > {line}")
        exit(exit_code)

    def assert_condition(self, expr: bool, failure_message: str) -> None:
        """
        Assert that a condition is `True`, else exits with a failure message.

        Args:
            `expr` (`bool`): The expression to check.
            `failure_message` (`str`): The message to display if the assertion fails.
        """
        if not expr:
            self.fatal_error(f"Assertion failed: {failure_message}")

    def vprint(
        self,
        *args: object,
        verbose_only: bool = False,
        end: str = "\n",
        file: SupportsWrite[str] = sys.stderr,
    ) -> None:
        """
        Wrapper around `print(...)` for verbose checking and printing to stderr by default.

        Positional Args:
            `*args`: Passed to `print(...)`

        Keyword Args:
            `verbose_only` (`bool`, optional):
                Only print if in Verbose mode. Defaults to `False`.
            `end` (`str`, optional):
                Passed to `print(...)`
            `file` (`SupportsWrite[str]`, optional):
                Passed to `print(...)`. Defaults to `sys.stderr`.
        """
        if verbose_only and not self._verbose:
            return
        print(*args, file=file, end=end)

    def vcat(self, file_path: str) -> None:
        """
        Prints a confirmation of a file change, and the contents of the file if in Verbose mode.

        Args:
            `file_path` (`str`): The file to read out or confirm.
        """
        self.vprint(f"# Updated `{file_path}`.", end="")
        if not self._verbose:
            self.vprint(" Enable Verbose mode to examine file contents.")
            return
        self.vprint()
        with open(file_path) as f:
            for line in f.readlines():
                self.vprint(f"# > {line}", end="")
        self.vprint("\n")

    def run(self, *command: str, capture_stdout: bool = False) -> str | None:
        """
        Run a shell command. Prints stdout if Verbose mode is enabled. Calls `fatal_error` with
        stderr contents if command returns a non-zero exit code.

        Positional Args:
            `*args` (`str`): The command and arguments to run.

        Keyword Args:
            `capture_stdout` (`bool`, optional):
                If `True`, returns stdout as a string. Defaults to `False`.

        Returns:
            `str | None`: The stdout contents if `capture_stdout` is set, else `None`.
        """
        self.vprint("$", *command)
        stdout = (
            subprocess.PIPE if capture_stdout else None if self._verbose else subprocess.DEVNULL
        )
        result = subprocess.run(command, stdout=stdout, stderr=subprocess.PIPE)

        if result.returncode != 0:
            self.fatal_error(
                f"Previous command failed with exit code {result.returncode}.",
                details=(result.stderr or b"").decode("utf-8"),
                exit_code=result.returncode,
            )

        return result.stdout.decode("utf-8") if capture_stdout else None

    def finalise(self) -> None:
        """
        Commits the ostree container, and runs `bootc container lint`.
        """
        _ = self.run("ostree", "container", "commit")
        _ = self.run("bootc", "container", "lint")

    def unsymlink_directory(self, path: str | Path) -> None:
        path = Path(path)
        self.assert_condition(path.is_symlink(), f"{path} is not a symlink.")
        path.unlink()
        path.mkdir()

        self.assert_condition(not path.is_symlink(), f"Failed to unsymlink {path}.")

    @property
    def verbose(self) -> bool:
        return self._verbose


@final
class _Identity:
    """Functions for querying and setting image identity and version information."""

    __slots__ = ("_core",)

    def __init__(self, core: _Core) -> None:
        self._core = core

    @staticmethod
    def fedora_release() -> str:
        """
        Get the current Fedora version number.

        Returns:
            `str`: The version number as a string.
        """
        return platform.freedesktop_os_release()["VERSION_ID"]

    def set_os_release(self, **properties: str | None) -> None:
        """
        Update `/usr/lib/os-release` properties. Keeps existing keys unless parameters override
        them.

        Keyword Args:
            `**properties` (`str | None`):
                The properties to set or update. By convention, the keys should be in `SHOUTY_CASE`.
                `None` values will be skipped.
        """
        properties = {k: v for k, v in properties.items() if v is not None}
        os_release = platform.freedesktop_os_release() | properties
        with open("/usr/lib/os-release", "w+") as f:
            f.writelines(
                f"{key}={shlex.quote(val)}\n" for key, val in os_release.items() if val is not None
            )
        self._core.vcat("/usr/lib/os-release")

    def set_image_info(self, properties: dict[str, str | None]) -> None:
        """
        Update `/usr/share/ublue-os/image-info.json` properties. Overwrites the contents of any
        existing `image-info.json` file.

        Args:
            `properties` (`dict[str, str | None]`):
                The properties to set. By convention, the keys should be in `kebab-case`.
                `None` values will be skipped.
        """
        properties = {k: v for k, v in properties.items() if v is not None}
        with open("/usr/share/ublue-os/image-info.json", "w+") as f:
            json.dump(properties, f, indent=4)
        self._core.vcat("/usr/share/ublue-os/image-info.json")

    def set_basic_identity_info(
        self,
        *,
        image_vendor: str,
        image_name: str,
        image_pretty_name: str | None = None,
        image_like: str | None = None,
        codename: str | None = None,
        use_github_conventions: bool = False,
        home_url: str | None = None,
        docs_url: str | None = None,
        support_url: str | None = None,
        image_reference_url: str | None = None,
        base_image_name: str | None = None,
        base_image_url: str | None = None,
        default_hostname: str | None = None,
    ) -> None:
        """
        Scaffold for quickly setting up `os-release` and `image-info.json` files.

        Keyword Args:
            `image_vendor` (`str`):
                The image vendor name e.g. your username.
            `image_name` (`str`):
                The simple name of the image, should be `kebab-case` or `snake_case`.
            `image_pretty_name` (`str | None`, optional):
                A stylised version of your image name.
                If unspecified, reuses `image_name`.
            `image_like` (`str | None`, optional):
                The closest popular image the image is based on -- recommended to leave unspecified.
                If unspecified, uses "fedora".
            `codename` (`str | None`, optional):
                A version codename. If unspecified, uses an empty string `''`.
            `use_github_conventions` (`bool`, optional):
                If True, follow simple conventions assuming the image source and container
                endpoints are hosted on GitHub and ghcr.io. Defaults to `False`.
            `home_url` (`str | None`, optional):
                The URL of the image's homepage.
                Can be autogenerated with `use_github_conventions`. Defaults to `None`.
            `docs_url` (`str | None`, optional):
                The URL of the image's documentation.
                Can be autogenerated with `use_github_conventions`. Defaults to `None`.
            `support_url` (`str | None`, optional):
                The URL of the image's support portal.
                Can be autogenerated with `use_github_conventions`. Defaults to `None`.
            `image_reference_url` (`str | None`, optional):
                The URL of the image's container on a registry.
                Can be autogenerated with `use_github_conventions`. Defaults to `None`.
            `base_image_name` (`str | None`, optional):
                The pretty name which this image is based on. The Fedora version number will be
                suffixed on. Ommitted from `os-release` and `image-info.json` if unspecified.
            `base_image_name` (`str | None`, optional):
                The image URL which this image is based on. Ommitted from os-release if unspecified.
            `default_hostname` (`str | None`, optional):
                The default hostname given to new installations. Uses `"localhost"` if unspecified.
        """
        # Based on: https://github.com/winblues/blue95/blob/main/files/scripts/00-image-info.sh
        # Authors: jahinzee, ledif
        # Changes:
        #   * rewritten logic to Python, leveraging `configparser`, `shlex` and `json`
        #   * added ID_LIKE fixes
        #   * added options for custom hostname, codenames, etc.
        #   * added assertion checks for grub2-switch-to-blscfg patches
        #
        image_pretty_name = image_pretty_name or image_name
        image_like = image_like or "fedora"
        home_url = home_url or (
            f"https://github.com/{image_vendor}/{image_name}" if use_github_conventions else None
        )
        docs_url = docs_url or (
            f"https://github.com/{image_vendor}/{image_name}/blob/main/README.md"
            if use_github_conventions
            else None
        )
        support_url = support_url or (
            f"https://github.com/{image_vendor}/{image_name}/issues"
            if use_github_conventions
            else None
        )
        image_reference_url = image_reference_url or (
            f"ostree-image-signed:docker://ghcr.io/{image_vendor}/{image_name}"
            if use_github_conventions
            else None
        )
        codename = codename or ""
        fedora_major_version = self.fedora_release()
        base_image_name = f"{base_image_name} {fedora_major_version}" if base_image_name else None
        default_hostname = default_hostname or "localhost"

        self.set_image_info(
            {
                "image-name": image_name,
                "image-vendor": image_vendor,
                "image-ref": image_reference_url,
                "base-image-name": base_image_url,
                "fedora-version": fedora_major_version,
            }
        )
        self.set_os_release(
            VARIANT_ID=image_name,
            PRETTY_NAME=f"{image_pretty_name} (FROM Fedora {base_image_name})",
            NAME=image_pretty_name,
            ID=image_name,
            # Add ID_LIKE tag to allow external apps to properly identify that this image is based
            # on Fedora.
            #
            ID_LIKE=image_like,
            CODENAME=codename,
            HOME_URL=home_url,
            DOCUMENTATION_URL=docs_url,
            SUPPORT_URL=support_url,
            CPE_NAME=f"cpe:/o:{image_vendor}:{image_pretty_name}",
            DEFAULT_HOSTNAME=default_hostname,
        )
        # Fix issues caused by ID no longer being fedora.
        #
        _ = self._core.run(
            "sed", "-i", 's/^EFIDIR=.*/EFIDIR=\\"fedora\\"/', "/usr/sbin/grub2-switch-to-blscfg"
        )
        # Assert that the patch actually worked.
        #
        self._core.assert_condition(
            self._core.run(
                "grep", "-i", "^EFIDIR", "/usr/sbin/grub2-switch-to-blscfg", capture_stdout=True
            )
            == 'EFIDIR="fedora"\n',
            failure_message="Failed to apply grub2-switch-to-blscfg patch.",
        )
        self._core.vprint("# Applied grub2-switch-to-blscfg patch.")


@final
class _Packages:
    """Functions for managing DNF5 packages."""

    __slots__ = ("_core",)

    def __init__(self, core: _Core) -> None:
        self._core = core

    def install(self, *pkgs: str) -> None:
        """
        Install packages with DNF5.

        Positional arguments:
            `*pkgs` (`str`): The packages to install.
        """
        _ = self._core.run("dnf5", "install", "-y", *pkgs)

    def uninstall(self, *pkgs: str) -> None:
        """
        Uninstall packages with DNF5.

        Positional arguments:
            `*pkgs` (`str`): The packages to uninstall.
        """
        _ = self._core.run("dnf5", "remove", "-y", *pkgs)

    def swap(self, left: str, right: str) -> None:
        """
        Swap two packages with DNF5.

        Args:
            `left` (`str`): The package to install.
            `right` (`str`): The package to uninstall.
        """
        _ = self._core.run("dnf5", "swap", "-y", left, right)


@final
class _Repositories:
    """Functions for managing repositories."""

    def __init__(self, core: _Core) -> None:
        self._core = core

    def enable_copr(self, author: str, repo: str) -> None:
        """
        Enable a COPR repository.

        Args:
            `author` (`str`):
                The author of the COPR -- the section before the `/` in the identifier.
            `repo` (`str`):
                The name of the COPR -- the section after the `/` in the identifier.
        """
        _ = self._core.run("dnf5", "copr", "enable", "-y", f"{author}/{repo}")

    def disable_copr(self, author: str, repo: str) -> None:
        """
        Disable a COPR repository.

        Args:
            `author` (`str`):
                The author of the COPR -- the section before the `/` in the identifier.
            `repo` (`str`):
                The name of the COPR -- the section after the `/` in the identifier.
        """
        _ = self._core.run("dnf5", "copr", "disable", "-y", f"{author}/{repo}")

    # JUSTIFY:
    def ctx_copr(self, author: str, repo: str) -> _ContextManager:
        """
        Context manager: enables a COPR on creation, and disables it on exit.

        Args:
            `author` (`str`):
                The author of the COPR -- the section before the `/` in the identifier.
            `repo` (`str`):
                The name of the COPR -- the section after the `/` in the identifier.
        """
        return _ContextManager(
            enter_callback=(partial(self.enable_copr, author, repo)),
            exit_callback=(partial(self.disable_copr, author, repo)),
        )

    def enable_repo(self, repo_file: str) -> None:
        """
        Enable a repository from an arbitrary repofile.

        Args:
            `repo_file` (`str`): The path of the repofile *without* the `.repo` extension.
        """
        _ = self._core.run(
            "dnf5", "config-manager", "addrepo", "-y", f"--from-repofile={repo_file}.repo"
        )

    def disable_repo(self, repo_file: str) -> None:
        """
        Disable and delete an existing repofile.

        Args:
            `repo_file` (`str`):
                The name of the repofile in `/etc/yum.repos.d/` *without* the `.repo` extension.
        """
        _ = self._core.run("rm", f"/etc/yum.repos.d/{repo_file}.repo")

    def enable_url_repo(self, repo_name: str, base_url: str) -> None:
        """
        Enable a repo from a URL.

        Args:
            `repo_name` (`str`): The name of the repofile *without* the `.repo` extension.
            `base_url` (`str`): The URL the repofile is hosted on -- path before the final `/`.
        """
        self.enable_repo(f"{base_url}/{repo_name}")

    def ctx_url_repo(self, repo_name: str, base_url: str) -> _ContextManager:
        """
        Context manager: enable a repo from a URL on enter, and removes it on exit.

        Args:
            `repo_name` (`str`): The name of the repofile *without* the `.repo` extension.
            `base_url` (`str`): The URL the repofile is hosted on -- path before the final `/`.
        """
        return _ContextManager(
            enter_callback=(partial(self.enable_url_repo, repo_name, base_url)),
            exit_callback=(partial(self.disable_repo, repo_name)),
        )

    def enable_obs_repo(
        self, repo_id: str, *, root_url: str = "https://download.opensuse.org"
    ) -> None:
        """
        Enable an OBS (Open Build Service) repository.

        Args:
            `repo_id` (`str`): The OBS repo ID.
            `root_url` (`str`, optional): The root location URL. Defaults to `"opensuse.org"`.
        """
        _release = _Identity.fedora_release()
        self.enable_url_repo(repo_id, f"{root_url}/repositories/{repo_id}/Fedora_{_release}")

    def ctx_obs_repo(
        self, repo_id: str, *, root_url: str = "https://download.opensuse.org"
    ) -> _ContextManager:
        """
        Context manager: enable an OBS (Open Build Service) repository from opensuse.org on enter,
        and removes it on exit.

        Args:
            `repo_id` (`str`): The OBS repo ID.

        Keyword args:
            `root_url` (`str`, optional): The root location URL. Defaults to `"opensuse.org"`.
        """
        return _ContextManager(
            enter_callback=(partial(self.enable_obs_repo, repo_id, root_url=root_url)),
            exit_callback=(partial(self.disable_repo, repo_id)),
        )


@final
class Setup:
    """Tools to setup a Universal Blue image."""

    __slots__ = ("_verbose", "_core", "_identity", "_packages", "_repositories")

    def __init__(self, verbose: bool = False) -> None:
        """
        Tools to setup an immutable image.

        Args:
            `verbose` (`bool`, optional):
                Verbose mode -- prints additional debug information and subcommand output to the
                console for debugging. Defaults to `False`.
        """
        self._verbose = verbose
        self._core = _Core(verbose=verbose)
        self._identity = _Identity(core=self._core)
        self._packages = _Packages(core=self._core)
        self._repositories = _Repositories(core=self._core)

    @property
    def core(self) -> _Core:
        """Common functions for shared internal code and ad-hoc operations."""
        return self._core

    @property
    def identity(self) -> _Identity:
        """Functions for querying and setting image identity and version information."""
        return self._identity

    @property
    def pkgs(self) -> _Packages:
        """Functions for managing DNF5 packages."""
        return self._packages

    @property
    def repos(self) -> _Repositories:
        """Functions for managing repositories."""
        return self._repositories

    @property
    def verbose(self) -> bool:
        """Whether or not the Setup object with initialised with `verbose=True`."""
        return self._verbose
