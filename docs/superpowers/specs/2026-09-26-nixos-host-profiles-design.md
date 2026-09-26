# NixOS host profiles design

## Goal

Extend the existing flake from one WSL configuration to three usable host profiles: WSL, laptop, and desktop. Keep shared command-line tooling available across profiles, keep WSL free of graphical applications, use i3 on graphical profiles, and enable NVIDIA drivers on desktop.

## Current state

- `flake.nix` defines only `nixosConfigurations.wsl`.
- `nixos/system/common.nix` contains system packages and settings that currently apply to WSL.
- `home/home.nix` contains shared Home Manager configuration and CLI utilities, and is imported by WSL.
- `hosts/wsl.nix` enables NixOS-WSL and names the host.
- There are no laptop or desktop hardware configuration modules in the repository.
- Existing uncommitted edits add Home Manager backup suffix handling, CLI packages and aliases, `herdr`, and `nixd`; preserve these edits and account for them in the resulting profile layout.

## Design

### Module boundaries

Keep `nixos/system/common.nix` for cross-profile NixOS settings and CLI system utilities. Keep common Home Manager CLI configuration in a shared module, including the existing shell setup, aliases, editor configuration, and command-line tools. Do not put graphical applications or graphical session services in these shared modules.

Keep `hosts/wsl.nix` as the WSL-specific module and ensure it imports only common CLI configuration. Add `hosts/laptop.nix` and `hosts/desktop.nix` for host-specific settings. Expose all three systems through `flake.nix`, using the existing `x86_64-linux` architecture and username unless current repository requirements indicate otherwise.

### Graphical profiles

Laptop and desktop will enable the i3 window manager and a graphical login/session. Their user environment will include Brave, Zed, and KeePassXC. Enable Flatpak at the system level and configure Flathub as a remote; install Bazaar as a Flatpak application. Keep the exact Bazaar Flatpak application ID in one clearly named setting so it can be adjusted if upstream packaging changes.

Desktop will enable the supported NixOS NVIDIA driver configuration with modesetting and the appropriate open/proprietary driver selection for current NixOS packages. The initial profile will not assume a particular GPU generation or add laptop NVIDIA settings.

### Hardware boundary

The repository has no hardware configuration files. Do not fabricate filesystem UUIDs, bootloader devices, kernel modules, or GPU hardware details. Keep those machine-generated settings out of the reusable host modules; make the new profile modules evaluable without inventing hardware data, and document where per-machine `hardware-configuration.nix` modules should be added when installing on actual machines.

## Success criteria

- The flake exposes `wsl`, `laptop`, and `desktop` configurations.
- Shared CLI tools and shell/editor setup remain available to each profile.
- WSL's system and Home Manager package sets contain no graphical applications or desktop session packages.
- Laptop and desktop enable i3 and receive Brave, Zed, KeePassXC, Flatpak/Flathub, and Bazaar.
- Desktop alone enables NVIDIA graphics support.
- Existing user modifications remain represented in the final configuration.

## Scope and follow-up

This change establishes reusable profiles, not machine-specific installation details. Hardware configuration, laptop-specific power management, display settings, and further applications can be added later as hardware and preferences become known.

## Validation approach

Review the final module graph and evaluate each flake configuration and the relevant Home Manager package sets. Do not deploy or rebuild a machine as part of this change.
