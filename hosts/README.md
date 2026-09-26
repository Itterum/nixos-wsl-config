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

Replace `laptop` with `desktop` or `wsl` as appropriate. The graphical profiles use i3 with LightDM. Bazaar is installed as the `io.github.kolunmi.Bazaar` Flatpak from Flathub by [nix-flatpak](https://github.com/gmodena/nix-flatpak).

## Machine-specific setup

The laptop and desktop files are reusable profiles; they do not contain disk, root filesystem, bootloader, or generated hardware settings. Before building or installing one on a real machine:

1. Generate that machine's NixOS hardware configuration and save it as `hosts/laptop-hardware.nix` or `hosts/desktop-hardware.nix`.
2. Import the matching file from `hosts/laptop.nix` or `hosts/desktop.nix`.
3. Add the machine's root and boot filesystems and bootloader settings to its hardware-specific module.
4. Set credentials for the `itterum` account using the machine's secure setup; this repository does not include a password.

The desktop profile selects the open NVIDIA kernel module and enables modesetting. Confirm that the desktop GPU supports the open module; for hardware that needs the proprietary kernel module, change `hardware.nvidia.open` in `hosts/desktop.nix` to `false`.

The WSL profile does not import graphical modules or install GUI applications. Shared CLI packages, shell setup, and the Helix configuration live in the common system and Home Manager modules.
