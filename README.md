# webfisher
A Nim based fishing script Webfishing

# TODO
- [x] Config loading
  - [x] Find the true user (The user running with sudo)
  - [x] Load config file
  - [x] Create config file
  - [x] Update config file
  - [ ] Hot-reloading (just internally restart the program)
- [x] CLI
  - [x] `-h | --help` (Print out other flags)
  - [x] `-v | --version`
  - [x] `-f | --file` (Config file to load)
  - [x] `-d | --device` (Device for input)
  - [x] mode argument (fish, bucket, or combo)
- [ ] Sensory
  - [ ] Capture screen and analyze pixels (X11 wrapper)
  - [ ] Receive/send keyboard inputs (libevdev wrapper)
- [ ] Fishing game
  - [ ] Casting/reeling
  - [ ] Game detection/completion
- [ ] Bucket game
  - [ ]? Smart mode (Pixel detections)
  - [ ] Dumb mode (Periodically press "e")
- [ ] Combined game (fishing and bucketting)
- [ ] Testing/ECC
  - [ ] Error check config
  - [ ] parse test constJson
- Other goals
  - [ ] Variable verbosity output

> [!CAUTION]
> I am not responsible for any bans or data loss as a result of using this. This was a project for me to learn Nim. If you are worried about getting banned, don't use it and be a legitimate player :)

# Dependencies
- Linux. <b>This is not supported on Windows or MacOS.</b>
- X11. This is not supported on Wayland.
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

