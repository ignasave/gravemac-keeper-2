#!/bin/zsh
# GraveMac Keeper 2: run the Windows build of Graveyard Keeper 2 on macOS
# via Wine + Apple D3DMetal (Game Porting Toolkit). Bring your own Steam copy.
# usage: gk2.sh setup | import | run | app | steam-setup | steam
set -euo pipefail

APPID=4358690 DEPOT=4358691
HERE="${0:A:h}"
export WINEPREFIX="${GK2_PREFIX:-$HOME/Games/gk2-prefix}"
export WINEESYNC=1 WINEMSYNC=1 WINEDEBUG=-all
WINE="/Applications/Game Porting Toolkit.app/Contents/Resources/wine/bin/wine64"
GAME="$WINEPREFIX/drive_c/GK2"
DEPOT_DIR="$HOME/Library/Application Support/Steam/Steam.AppBundle/Steam/Contents/MacOS/steamapps/content/app_$APPID/depot_$DEPOT"
STEAM='C:\Program Files (x86)\Steam\steam.exe'
APP="$HOME/Applications/Graveyard Keeper 2.app"

# Wine is x86_64; macOS updates can remove Rosetta ("bad CPU type in executable")
rosetta() { arch -x86_64 /usr/bin/true 2>/dev/null || softwareupdate --install-rosetta --agree-to-license; }

case "${1:-run}" in
  setup)
    rosetta
    brew trust gcenx/wine 2>/dev/null || true   # only on newer Homebrew
    brew install --cask gcenx/wine/game-porting-toolkit
    mkdir -p "$WINEPREFIX"
    "$WINE" wineboot -i
    "$0" app
    echo "Next: in Mac Steam run 'steam://open/console', type: download_depot $APPID $DEPOT"
    echo "      when it says 'Depot download complete', run: $0 import"
    ;;
  import)
    # moves the depot (1.5 GB, same disk) instead of copying; re-run after each game update
    [[ -d "$DEPOT_DIR" ]] || { echo "No download at: $DEPOT_DIR" >&2; exit 1; }
    mkdir -p "$GAME"
    rsync -a --remove-source-files "$DEPOT_DIR/" "$GAME/"
    rm -rf "$DEPOT_DIR"
    echo $APPID > "$GAME/steam_appid.txt"
    echo "Imported. Open $APP"
    ;;
  run)
    [[ -f "$GAME/GraveyardKeeper2.exe" ]] || { echo "Game not imported, see: $0 import" >&2; exit 1; }
    rosetta
    # optional Windows Steam (cloud saves/achievements); game runs without it
    if [[ -f "$WINEPREFIX/drive_c/Program Files (x86)/Steam/steam.exe" ]] && ! pgrep -qf 'Steam\\steam.exe'; then
      "$WINE" "$STEAM" -cef-disable-gpu-compositing -silent & sleep 15
    fi
    cd "$GAME" && exec "$WINE" GraveyardKeeper2.exe
    ;;
  app)
    mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
    cp "$0" "$APP/Contents/MacOS/gk2.sh"
    [[ -f "$HERE/assets/icon.icns" ]] && cp "$HERE/assets/icon.icns" "$APP/Contents/Resources/icon.icns"
    printf '#!/bin/zsh\nexec "${0:h}/gk2.sh" run\n' > "$APP/Contents/MacOS/launch"
    chmod +x "$APP/Contents/MacOS/"*
    cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>Graveyard Keeper 2</string>
  <key>CFBundleIdentifier</key><string>local.gravemac-keeper-2</string>
  <key>CFBundleExecutable</key><string>launch</string>
  <key>CFBundleIconFile</key><string>icon</string>
  <key>CFBundlePackageType</key><string>APPL</string>
</dict></plist>
EOF
    touch "$APP"   # make Finder pick up the new icon
    ;;
  steam-setup)
    curl -fL -o "$WINEPREFIX/drive_c/SteamSetup.exe" \
      https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe
    "$WINE" 'C:\SteamSetup.exe' /S
    ;;
  steam) exec "$WINE" "$STEAM" -cef-disable-gpu-compositing ;;
  *) echo "usage: $0 setup|import|run|app|steam-setup|steam" >&2; exit 1 ;;
esac
