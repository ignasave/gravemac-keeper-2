<p align="center"><img src="assets/icon.png" width="220" alt="GraveMac Keeper 2 icon"></p>

# GraveMac Keeper 2

Play **Graveyard Keeper 2** (Windows-only on Steam) on an Apple Silicon Mac.
One script wraps the Windows build in Wine + Apple's D3DMetal (Game Porting Toolkit)
and gives you a normal `Graveyard Keeper 2.app` in `~/Applications`.

> Unofficial fan wrapper. Not affiliated with Lazy Bear Games or tinyBuild.
> **You need to own the game on Steam.** This repo contains no game files.

**Tested on:** Apple Silicon (arm64), macOS 27, Game Porting Toolkit 3.0-3, GK2 depot manifest `8550693869351246529`.

**Community reports:**
- MacBook Pro M4 Pro: full evening of play, works perfectly, PS5 DualSense over USB works

## Requirements

- Apple Silicon Mac, macOS 14 (Sonoma) or newer
- [Homebrew](https://brew.sh)
- Graveyard Keeper 2 in your Steam library and ~3 GB free disk

## Install

```sh
git clone https://github.com/ignasave/gravemac-keeper-2 && cd gravemac-keeper-2
./gk2.sh setup
```

`setup` installs Rosetta 2, [Gcenx's Game Porting Toolkit build](https://github.com/Gcenx/game-porting-toolkit),
creates a Wine prefix in `~/Games/gk2-prefix` and builds the app.

Then download the Windows version through **Mac Steam** (it won't offer an Install button, this is the workaround):

1. Open the Steam console: `open steam://open/console`
2. Type `download_depot 4358690 4358691` and press Enter
3. Wait for `Depot download complete` (≈1.5 GB)
4. `./gk2.sh import`
5. Open **Graveyard Keeper 2** from `~/Applications`

**Game update?** Repeat steps 2–4.

## Bringing your Steam Cloud saves

The game runs without a Steam connection, so cloud saves don't sync automatically.

1. Go to <https://store.steampowered.com/account/remotestorageapp/?appid=4358690>
2. Download the `Steam_1.dat` / `.info` files (and backups if you want)
3. Put them in
   `~/Games/gk2-prefix/drive_c/users/crossover/AppData/LocalLow/Lazy Bear Games/Graveyard Keeper 2/`

Imported cloud saves load fine with **Continue**. Saves made on the Mac stay on the Mac
unless you set up Windows Steam (see below).

## Mods

The game loads mods from disk, no Steam needed:

```
~/Games/gk2-prefix/drive_c/users/crossover/AppData/LocalLow/Lazy Bear Games/Graveyard Keeper 2/Mods/
```

- Drop a mod folder there and press **Shift+F10** in-game to reload
- Prefix a folder name with `~` to disable it
- Currently the only category is `Languages/` (translations)

**Workshop items** without Windows Steam: in the Mac Steam console run
`workshop_download_item 4358690 <id>` (the id is the number at the end of the Workshop URL),
then copy `steamapps/workshop/content/4358690/<id>` from your Mac Steam folder into `Mods/`.

## Pre-order bonus, cloud sync, achievements (experimental)

These come from Steam itself, not from files. Out of the box the game can't reach Steam,
so `Player.log` (next to `Mods/`) shows `SteamAPI_Init() failed` and `[Preorder]: False`.

To try fixing that, run a Windows Steam inside the prefix:

```sh
./gk2.sh steam-setup   # one time, installs Windows Steam in the prefix
./gk2.sh steam         # log in once; it remembers you
```

After that, the app starts this Steam in the background before the game. If it works,
`[Preorder]` should flip to `True` and Workshop/cloud/achievements come with it.
**Unconfirmed:** the Windows Steam window may render black under Wine. Reports welcome.

## Commands

| Command | Does |
|---|---|
| `setup` | Rosetta, GPTK, Wine prefix, app bundle |
| `import` | Moves the Steam console download into the prefix |
| `run` | Launches the game (what the app does) |
| `app` | Rebuilds `~/Applications/Graveyard Keeper 2.app` |
| `steam-setup` / `steam` | Optional Windows Steam in the prefix |

Use a different prefix with `GK2_PREFIX=/path ./gk2.sh …`.

## Known issues / untested

- Intel Macs: untested (GPTK targets Apple Silicon)
- Windows Steam window may render black under Wine
- Controllers: PS5 DualSense over USB works (community report); Bluetooth and others untested
- Pre-order bonus / Steam features need the experimental Windows Steam setup above

## Uninstall

```sh
rm -rf ~/Games/gk2-prefix ~/Applications/"Graveyard Keeper 2.app"
brew uninstall --cask game-porting-toolkit
```

## Credits

Game and original icon art © Lazy Bear Games. `assets/icon.png` is the game's icon with the
skull swapped for a pixel rainbow Apple logo (`assets/make-icon.py`). Wine/GPTK packaging by [Gcenx](https://github.com/Gcenx).
