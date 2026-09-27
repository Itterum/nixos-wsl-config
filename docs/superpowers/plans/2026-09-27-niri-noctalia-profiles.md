# Профили i3 и Niri с Noctalia — план настройки

**Цель:** На графических хостах запускать i3 или Niri с Noctalia и выбирать сессию на экране входа.

**Подход:** Общие службы графической системы остаются в общем модуле. i3 и Niri описываются отдельными системными и Home Manager модулями, но оба профиля доступны на одном хосте. Noctalia Greeter заменяет текущий greetd/tuigreet и показывает доступные сессии.

**Технологии:** NixOS unstable, flakes, Home Manager, Niri, Noctalia Shell, Noctalia Greeter, greetd.

**Исходный контекст:** существующие `flake.nix`, `nixos/system/graphical.nix`, `home/graphical.nix` и `home/programs/i3/default.nix`.

## Ограничения

- WSL не должен получать графические пакеты и профили.
- На графических хостах должны быть доступны обе сессии: i3 и Niri.
- greeter должен быть ровно один; удалить запуск `tuigreet --cmd startx` при переходе на Noctalia Greeter.
- Noctalia Shell должна запускаться только в Niri-сессии.
- Не менять `system.stateVersion` и `home.stateVersion`.

## Обратить внимание при проверке

- WSL случайно импортирует графические пакеты из общего `home/home.nix`: вынести их в графический профиль и проверить `nixosConfigurations.wsl`.
- Greeter не показывает i3 или Niri: убедиться, что системные desktop session-файлы установлены и команда сессии запускается.
- i3 через greetd не должен зависеть от безусловного `startx` в default session.
- Niri должен иметь рабочие portal, Polkit, NetworkManager и графический стек.
- Shell может стартовать в обеих сессиях или не стартовать в Niri: ограничить автозапуск модулем Niri и использовать актуальную команду `noctalia`.

## Файлы и роли

- `flake.nix` — добавить вход Noctalia для Home Manager-модуля и импортировать нужные профильные модули в графические хосты.
- `nixos/system/graphical.nix` — оставить общие службы, greeter и пользователя; убрать жёстко заданный запуск X через tuigreet.
- `nixos/profiles/i3.nix` — X-сессия i3, нужные параметры X11.
- `nixos/profiles/niri.nix` — включить Niri и необходимые системные настройки Wayland.
- `home/home.nix` — общие пользовательские программы, без графических приложений и конфигураций сессий.
- `home/graphical.nix` — только пакеты и настройки, общие для графической сессии.
- `home/profiles/i3.nix` — импорт текущего `home/programs/i3`.
- `home/profiles/niri.nix` — Noctalia Home Manager-модуль, настройки оболочки и её запуск из Niri.
- `hosts/laptop.nix`, `hosts/desktop.nix` — импортировать оба системных профиля и общий графический модуль.

---

### Этап 1: Разнести общие и графические пакеты

- [ ] Переместить `brave`, `zed-editor`, `keepassxc` из `home/home.nix` в графический Home Manager-модуль, чтобы они не устанавливались на WSL.
- [ ] Создать `home/profiles/i3.nix` и перенести туда импорт `home/programs/i3` из общего `home/graphical.nix`.
- [ ] Проверить, что `home/home.nix` импортируется WSL и не включает пакеты i3 или GUI-приложения.

Проверка: просмотреть итоговые импорты `wsl`, `laptop`, `desktop`; убедиться, что графические HM-модули подключены только к laptop и desktop.

### Этап 2: Ввести два системных профиля

- [ ] Создать `nixos/profiles/i3.nix`, перенеся туда `services.xserver.enable`, `services.xserver.windowManager.i3.enable` и связанные сессией параметры из графического модуля.
- [ ] Создать `nixos/profiles/niri.nix` с `programs.niri.enable = true` и системными параметрами, необходимыми Niri.
- [ ] Оставить в `nixos/system/graphical.nix` общие аудио-службы, portal, сеть, пользователя и настройки greeter.
- [ ] Подключить оба профиля к `laptop` и `desktop`, не подключая их к WSL.

Проверка: NixOS-модули laptop и desktop содержат обе сессии; WSL не импортирует ни один из профилей.

### Этап 3: Подключить Noctalia Shell к Niri

- [ ] Добавить официальный input `noctalia` в `flake.nix`, связав его `nixpkgs` с основным input через `follows`.
- [ ] Создать `home/profiles/niri.nix`, импортировать `noctalia.homeModules.default` и включить `programs.noctalia`.
- [ ] Настроить Niri так, чтобы Noctalia запускалась при старте только Niri-сессии. Для актуальной Noctalia v5 команда автозапуска Niri — `spawn-at-startup "noctalia"`.
- [ ] Добавить минимальные клавиши для запуска лаунчера и блокировки экрана после запуска оболочки.
- [ ] Подключить оба HM-профиля i3 и Niri к графическим хостам.

Проверка: Noctalia запускается в Niri, не запускается в i3; настройки Niri не подменяют конфигурацию i3.

### Этап 4: Переключить greetd на Noctalia Greeter

- [ ] Проверить наличие модуля `services.displayManager.noctalia-greeter` в используемом Nixpkgs unstable.
- [ ] Включить модуль Noctalia Greeter и задать его базовые настройки.
- [ ] Удалить конфигурацию `services.greetd` с `tuigreet --cmd ...startx`, чтобы не было двух greeter-конфигураций и принудительного выбора i3.
- [ ] Убедиться, что в системных сессиях доступны Wayland-сессия Niri и X-сессия i3.

Проверка: dry-run сборки показывает одну службу greeter; после применения экран входа предлагает обе сессии и запоминает выбор.

### Этап 5: Проверить переключение и восстановление

- [ ] Проверить вычисление конфигураций: `nix flake check --no-build`.
- [ ] Проверить сборку без активации: `nix build .#nixosConfigurations.laptop.config.system.build.toplevel --dry-run` и аналогичную цель для desktop.
- [ ] Применять изменения сначала на одном графическом хосте, сохранив доступ к TTY и предыдущую генерацию NixOS.
- [ ] В Noctalia Greeter отдельно войти в i3, затем выйти и войти в Niri.
- [ ] Для Niri проверить экран, ввод, звук, сеть, portal, блокировку и работу Noctalia; затем перезагрузиться и убедиться, что обе сессии всё ещё доступны.
- [ ] Проверить возврат через предыдущую генерацию NixOS, если greeter или одна из сессий не запускается.

Проверка: laptop и desktop предлагают обе сессии; WSL собирается без GUI-компонентов; возврат к предыдущей генерации доступен.
