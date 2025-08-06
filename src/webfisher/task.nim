import
  std/os

import
  ./evdev,
  ./screen

import
  libevdev,
  linux/input

from ./config import globalConfig


proc cleanup() {.noconv.} =
  echo "Cleaning up..."
  cleanupDisplay()
  cleanupDevice()
  quit(0)

setControlCHook(cleanup)

proc moveCursorToScreen*(): void =
  if globalConfig.moveCursor:
    var x, y: int
    x = (globalConfig.screenConfig[0] + (globalConfig.screenConfig[2] / 2).int)
    y = (globalConfig.screenConfig[1] + (globalConfig.screenConfig[3] / 2).int)
    moveMouseAbs(x, y)

proc doCatchMenu*(): bool =
  moveCursorToScreen()
  if getCatchMenu():
    echo "Nice catch!"
    while getCatchMenu():
      pressMouse(20)
      sleep(500)
    return true
  else:
    echo "No catch detected."
    return false

proc castLine*(): void =
  moveCursorToScreen()
  pressMouse(globalConfig.castTime)

proc doFish*(): void =
  moveCursorToScreen()
  if globalConfig.holdToFish:
    while getFishingGame():
      pressMouse()
      sleep(500)
    releaseMouse()
  else:
    while getFishingGame():
      pressMouse(20)

proc doBucket*(): void =
  moveCursorToScreen()
  pressInteract(20)

proc doSoda*(): void =
  moveCursorToScreen()
  pressNum(globalConfig.sodaSlot, 20)
  sleep(1500)
  pressMouse(20)
  sleep(2500)
  pressNum(globalConfig.rodSlot, 20)
  sleep(1500)

