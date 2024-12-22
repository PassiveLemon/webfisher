# import
#   std/os

import
  webfisher / [
    config,
    functions
  ]

# import
#   x11/xlib,
#   libevdev


block webfisher:
  let config: configType = initConfig()
  echo config

