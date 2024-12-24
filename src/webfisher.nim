import
  std/os

import
  webfisher / [
    config,
    pixel
  ]

import
  x11/xlib


type
  GlobalState* = object
    fishingGameActive: bool
    bucketGameActive: bool
    comboGameActive: bool

var globalState*: GlobalState

block webfisher:
  let
    config: Config = initConfig()
    display: PDisplay = XOpenDisplay(nil)

  echo config
  echo "Config loaded."

  while true:
    echo "Simulated main loop"
    if getFishingGame(display):
      echo "Fishing game found"
    sleep((config.checkInterval * 1000).int)

  discard XCloseDisplay(display)

