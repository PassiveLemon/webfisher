# webfisher
A Nim based fishing script Webfishing </br>

3 settings:
- Fishing: Detect when the rod comes up and then complete the game.
  - Configurable throw length/time.
  - Make sure to incrementally reel in the rod to increase catch rate.
  - If it's been over a minute with no detection, LMB once (Should help recover if any weird states occur).
- Bucketing: Periodically collect the buckets. Smart and dumb mode:
  - Smart should use pixel detection.
  - Dumb can just press e every 3 seconds or something.
- Combined: Fish while periodically collecting buckets.

General:
Use pixel detections

Other:
Parse test the configJson constant

> [!CAUTION]
> I am not responsible for any bans or data loss as a result of using this. This was a project for me to learn Nim. If you are worried about getting banned, don't use it and be a legitimate player :) </br>

# Dependencies
- Linux. <b>This is not supported on Windows or MacOS.</b>
- X11. This is not tested on Wayland so I cannot ensure compatibility.
- Sudo. This requires access to input devices.
- Nim packages: `libevdev, x11`

# Usage
### Nix:
- You can get the package in my [flake repository](https://github.com/PassiveLemon/lemonake). </br>
### Source:
- Clone the repo, cd to src
- Run `nim c -r webfisher`
- Edit the generated config file in your `~/.config/webfisher/config.json`. You can also supply a config file with `-f <path to config.json`. Please read the configuration below, you need to configure the file to enable functionality. </br>
  - Arguments can be found by tacking `-h` or `--help`

# Configuration (config.json)

