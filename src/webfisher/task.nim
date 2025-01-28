import
  std/os

import
  ./evdev,
  ./screen

from ./config import globalConfig


proc cleanup() {.noconv.} =
  echo "Cleaning up..."
  cleanupDisplay()
  cleanupDevice()
  quit(0)

setControlCHook(cleanup)

proc doCatchMenu*(): void =
  if getCatchMenu():
    echo "Nice catch!"
    while getCatchMenu():
      pressMouse(20)
      sleep(500)
  else:
    echo "No catch detected."

proc castLine*(): void =
  pressMouse(globalConfig.castTime)

proc doFish*(): void =
  if globalConfig.holdToFish:
    while getFishingGame():
      pressMouse()
      sleep(500)
    releaseMouse()
  else:
    while getFishingGame():
      pressMouse(20)

proc doBucket*(): void =
  pressKey(20)

proc resetClick*(): void =
  pressMouse(20)

