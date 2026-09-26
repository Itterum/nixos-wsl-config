# NixOS Host Profiles Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add WSL, laptop, and desktop NixOS profiles with shared CLI tools, i3 graphical profiles, and NVIDIA support on desktop.

**Architecture:** Keep shared system CLI configuration in `nixos/system/common.nix` and shared Home Manager CLI configuration in `home/home.nix`. Add a reusable graphical system module for laptop and desktop, with focused host modules for WSL, laptop, and desktop; expose all three through the flake.

**Tech Stack:** Nix flakes, NixOS modules, Home Manager, NixOS Flatpak module, i3, NVIDIA kernel driver.

**Spec:** `docs/superpowers/specs/2026-09-26-nixos-host-profiles-design.md`

## Global Constraints

- The flake exposes `wsl`, `laptop`, and `desktop` configurations.
- Shared CLI tools and shell/editor setup remain available to each profile.
- WSL's system and Home Manager package sets contain no graphical applications or desktop session packages.
- Laptop and desktop enable i3 and receive Brave, Zed, KeePassXC, Flatpak/Flathub, and Bazaar.
- Desktop alone enables NVIDIA graphics support.
- Existing user modifications remain represented in the final configuration.
- Keep `x86_64-linux` and the configured username unless current repository requirements indicate otherwise.
- Do not invent machine-generated filesystem UUIDs, bootloader devices, kernel modules, or GPU hardware details.

## Review Focus

- WSL accidentally receiving GUI packages/session: evaluate its package/module graph and confirm graphical module is absent.
- Graphical profiles missing one of the requested applications or Flathub: inspect evaluated module options.
- Bazaar remote/application declaration mismatch: use the Flathub remote and the Bazaar app ID `io.github.kolunmi.Bazaar` together.
- NVIDIA option invalid or enabled outside desktop: evaluate all three configurations and inspect desktop graphics options.
- Existing user changes dropped during module extraction: compare final common packages, aliases, editor, `herdr`, `nixd`, and Home Manager backup suffix against current worktree.

---

### Task 1: Separate shared CLI and graphical system modules

**Files:**
- Modify: `nixos/system/common.nix`
- Create: `nixos/system/graphical.nix`
- Keep: `home/home.nix` as the shared CLI Home Manager module

**Interfaces:**
- `nixos/system/common.nix` remains imported by every profile and contains only profile-neutral system settings and CLI tools.
- `nixos/system/graphical.nix` is imported only by laptop and desktop and configures i3, LightDM, Brave, Zed, KeePassXC, Flatpak/Flathub, and Bazaar (`io.github.kolunmi.Bazaar`).

- [ ] Move WSL-specific `GH_BROWSER = "explorer.exe"` from common system variables into `hosts/wsl.nix`; retain the neutral terminal variables in common.
- [ ] Add a graphical system module enabling X11, LightDM with i3 as the session, and i3 window manager.
- [ ] Add Brave, Zed (`zed-editor`), and KeePassXC as graphical-profile system packages.
- [ ] Enable Flatpak, declare the Flathub remote, and install Bazaar through Flatpak.
- [ ] Preserve shared CLI package/config additions already in the worktree, including `herdr`, Home Manager backup extension, tools, aliases, and editor setup.
- [ ] Inspect the diff to confirm common and shared Home Manager modules contain no graphical apps or sessions.

### Task 2: Add host modules and flake configurations

**Files:**
- Create: `hosts/laptop.nix`
- Create: `hosts/desktop.nix`
- Modify: `hosts/wsl.nix`
- Modify: `flake.nix`

**Interfaces:**
- Each `nixosConfigurations.<host>` imports common system settings and shared Home Manager CLI settings.
- Laptop and desktop additionally import `nixos/system/graphical.nix`.
- Desktop enables NVIDIA support (`services.xserver.videoDrivers = [ "nvidia" ];`, graphics acceleration, and the open kernel module setting); WSL and laptop do not.

- [ ] Move the WSL GitHub browser variable into its WSL module and retain existing WSL integration settings.
- [ ] Add laptop and desktop host modules with hostnames and their shared graphical module import (directly in flake module list or through host imports, keeping responsibility easy to follow).
- [ ] Configure NVIDIA only for desktop with current NixOS options, using the open NVIDIA kernel module setting and leaving device-specific hardware configuration out.
- [ ] Factor flake module construction only as much as needed to avoid duplicating the shared Home Manager setup while exposing `wsl`, `laptop`, and `desktop`.
- [ ] Run `nix flake show` and `nix eval .#nixosConfigurations.wsl.config.system.build.toplevel.drvPath`, then evaluate the matching laptop and desktop derivation paths; resolve evaluation errors.
- [ ] Review evaluated package/module options to confirm WSL is CLI-only, both graphical profiles have the requested apps, and NVIDIA is desktop-only.

### Task 3: Document hardware-specific installation boundary

**Files:**
- Create or modify: `README.md` (or a focused `hosts/README.md` if a README already exists)

**Interfaces:**
- Documentation describes which flake attribute to build for each profile and where per-machine hardware configuration belongs.

- [ ] Document `wsl`, `laptop`, and `desktop` profile intent and build attribute names.
- [ ] Explain that real installations need machine-generated hardware configuration and that this repository intentionally does not invent disk or GPU details.
- [ ] Confirm the documentation names Bazaar as a Flathub Flatpak and identifies that GUI applications are limited to laptop and desktop.
