# Host profiles

The flake exposes three NixOS configurations:

| Flake attribute | Purpose |
| --- | --- |
| `.#wsl` | NixOS-WSL with shared command-line tools only |
| `.#laptop` | Laptop profile with i3, Brave, Zed, KeePassXC, and Flatpak |
| `.#desktop` | Desktop profile with the laptop graphical tools and NVIDIA support |

Apply a profile on its matching NixOS host with:

```sh
sudo nixos-rebuild switch --flake .#laptop
```

Replace `laptop` with `desktop` or `wsl` as appropriate. The graphical profiles
use i3, greetd with the tuigreet text greeter, and PipeWire. Bazaar is installed
as the `io.github.kolunmi.Bazaar` Flatpak from Flathub by
[nix-flatpak](https://github.com/gmodena/nix-flatpak).

## Deploy the current laptop profile

`hosts/laptop-hardware.nix` belongs only to the current VMware installation.
It contains that machine's filesystem and swap UUIDs. Do not reuse it on
another machine.

From the repository root, build without changing the running system:

```sh
nixos-rebuild build --flake .#laptop \
  --option extra-experimental-features 'nix-command flakes'
```

If the build succeeds, activate it temporarily:

```sh
sudo nixos-rebuild test --flake .#laptop \
  --option extra-experimental-features 'nix-command flakes'
```

Before making it persistent, verify the system, network, login manager, and
audio units:

```sh
systemctl is-system-running
systemctl is-active NetworkManager
systemctl status greetd --no-pager
systemctl --user status pipewire pipewire-pulse wireplumber --no-pager
getent passwd itterum
```

The running i3 session is not replaced by `nixos-rebuild test`. The tuigreet
screen appears after the next logout or reboot. Once the temporary generation
is healthy, make it the default boot generation:

```sh
sudo nixos-rebuild switch --flake .#laptop \
  --option extra-experimental-features 'nix-command flakes'
```

Do not remove old generations during the migration. To return to the previous
persistent generation, select it in the boot menu or run:

```sh
sudo nixos-rebuild switch --rollback
```

## Machine-specific setup

The current `laptop` attribute is tied to this VMware machine. The `desktop`
file remains a reusable profile without disk, root filesystem, bootloader, or
generated hardware settings. Give every future physical or virtual machine
its own host module, hardware module, and unique flake attribute.

On each future machine:

1. Install or boot NixOS and generate configuration for that machine with
   `sudo nixos-generate-config`.
2. Copy its generated `/etc/nixos/hardware-configuration.nix` to a unique name,
   such as `hosts/travel-laptop-hardware.nix`.
3. Create `hosts/travel-laptop.nix`, import the new hardware file and the
   reusable `nixos/system/graphical.nix`, then declare only that machine's
   hostname, bootloader, locale, keyboard, and other host policy.
4. Add a unique `nixosConfigurations.travel-laptop` entry to `flake.nix` and
   include `home/graphical.nix` for that graphical host.
5. Preserve the target installation's original `system.stateVersion` and
   `home.stateVersion`; do not raise them merely because nixpkgs was updated.
6. Build the exact new attribute, use `nixos-rebuild test`, complete the health
   checks, and only then use `nixos-rebuild switch`.

Never copy filesystem or swap UUIDs from another host. Do not commit password
hashes, private keys, tokens, or other unencrypted secrets. Set account
credentials locally or introduce encrypted secret management first.

The desktop profile selects the open NVIDIA kernel module and enables modesetting. Confirm that the desktop GPU supports the open module; for hardware that needs the proprietary kernel module, change `hardware.nvidia.open` in `hosts/desktop.nix` to `false`.

The WSL profile does not import graphical modules or install GUI applications.
Shared CLI packages, shell setup, and the Helix configuration live in the
common system and Home Manager modules.
