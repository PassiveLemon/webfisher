# webfisher
A Nim based fishing script for Webfishing

> [!CAUTION]
> I am not responsible for any bans or data loss as a result of using this. This was a project for me to learn Nim. If you have any concerns, don't use it and be a legitimate player :)

# Dependencies
- Linux. <b>This is not supported on Windows or MacOS.</b>
- X11. This is not supported on Wayland.
- A user in the "input" group or sudo privileges.
- Nimble packages: `x11` and [`libevdev`](https://github.com/PassiveLemon/libevdev-nim)

# Usage
### Nix:
- You can get the package in my [flake repository](https://github.com/PassiveLemon/lemonake).
### Source:
- Clone the repo, cd to src
- Run `nim c -r webfisher`
- Edit the generated config file in your `~/.config/webfisher/config.json`. You can also supply a config file with `-f <path to config.json`.
  - Arguments can be found by tacking `-h` or `--help`

> [!IMPORTANT]
> You will likely need to configure the `screenConfig` configuration option (see below). This is only tested on a screen resolution of 1920x1080. Other resolutions probably do not work.

> [!IMPORTANT]
> In order to use the bucket functionality, your interact key must be `E` (default).

# Configuration (config.json)
| Setting | Default | Details |
| :- | :- | :- |
| bucketTime | `30.0` (Float) | How long (in seconds) to wait between bucket task attempts. |
| castOnStart | `false` (Boolean) | Whether to cast the rod upon starting the script. When set to `false`, nothing happens until the first fishing task is detected. |
| castTime | `1.0` (Float) | How long (in seconds) to cast the rod. |
| checkInterval | `0.25` (Float) | How often (in seconds) to check for visual input. |
| holdToFish | `false` (Boolean) | Whether to hold to fish by using the built-in autoclicker (Make sure to enable this before setting to `true`). When set to `false`, it will rapidly click until completed. |
| resetTime | `120.0` (Float) | How long (in seconds) since the last catch to wait before attempting to reset. This helps resynchronize the loop if something is missed. |
| screenConfig | `[ 0, 0, 1920, 1080 ]` (List of 4 integers) | Config to control the screen capture. This spans across all displays. The first 2 elements are the starting X and Y value of the screen. The last 2 elements are the width and height of the screen. For example: If you have 2 side-by-side 1080p displays and you launch the game on the right, your config would be `[ 1920, 0, 1920, 1080 ]`. |

# TODO
- Periodic sodas (Player config for slot) - Do not soda unless a fish has recently been caught so we dont waste sodas on nothing.
- Auto shop (Needs cursor movement)
- Timestamps
- Verbose and quiet output
- parse test constJson

