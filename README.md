# webfisher
A Nim based fishing script for Webfishing

> [!CAUTION]
> I am not responsible for any bans or data loss as a result of using this. This was a project for me to learn Nim. If you have any concerns, don't use it and be a legitimate player :)

# Dependencies
- Linux. <b>This is not supported on Windows or MacOS.</b>
- X11. This is not supported on Wayland.
- A user in the "input" group or sudo privileges.
- Nimble packages: `x11`

# Usage
### Nix:
- You can get the package in my [flake repository](https://github.com/PassiveLemon/lemonake).
### Source:
- Clone the repo, cd to src
- Run `nim c -r webfisher`
- Edit the generated config file in your `~/.config/webfisher/config.json`. You can also supply a config file with `-f <path to config.json`.
  - Arguments can be found by tacking `-h` or `--help`

In order to use this script, you must enable the built-in autoclicker in the Webfishing main settings.

# Configuration (config.json)
| Setting | Default | Details |
| :- | :- | :- |
| castOnStart | `false` (Boolean) | Whether to cast the rod upon starting the script. When set to `false`, this will not do anything until the rod is cast and the fishing task is detected. |
| castTime | `1.0` (Float) | How long to cast the rod (in seconds). |
| checkInterval | `0.25` (Float) | How often to check for visual input (in seconds). |

# TODO
- [ ] Timestamps
- [ ] Verbose and quiet output
- [ ] parse test constJson
- [ ] Periodic sodas (Player config for slot)
- [ ] Auto shop (Needs cursor movement)

