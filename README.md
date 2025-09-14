# webfisher
A Nim based fishing script for Webfishing, supporting Linux and Windows.

Features:
- Fishing and reeling
- Bucket collection
- UI navigation
- Automatic bait shopping and selection
- Smart soda use, will only be used when a fish has recently been caught
- Various configurable options in the config file

> [!CAUTION]
> I am not responsible for any bans or data loss as a result of using this. This was a project for me to learn Nim. If you have any concerns, don't use it and be a legitimate player :)

> [!NOTE]
> Windows Defender and other anti-virus/anti-cheat software may flag this as malware and stop it or block functionality. This is likely because Webfisher takes screenshots, controls your mouse and can send keyboard inputs. If you have any doubt, all of the source code and build process is accessible.

# Dependencies
- Linux:
  - X11, Wayland is not supported.
  - A user in the "input" group or sudo privileges.
  - Nimble packages: `x11` and [`libevdev`](https://github.com/PassiveLemon/libevdev-nim)
- Windows:
  - Nimble packages: `winim`

# Usage
### Nix:
- You can get the package in my [flake repository](https://github.com/PassiveLemon/lemonake).
### Linux:
- Download the binary from [releases](https://github.com/PassiveLemon/webfisher/releases/latest) (The one without an extension).
### Windows:
- Download the executable from [releases](https://github.com/PassiveLemon/webfisher/releases/latest).
### Source:
- Clone the repo, cd to src
- Run `nim c -r webfisher`
- Edit the generated config file in your `~/.config/webfisher/config.json` (Linux), or `~\Appdata\Roaming\webfisher\config.json` (Windows).
- If you run Webfisher from the CLI, you can also supply a config file with `-f="<path to config.json>"`.
  - Arguments can be found by tacking `-h` or `--help`

Upon start, Webfisher will wait 5 seconds before attempting to do anything, so use this time to get Webfishing and your cursor situated.

If you are using Webfisher for the first time, it will create a default config file and quit. Please configure this config file before running it again as it does control your mouse and send keyboard inputs. Details [below](https://github.com/PassiveLemon/webfisher?tab=readme-ov-file#configuration-configjson).

> [!IMPORTANT]
> You will likely need to configure the `screenConfig` configuration option (see below). This is only tested on a screen resolution of 1920x1080. Other resolutions probably do not work. Also, Webfisher takes screenshots of the entire display, so any desktop popups that cover necessary pixels (bait count, fishing reel, and menus) may cause problems.

> [!IMPORTANT]
> Your interact key MUST be `E` (default), and your bait menu key MUST be `B` (default).

By default, Webfisher assumes your fishing rod is in slot 1, phones are in slot 4, and soda is in slot 5. Configure accordingly.

While enabled, autoShop will replenish empty bait whenever possible, but autoSoda will only attempt to use soda when a fish has recently been caught.

When using autoSoda, make sure to:
- Stock up on soda if you plan to leave it running for a while
- Configure your soda slot (5 by default) and rod slot (1 by default)

When using autoShop, make sure to:
- Stock up on phones if you plan to leave it running for a while, especially with the golden hook
- Use fish mode only as the buckets can get in the way of the interaction
- Stand far enough from the water to where the shop will actually deploy
- Increase your castTime to account for the extra standing distance
- Configure your phone slot (4 by default) and rod slot (1 by default)

# Configuration (config.json)
The intended way to currently configure Webfisher is by the config.json. CLI configuration is planned.

The slot related options go up to 10 for players that use mods for additional slots.

| Setting | Default | Details |
| :- | :- | :- |
| autoShop | `false` (Boolean) | Whether to enable automatic bait shopping. |
| autoSoda | `false` (Boolean) | Whether to enable automatic sodas when fishing. |
| bait | `0` (Best) (Int 0-7) | The bait to buy and use. It starts with 0 to use the best bait, 1 for worms and increases by 1 for every bait, ending with 7 on gilded worms. Ignore if you are not using autoShop. |
| bucketTime | `30.0` (Float) | How long (in seconds) to wait between bucket task attempts. |
| castOnStart | `false` (Boolean) | Whether to cast the rod upon starting the script. When set to `false`, nothing happens until the first fishing task is detected. |
| castTime | `1.0` (Float) | How long (in seconds) to cast the rod. |
| checkInterval | `0.25` (Float) | How often (in seconds) to check for visual input. |
| holdToFish | `false` (Boolean) | Whether to hold to fish by using the built-in autoclicker (Make sure to enable this before setting to `true`). When set to `false`, it will rapidly click until completed. |
| moveCursor | `true` (Boolean) | Whether to move the cursor into the game window when inputs are needed. Helps make sure your cats didn't move your cursor off the game and then spam text everywhere... |
| phoneSlot | `4` (Int 1-10) | The slot in which the bait shop phone is held. Use a 10 instead of 0. |
| resetTime | `120.0` (Float) | How long (in seconds) since the last catch to wait before attempting to reset. This helps resynchronize the loop if something is missed. |
| rodSlot | `1` (Int 1-10) | The slot in which the primary fishing rod is held. Use a 10 instead of 0. |
| screenConfig | `[ 0, 0, 1920, 1080 ]` (List of 4 integers) | Config to control the screen capture. This spans across all displays. The first 2 elements are the starting X and Y value of the screen. The last 2 elements are the width and height of the screen. For example: If you have 2 side-by-side 1080p displays and you launch the game on the right, your config would be `[ 1920, 0, 1920, 1080 ]`. |
| sodaSlot | `5` (Int 1-10) | The slot in which the primary soda is held. Use a 10 instead of 0. |

