import
  std/os

import
  ./evdev,
  ./screen


proc cleanup() {.noconv.} =
  echo "Cleaning up..."
  cleanupDisplay()
  cleanupDevice()
  quit(0)

setControlCHook(cleanup)

proc resetClick*(): void =
  pressMouse(20)

proc castLine*(castTime: float): void =
  pressMouse(castTime * 1000)

proc doFish*(): void =
  while getFishingGame():
    pressMouse()
    sleep(500)
  releaseMouse()

proc doBucket*(): void =
  pressKey(20)

proc clickCatchMenu*(): void =
  pressMouse(20)
  sleep(1000)
  pressMouse(20)

