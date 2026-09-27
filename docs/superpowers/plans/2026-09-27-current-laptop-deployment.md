# Current Laptop Deployment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `.#laptop` reproducibly build and run on the current VMware NixOS machine with greetd/tuigreet, PipeWire, declarative i3/i3status, and documented onboarding for future machines.

**Architecture:** Keep machine facts in `hosts/laptop-hardware.nix`, laptop policy in `hosts/laptop.nix`, and reusable graphical services in `nixos/system/graphical.nix`. Split Home Manager into the existing CLI-only entry point and a graphical entry point used only by laptop and desktop, so WSL stays free of GUI packages.

**Tech Stack:** Nix flakes, NixOS 26.05 modules, Home Manager, systemd-boot, X11/startx, i3, i3status, greetd/tuigreet, PipeWire/WirePlumber.

**Spec:** `docs/superpowers/specs/2026-09-27-current-laptop-deployment-design.md`

## Global Constraints

- Preserve `system.stateVersion = "26.05"` and `home.stateVersion = "26.05"`.
- Copy the current machine's UUIDs and initrd facts only into `hosts/laptop-hardware.nix`; never reuse them for another machine.
- Keep WSL free of graphical, audio, login-manager, bootloader, and disk configuration.
- Keep desktop free of the current laptop's hardware and boot configuration.
- Require password authentication through tuigreet; do not configure greetd `initial_session` or display-manager auto-login.
- Use PipeWire with WirePlumber, ALSA, and PulseAudio compatibility; do not enable the legacy PulseAudio daemon.
- Keep the existing i3 key behavior and i3status blocks, and declare every executable they call.
- Do not delete NixOS generations or reboot during implementation.
- Do not run `nixos-rebuild switch` until build and `nixos-rebuild test` verification succeed.

## Review Focus

- A hardware import must make laptop buildable without leaking its UUIDs or bootloader into WSL or desktop; Task 1 pins this with positive and negative evaluations.
- Replacing LightDM must still start an authenticated X11 i3 session; Task 2 evaluates greetd, tuigreet, startx, and disabled auto-login/LightDM options.
- PipeWire compatibility must provide working `pactl` bindings without starting PulseAudio; Tasks 2 and 3 evaluate the service flags and executable closure.
- Graphical Home Manager modules must never enter WSL; Task 3 evaluates i3 enablement and package separation for all profiles.
- A future host must not copy this machine's UUIDs or `stateVersion`; Task 4 documents and checks the host-specific onboarding and rollback procedure.

---

### Task 1: Make the current laptop profile bootable

**Files:**
- Create: `hosts/laptop-hardware.nix`
- Modify: `hosts/laptop.nix`
- Modify: `nixos/system/common.nix`

**Interfaces:**
- Consumes: `/etc/nixos/hardware-configuration.nix` from the current VMware installation.
- Produces: a laptop profile with current filesystems, swap, systemd-boot, locale/XKB policy, fonts, and flake support; later tasks build on this evaluable host.

- [ ] **Step 1: Record the current failure and isolation baselines**

Run:

```bash
nixos-rebuild build --flake .#laptop --option extra-experimental-features 'nix-command flakes'
nix --extra-experimental-features 'nix-command flakes' eval --json .#nixosConfigurations.wsl.config.fileSystems
nix --extra-experimental-features 'nix-command flakes' eval --json .#nixosConfigurations.desktop.config.fileSystems
```

Expected: laptop fails with missing root filesystem and bootloader assertions; WSL and desktop outputs contain none of the current machine's disk UUIDs.

- [ ] **Step 2: Add the generated hardware module**

Copy the complete contents of `/etc/nixos/hardware-configuration.nix` into `hosts/laptop-hardware.nix` without changing UUIDs, filesystem types, mount options, swap, initrd modules, or `nixpkgs.hostPlatform`.

- [ ] **Step 3: Add laptop machine policy**

In `hosts/laptop.nix`, import both `../nixos/system/graphical.nix` and `./laptop-hardware.nix`; enable systemd-boot and EFI variable access; set `Europe/Chisinau`, `en_US.UTF-8`, XKB `us,ru` with `grp:shifts_toggle,ctrl:nocaps`, hostname `laptop`, the three agreed font packages, and their monospace/sans-serif defaults. Do not add auto-login.

- [ ] **Step 4: Enable flakes declaratively**

In `nixos/system/common.nix`, set `nix.settings.experimental-features = [ "nix-command" "flakes" ];` without changing either state version.

- [ ] **Step 5: Verify laptop hardware and cross-profile isolation**

Run targeted `nix eval --json` checks for laptop `fileSystems`, `swapDevices`, `boot.loader.systemd-boot.enable`, locale, XKB, fonts, and hostname. Evaluate WSL and desktop `fileSystems` and bootloader settings and search their JSON output for `34bc3603-33fb-4436-a5e9-d3f02984235f`, `C3C8-1262`, and `dc292002-ba48-4327-a6a7-e1deffaa700f`.

Expected: laptop contains the exact current UUIDs and systemd-boot is `true`; neither other profile contains those UUIDs or inherits laptop boot policy.

- [ ] **Step 6: Commit the bootable host boundary**

```bash
git add hosts/laptop-hardware.nix hosts/laptop.nix nixos/system/common.nix
git -c user.name='lyashenko.ivan' -c user.email='ivan.lyashenko.it@gmail.com' commit -m "feat: configure current laptop hardware"
```

### Task 2: Replace the graphical login and audio stack

**Files:**
- Modify: `nixos/system/graphical.nix`

**Interfaces:**
- Consumes: the existing shared graphical profile and its single enabled X11 window manager, i3.
- Produces: authenticated `greetd → tuigreet → startx → i3` startup and PipeWire audio for laptop and desktop.

- [ ] **Step 1: Capture failing graphical-stack assertions**

Evaluate laptop options for `services.greetd.enable`, `services.xserver.displayManager.startx.enable`, `services.xserver.displayManager.lightdm.enable`, `services.displayManager.autoLogin.enable`, `services.pipewire`, `services.pulseaudio.enable`, and `security.rtkit.enable`.

Expected before implementation: greetd/startx and the required audio flags are not all enabled, while LightDM is enabled.

- [ ] **Step 2: Configure greetd and startx**

In `nixos/system/graphical.nix`, remove LightDM configuration, retain X11 and i3, enable `services.xserver.displayManager.startx` with `generateScript = true`, and enable `services.greetd.useTextGreeter`. Set `services.greetd.settings.default_session.command` to the absolute tuigreet executable with `--time`, `--remember`, and an absolute `startx` command; keep the session user as `greeter` and do not define `initial_session`.

- [ ] **Step 3: Configure PipeWire**

In the same module, set `services.pipewire.enable`, `audio.enable`, `alsa.enable`, `pulse.enable`, and `wireplumber.enable` to true; enable `security.rtkit`; explicitly disable `services.pulseaudio`.

- [ ] **Step 4: Evaluate the login and audio contracts**

Run `nix eval --json` assertions that laptop and desktop have greetd, text-greeter mode, startx script generation, PipeWire audio/ALSA/Pulse/WirePlumber, and RTKit enabled; assert LightDM, auto-login, and legacy PulseAudio are false. Evaluate WSL and assert greetd, X11, and PipeWire audio are disabled.

Expected: every assertion evaluates successfully, and the greetd command contains store paths for both `tuigreet` and `startx` but no `initial_session` is present.

- [ ] **Step 5: Commit the graphical stack**

```bash
git add nixos/system/graphical.nix
git -c user.name='lyashenko.ivan' -c user.email='ivan.lyashenko.it@gmail.com' commit -m "feat: use greetd and pipewire for graphical hosts"
```

### Task 3: Manage i3 and i3status through Home Manager

**Files:**
- Create: `home/graphical.nix`
- Create: `home/programs/i3/default.nix`
- Modify: `flake.nix`

**Interfaces:**
- Consumes: package set `pkgs`, username `itterum`, current `~/.config/i3/config`, current `~/.config/i3status/config`, and the graphical-host distinction from `flake.nix`.
- Produces: structured Home Manager i3/i3status configuration enabled only for laptop and desktop.

- [ ] **Step 1: Record the current Home Manager separation failure**

Evaluate `home-manager.users.itterum.xsession.windowManager.i3.enable` and `programs.i3status.enable` for WSL, laptop, and desktop.

Expected before implementation: i3 and i3status are not declaratively enabled in any Home Manager profile.

- [ ] **Step 2: Add the graphical Home Manager entry point**

Create `home/graphical.nix` with a single import of `./programs/i3`. Keep `home/home.nix` unchanged and CLI-only.

- [ ] **Step 3: Route graphical Home Manager modules by host**

Change `mkHost` in `flake.nix` to accept an attribute set with `extraModules` and optional `homeModules`. Configure `home-manager.users.${username}.imports` as `[ ./home/home.nix ] ++ homeModules`; pass no graphical module to WSL and pass `[ ./home/graphical.nix ]` to laptop and desktop.

- [ ] **Step 4: Declare i3 dependencies and startup**

In `home/programs/i3/default.nix`, enable `xsession` and `xsession.windowManager.i3`; add Alacritty, dmenu, dex, xss-lock, i3lock, NetworkManager applet, PulseAudio client tools, and procps to Home Manager packages. Define startup entries for dex, xss-lock+i3lock, and nm-applet with absolute package paths.

- [ ] **Step 5: Declare the current i3 behavior**

Set Mod4, DejaVu Sans Mono size 8, four-pixel inner/outer gaps, Alacritty terminal, dmenu launcher, top bar with primary tray and i3status command, current focus/movement/layout/workspace bindings, multimedia `pactl` bindings with i3status refresh, and the current resize mode including `j/k/l/semicolon`, arrow keys, Return, Escape, and Mod4+r.

- [ ] **Step 6: Declare i3status**

Enable `programs.i3status` with defaults disabled; set colors true and interval 1; define only `memory`, `load`, and `tztime local` at positions 1, 2, and 3, with local time format `%Y-%m-%d %H:%M:%S`.

- [ ] **Step 7: Verify generated configuration and WSL isolation**

Build or evaluate the laptop Home Manager activation package so Home Manager's built-in `i3 -C` validation runs. Inspect the generated i3 and i3status files for gaps, Mod4 bindings, all ten workspaces, top/primary bar, absolute dependency paths, and the exact three status blocks. Evaluate all profiles and assert i3/i3status are true only for laptop and desktop; search WSL packages for `i3`, `i3status`, `alacritty`, `dmenu`, `tuigreet`, and `pipewire` and expect no graphical additions from this task.

- [ ] **Step 8: Commit the declarative desktop configuration**

```bash
git add flake.nix home/graphical.nix home/programs/i3/default.nix
git -c user.name='lyashenko.ivan' -c user.email='ivan.lyashenko.it@gmail.com' commit -m "feat: manage i3 desktop with home manager"
```

### Task 4: Document future hosts and verify the complete laptop closure

**Files:**
- Modify: `hosts/README.md`

**Interfaces:**
- Consumes: the completed laptop profile and existing `wsl`, `laptop`, and `desktop` flake attributes.
- Produces: operator instructions for current deployment, future machine onboarding, test activation, persistent activation, and rollback.

- [ ] **Step 1: Write the deployment and future-host instructions**

Document the current laptop build command, `nixos-rebuild test`, post-test checks, `switch`, and `switch --rollback`. For a future machine, require a newly generated, uniquely named hardware module; a host module importing it; a unique flake attribute; preservation of that installation's original state version; build/test before switch; and no copied UUIDs, password hashes, or unencrypted secrets.

- [ ] **Step 2: Check the documentation safety contract**

Search `hosts/README.md` for `nixos-generate-config`, `hardware-configuration`, `stateVersion`, `nixos-rebuild test`, `nixos-rebuild switch`, `--rollback`, and a warning not to copy UUIDs. Confirm the future-machine example does not contain any current UUID.

- [ ] **Step 3: Run static and evaluation checks**

Run `nix-shell --run 'nixfmt --check <changed Nix files>'`, `nix-shell --run 'statix check'`, `nix --extra-experimental-features 'nix-command flakes' flake show`, targeted evaluations for all Review Focus assertions, and `git diff --check`.

Expected: all commands pass. `nix flake check --no-build` may still reject the intentionally hardware-free desktop profile; if so, record that exact known boundary rather than adding fabricated desktop disks or a bootloader.

- [ ] **Step 4: Build the complete laptop system**

```bash
nixos-rebuild build --flake .#laptop --option extra-experimental-features 'nix-command flakes'
```

Expected: exit 0 and a `result` symlink to a complete NixOS system closure. Inspect its evaluated configuration for the current filesystems, systemd-boot, greetd command, startx, PipeWire, user, locale, XKB, fonts, and Home Manager activation.

- [ ] **Step 5: Commit documentation**

```bash
git add hosts/README.md
git -c user.name='lyashenko.ivan' -c user.email='ivan.lyashenko.it@gmail.com' commit -m "docs: explain laptop deployment and host onboarding"
```

- [ ] **Step 6: Test-activate with interactive sudo**

Run `sudo nixos-rebuild test --flake .#laptop --option extra-experimental-features 'nix-command flakes'`. Do not log out or restart greetd during this step. Verify `systemctl is-system-running`, NetworkManager, the `itterum` account, greetd's unit definition, the generated tuigreet command, and PipeWire user-unit availability.

Expected: the test generation activates without breaking the running graphical session or network. If sudo cannot be entered interactively, stop and give the user this exact command plus the verification checklist.

- [ ] **Step 7: Persist only after successful test activation**

Run `sudo nixos-rebuild switch --flake .#laptop --option extra-experimental-features 'nix-command flakes'`, then confirm the current generation and `display-manager.service` point to the intended laptop/greetd configuration. Do not reboot automatically; explain that the new tuigreet login is observed on the next logout or reboot and include the rollback command.
