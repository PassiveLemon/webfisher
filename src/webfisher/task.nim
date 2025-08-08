import
  std/os

import
  ./constants,
  ./evdev,
  ./logging,
  ./screen

from ./config import globalConfig


proc cleanup() {.noconv.} =
  notice("Cleaning up evdev device...")
  cleanupDevice()
  notice("Cleaning up x11 display...")
  cleanupDisplay()
  notice("Exiting...")
  quit(0)

setControlCHook(cleanup)

proc moveCursorToScreen(): void =
  if globalConfig.moveCursor:
    var x, y: int
    # Center of the intended screen
    x = (globalConfig.screenConfig[0] + (globalConfig.screenConfig[2] / 2).int)
    y = (globalConfig.screenConfig[1] + (globalConfig.screenConfig[3] / 2).int)
    moveMouseAbs(x, y)
    sleep(uinputTimeout)

proc equipRod(): void =
  moveCursorToScreen()
  pressNum(globalConfig.rodSlot, uinputTime)
  sleep(animationEquipItem)

proc equipSoda(): void =
  moveCursorToScreen()
  pressNum(globalConfig.sodaSlot, uinputTime)
  sleep(animationEquipItem)

proc equipPhone(): void =
  moveCursorToScreen()
  pressNum(globalConfig.phoneSlot, uinputTime)
  sleep(animationEquipItem)

proc doCatchMenu*(): bool =
  moveCursorToScreen()
  sleep(animationCatchMenu)
  if getCatchMenu():
    info("Nice catch!")
    while getCatchMenu():
      pressMouse(uinputTime)
      sleep(animationMenuTimeout)
    sleep(animationCatchMenu - animationMenuClose)
    return true
  else:
    notice("No catch detected.")
    return false

proc castLine*(): void =
  moveCursorToScreen()
  equipRod()
  pressMouse(globalConfig.castTime.int)

proc doFish*(): void =
  moveCursorToScreen()
  if globalConfig.holdToFish:
    while getFishingGame():
      pressMouse()
      sleep(animationMenuTimeout)
    releaseMouse()
  else:
    while getFishingGame():
      pressMouse(uinputTime)
  sleep(animationCatchFish)

proc doBucket*(): void =
  moveCursorToScreen()
  pressInteract(uinputTime)

proc doSoda*(): void =
  moveCursorToScreen()
  # Select soda
  equipSoda()
  # Use soda
  pressMouse(uinputTime)
  sleep(animationDrinkSoda)
  # Select rod
  equipRod()

proc shopBait(num: int): void =
  let
    # Add additional X distance based on the selected bait multiplier
    baitShopWormX: int = (globalConfig.screenConfig[0] + baitShopWorm[0])
    baitShopWormY: int = (globalConfig.screenConfig[1] + baitShopWorm[1])
  moveMouseAbs(baitShopWormX, baitShopWormY)
  if num > 0:
    moveMouseRel(((num - 1) * baitShopPixelDistance), 0)
    pressMouse(uinputTime)
  else:
    for i in 1..7:
      pressMouse(uinputTime)
      moveMouseRel(baitShopPixelDistance, 0)

proc selectBait(num: int): void =
  let
    baitSelectWormX: int = (globalConfig.screenConfig[0] + baitSelectWorm[0])
    # Add additional Y distance based on the selected bait multiplier
    baitSelectWormY: int = (globalConfig.screenConfig[1] + baitSelectWorm[1])
  moveMouseAbs(baitSelectWormX, baitSelectWormY)
  if num > 0:
    moveMouseRel(0, ((num - 1) * baitSelectPixelDistance))
    pressMouse(uinputTime)
  else:
    # Not really smart but it should result in the best bait being selected
    for i in 1..7:
      pressMouse(uinputTime)
      moveMouseRel(0, baitSelectPixelDistance)

proc doShop*(): void =
  moveCursorToScreen()
  # Select phone
  equipPhone()
  # Use phone
  pressMouse(uinputTime)
  sleep(animationMenuTimeout)
  # Open shop
  pressInteract(uinputTime)
  sleep(animationBaitShop)
  # Buy bait
  shopBait(globalConfig.bait)
  # Close shop
  pressInteract(uinputTime)
  sleep(animationBaitShop - animationMenuClose)
  # Open bait
  pressBaitSelect(uinputTime)
  sleep(animationBaitSelect)
  # Select bait
  selectBait(globalConfig.bait)
  # Close bait
  pressBaitSelect(uinputTime)
  sleep(animationBaitSelect - animationMenuClose)
  # Select rod
  equipRod()

