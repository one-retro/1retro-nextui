# 1Retro Sync for NextUI

Sync your game saves with the [1Retro](https://1retro.com) cloud, right from
your TrimUI Brick or Smart Pro running
[NextUI](https://nextui.loveretro.games), or a handheld running
[MinUI](https://github.com/shauninman/MinUI).

Play on your handheld, pick up on MiSTer, RetroArch, OpenEmu, or any other
device 1Retro supports. Your saves follow you.

## Install

The easiest way is the **Pak Store** on your device: Tools, Pak Store, then
find "1Retro Sync".

Manual install: download `1Retro.Sync.pak.zip` from the
[latest release](https://github.com/one-retro/1retro-nextui/releases/latest),
create a folder called `1Retro Sync.pak` inside `Tools/tg5040/` on your SD
card (use your device's platform folder), and unzip the contents into it.

## MinUI devices (Anbernic RG35XX Plus/H, RG40XX H/V, CubeXX)

The pak also runs on upstream [MinUI](https://github.com/shauninman/MinUI)'s
`rg35xxplus` platform, which covers those Anbernic devices. There is no Pak
Store on MinUI, so install manually into `Tools/rg35xxplus/1Retro Sync.pak/`.
You will also need Wi-Fi, which stock MinUI does not manage; install
[minui-wifi-pak](https://github.com/josegonzalez/minui-wifi-pak) first and
connect to your network.

## First run

1. Connect your device to Wi-Fi.
2. Launch **1Retro Sync** from the Tools menu.
3. Scan the QR code with your phone (or visit `1retro.com/device` and enter
   the device ID) and confirm with the code shown on screen.
4. Done. Every launch after that opens the menu with **Sync saves** already
   highlighted, so a sync is one button press.

A free [1retro.com](https://1retro.com) account is all you need.

## The menu

Launching the pak once it is linked shows two actions, with the account it is
signed in as, when it last synced, and how many saves it is tracking listed
underneath:

- **Sync saves**: upload what changed on this device, download what changed
  elsewhere. The screen shows what it is doing as it goes.
- **Watch for saves**: keep syncing in the background after you leave this
  app. Saves upload as your emulator writes them, and anything you saved on
  another device comes down. Press it to turn it on or off. Watching uses
  extra battery and only works on Wi-Fi.
- **Start watching at boot**: pick up watching again after the device
  restarts.
- **Sign out**: forget the login on this device. You will need to link it
  again to sync.

**B** leaves the menu, and backs out of the pairing screen too.

Watching at boot adds one guarded line to `.userdata/<platform>/auto.sh`, the
script MinUI runs at boot, and takes it back out when you turn the option off.
Opening this app pauses the background sync while you use it, and starts it
again when you leave.

## What it syncs

In-game saves (battery saves) from your `Saves/` folder, for every system
NextUI ships with plus common emulator paks (GB, GBC, GBA, NES, SNES,
Genesis, PlayStation, PC Engine, Game Gear, and more). Save states are not
synced.

## What is in this repo

| Path | What it is |
| ---- | ---------- |
| `pak/launch.sh` | The pak's entry point: picks the architecture, sets up `PATH`, runs the app |
| `pak/bin/on-boot` | Starts the background watcher at boot, when that option is on |
| `pak/minui.lock` | The versions and SHA-256s of the bundled minui-presenter and minui-list |
| `pak.json` | The Pak Store manifest, read from this repo's root |
| `scripts/pin-minui.sh` | Rewrites the lock, for upgrading those two helpers |
| `.github/workflows/pak.yml` | Assembles the pak zip and attaches it to each release |

The pak bundles [minui-presenter](https://github.com/josegonzalez/minui-presenter)
and [minui-list](https://github.com/josegonzalez/minui-list) rather than
depending on them being installed. They are fetched at build time at the
versions in `pak/minui.lock` and checked against the SHA-256s there, so a moved
tag or a re-uploaded asset cannot change what ships to a device without showing
up as a diff here first.

The `1retro-nextui` binary is built from the 1Retro source tree (arm64 and arm,
static musl) and attached to each release here, where the workflow picks it up.

## License

The contents of this repository are [MIT](LICENSE) licensed. The
`1retro-nextui` binary inside the released pak is not open source, and is
distributed for use with a 1Retro account. The pak also bundles
[minui-presenter](https://github.com/josegonzalez/minui-presenter) and
[minui-list](https://github.com/josegonzalez/minui-list), both MIT.

## Support

Bug reports and questions are welcome here or on our
[Discord](https://discord.gg/vYKSvqVkdE).
