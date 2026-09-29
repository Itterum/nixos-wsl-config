# Конфигурация NixOS

Flake построен по схеме `flake-parts` и `import-tree` из
[статьи Vimjoyer](https://www.vimjoyer.com/vid79-parts-wrapped). Есть два хоста:
`wsl` и `pc`.

- `modules/hosts/wsl` — NixOS-WSL.
- `modules/hosts/pc` — NVIDIA, Niri и Noctalia.
- `modules/features` — общие модули и обёртка Niri.
- `nixos/system` и `home` — существующие системные и Home Manager настройки.

Для Noctalia используется версия 5.2.0 и её официальный модуль Home Manager.
Обёртка `noctalia-shell` из статьи относится к старой версии 4.

## Аппаратная конфигурация PC

Перед сборкой `pc` заполни `modules/hosts/pc/hardware.nix` настройками,
полученными на этом компьютере. Сохрани внешнее определение
`flake.nixosModules.pcHardware = ...`, а внутрь помести параметры из
`hardware-configuration.nix`. Также настрой загрузчик под реальный диск.
Сейчас у `pc` нет корневой файловой системы и загрузчика, поэтому полная
сборка ожидаемо не проходит. Старые UUID дисков VMware здесь неприменимы.

После добавления аппаратных настроек:

```sh
nix flake check --no-build
sudo nixos-rebuild switch --flake .#pc
```

Для WSL:

```sh
sudo nixos-rebuild switch --flake .#wsl
```
