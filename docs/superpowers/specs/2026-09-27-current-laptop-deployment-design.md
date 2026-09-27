# Current laptop deployment design

## Goal

Make `nixosConfigurations.laptop` buildable and safely deployable on the
current NixOS 26.05 VMware machine. Preserve the machine's working graphical
environment and document a repeatable process for adding future physical or
virtual laptop machines without reusing machine-specific disk identifiers.

## Current state

- The current host is a VMware virtual machine, not WSL.
- It boots with systemd-boot from EFI and uses Btrfs for `/`, `/home`, and
  `/nix`, with a separate swap device.
- `/etc/nixos/hardware-configuration.nix` contains the current machine's disk
  UUIDs and initrd modules.
- The active configuration provides LightDM, i3, automatic login for
  `itterum`, `us,ru` XKB layouts, fonts, and several i3 support packages. The
  new profile intentionally replaces LightDM and automatic login with an
  authenticated `tuigreet` login.
- The repository's `laptop` profile already provides LightDM, i3,
  NetworkManager, Home Manager, Brave, Zed, KeePassXC, and Flatpak.
- `nixos-rebuild build --flake .#laptop` fails because the profile has neither
  a root filesystem nor a bootloader definition.
- Flake commands currently require command-line experimental-feature flags
  because the active system does not enable `nix-command` and `flakes`.

## Design

### Module boundaries

Create `hosts/laptop-hardware.nix` from the current machine's generated
`/etc/nixos/hardware-configuration.nix`. This module owns only facts tied to
this installation: initrd kernel modules, filesystem and swap devices, disk
UUIDs, filesystem types, mount options, and `nixpkgs.hostPlatform`.

Import that module from `hosts/laptop.nix`. The laptop host module owns the
hostname and current-machine policy that is not useful to every graphical
host: systemd-boot, EFI variable access, time zone, locale, XKB layout, and
the current hardware import. The reusable `nixos/system/graphical.nix` module
continues to own graphical services, login, audio, and applications shared by
laptop and desktop.

Keep the existing `desktop` profile free of the laptop's filesystem,
bootloader, and hardware settings. Keep the `wsl` profile free of all
physical-machine boot, filesystem, login-manager, and audio settings.

### Login and graphical session

Replace LightDM with `greetd` and the `tuigreet` text interface. Do not define
an `initial_session`; the user must authenticate in `tuigreet`. Configure
`tuigreet` to start the NixOS `startx` entry point. Enable generation of the
system-wide xinit script so the X server starts the configured i3 session and
the corresponding systemd user graphical target.

Use absolute Nix store paths for `tuigreet` and other commands composed by Nix
modules. Keep the i3 session selection unambiguous: the graphical module
enables one X11 window manager, i3. The activation checks must verify that
LightDM and display-manager auto-login are disabled and that greetd is the
active display-manager service.

### Audio

Use PipeWire as the graphical profiles' audio server, with WirePlumber session
management, ALSA support, and PulseAudio compatibility. Enable RTKit for
real-time scheduling. Do not enable the legacy PulseAudio daemon.

Retain `pactl`-based i3 volume and mute bindings through PipeWire's PulseAudio
compatibility layer. Provide `pactl` from the relevant package explicitly so
the bindings do not depend on an undeclared executable.

### Declarative i3 and i3status

Create a focused Home Manager module under `home/programs/i3/` and import it
from a new `home/graphical.nix` entry point. Extend the flake host constructor
so `home/graphical.nix` is included only for laptop and desktop; keep
`home/home.nix` as the CLI-only module used by every profile. Manage both
`~/.config/i3/config` and `~/.config/i3status/config` through structured Home
Manager options instead of copying the generated files verbatim.

Preserve the current i3 behavior: four-pixel inner and outer gaps, Mod4,
DejaVu Sans Mono 8, focus and movement bindings, ten numbered workspaces,
layout controls, resize mode, top i3bar, primary tray, Alacritty terminal, and
dmenu launcher. Preserve the current i3status one-second refresh interval and
its memory, load, and local timestamp blocks.

Declare every command referenced by the i3 configuration. This includes
Alacritty, dmenu, dex, xss-lock, i3lock, the NetworkManager applet, `pactl`,
and the process utility used to signal i3status. Compose command strings from
package paths where Home Manager supports it. Remove generated comments and
inactive example bindings that do not affect behavior.

### Preserved user experience

Preserve the current machine's:

- `Europe/Chisinau` time zone and `en_US.UTF-8` locale;
- `us,ru` XKB layout with `grp:shifts_toggle,ctrl:nocaps`;
- JetBrains Mono Nerd Font, Inter, and Roboto font packages and defaults;
- i3 support utilities `dmenu`, `i3status`, `i3lock`, and `i3blocks`;
- existing repository applications and Home Manager configuration.

The approved exception is login behavior: replace LightDM automatic login
with password authentication through `tuigreet`.

Do not automatically retain every package from `/etc/nixos/configuration.nix`.
The repository's existing choices remain authoritative where they overlap:
Brave replaces the current collection of Chromium and qutebrowser, and Helix
continues to be managed through Home Manager. Add only missing utilities that
are required to preserve the graphical session described above.

### Nix interface

Enable `nix-command` and `flakes` declaratively in the shared NixOS
configuration so future rebuild commands do not require temporary command-line
flags. This applies to all profiles and does not change their package or
graphical boundaries.

### Validation and activation

Before activating the profile:

1. Format and statically inspect the changed Nix files.
2. Evaluate all three flake configurations to catch cross-profile regressions.
3. Build `.#nixosConfigurations.laptop.config.system.build.toplevel` without
   changing the running system.
4. Compare the evaluated laptop boot, filesystems, user, locale, XKB, display
   manager, audio, network, and Home Manager settings with the design.
5. Run `sudo nixos-rebuild test --flake .#laptop` only after the build passes.
6. Verify the greetd service, `tuigreet` command, generated startx session,
   PipeWire user units, NetworkManager, user account, and expected
   configuration values in the test generation. Do not terminate the current
   graphical session merely to test the new greeter.
7. Run `sudo nixos-rebuild switch --flake .#laptop` after the test activation
   succeeds. A reboot is not part of the initial deployment.

Because sudo on this machine requires interactive authentication, commands
that need sudo may require the user to enter their password in the shared
terminal. If interactive elevation is unavailable, stop after the verified
build and provide the exact `test` and `switch` commands.

### Future-machine workflow

Extend `hosts/README.md` with instructions for future machines:

1. Install or boot NixOS on the target machine and generate its hardware
   configuration with `nixos-generate-config`.
2. Store the generated hardware module under a unique host-specific name;
   never copy disk, filesystem, or swap UUIDs from another host.
3. Add a small host module containing its hostname and machine policy, then
   import the generated hardware module and the reusable graphical module.
4. Expose a uniquely named `nixosConfigurations` attribute in `flake.nix`.
5. Evaluate and build that exact attribute before using `test` and `switch`.
6. Keep secrets and password hashes out of the repository unless encrypted
   secret management is added later.
7. Retain the original `system.stateVersion` from the target installation.

The documentation will also include rollback commands and distinguish
temporary `test` activation from persistent `switch` activation.

## Error handling and recovery

- Never activate a profile that failed evaluation or build.
- Retain the current bootable generation; do not delete old generations during
  this work.
- If `nixos-rebuild test` disrupts the graphical session or networking, reboot
  to return to the last persistent generation or select it from the boot menu.
- If a later persistent generation fails, use the previous boot-menu entry or
  `sudo nixos-rebuild switch --rollback`.
- Treat hardware UUIDs and bootloader settings as immutable machine facts
  unless a disk layout change is explicitly intended.

## Success criteria

- `nixos-rebuild build --flake .#laptop` succeeds on the current repository.
- The laptop closure contains the current machine's root, home, nix, boot, and
  swap declarations and uses systemd-boot.
- The laptop preserves the agreed locale, keyboard, fonts, i3 utilities,
  shared applications, and Home Manager environment.
- The laptop and desktop use greetd with authenticated tuigreet login and use
  PipeWire with ALSA and PulseAudio compatibility; LightDM and the legacy
  PulseAudio daemon are disabled.
- i3 and i3status reproduce the current bindings, workspaces, bar, and status
  blocks from declarative Home Manager options, with all commands available.
- WSL does not receive graphical, audio, login-manager, bootloader, or disk
  settings.
- Desktop does not receive this laptop's hardware module.
- Flake commands work without per-command experimental-feature flags after
  activation.
- The repository documents safe onboarding, testing, switching, and rollback
  for future machines.
