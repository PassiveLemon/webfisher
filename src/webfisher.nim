import
  os

import
  webfisher / [
    config,
    functions
  ]

# import
#   x11/xlib,
#   libevdev

let
  # Config file should be overridable from CLI. Don't forget CLI --help
  configFilePath: string = getConfigDir() / "/webfisher/config.json"


block webfisher:
  let config: configType = initConfig(configFilePath)
