import
  std/os

import
  ./constants,
  ./input,
  ./logging,
  ./screen

from ./config import globalConfig


proc cleanup() {.noconv.} =
  debug("Cleaning up evdev device...")
  cleanupDevice()
  debug("Cleaning up x11 display...")
  cleanupDisplay()
  notice("Exiting...")
  quit(0)

setControlCHook(cleanup)

proc moveCursorToScreen(): void =
  if globalConfig.moveCursor:
    var x, y: int
    # Center-right quarter of the screen so we aren't on top of buttons when navigating interfaces
    x = (globalConfig.screenConfig[0] + ((globalConfig.screenConfig[2] / 2) * 1.5).int)
    y = (globalConfig.screenConfig[1] + (globalConfig.screenConfig[3] / 2).int)
    moveMouseAbs(x, y)
    sleep(uinputTimeout)

proc equipRod(): void =
  moveCursorToScreen()
  pressNum(globalConfig.rodSlot, animationEquipItem)

proc equipSoda(): void =
  moveCursorToScreen()
  pressNum(globalConfig.sodaSlot, animationEquipItem)

proc equipPhone(): void =
  moveCursorToScreen()
  pressNum(globalConfig.phoneSlot, animationEquipItem)

proc doCatchMenu*(): bool =
  moveCursorToScreen()
  var catchMenuAttempts: int = 1
  while not getCatchMenu():
    catchMenuAttempts += 1
    if catchMenuAttempts > 20:
      notice("No catch detected.")
      return false
    sleep(animationMenuDelay)

  info("Nice catch!")
  while getCatchMenu():
    pressMouse(uinputTime)
    sleep(animationMenuDelay)
  sleep(animationCatchMenu - animationMenuClose)
  return true

proc castLine*(): void =
  info("Casting line...")
  moveCursorToScreen()
  equipRod()
  pressMouse(globalConfig.castTime.int)

proc doFish*(): void =
  info("Doing fishing task...")
  moveCursorToScreen()
  if globalConfig.holdToFish:
    while getFishingGame():
      pressMouse()
      sleep(animationMenuDelay)
    releaseMouse()
  else:
    while getFishingGame():
      pressMouse(uinputTime)
  sleep(animationCatchFish)

proc doBucket*(): void =
  info("Doing bucket task...")
  moveCursorToScreen()
  pressInteract(uinputTime)

proc doSoda*(): void =
  info("Drinking soda...")
  moveCursorToScreen()
  # Select soda
  equipSoda()
  # Use soda
  pressMouse(animationDrinkSoda)
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

proc shopBaitMenu(): void =
  var baitMenuAttempts: int = 1
  while not getBaitShop():
    baitMenuAttempts += 1
    if baitMenuAttempts > 20:
      error("Could not detect bait shop. Skipping...")
      return
    sleep(animationMenuDelay)
  baitMenuAttempts = 0
  # Buy bait
  shopBait(globalConfig.bait)
  # Wait for shop to close
  pressInteract(uinputTime)
  while getBaitShop():
    baitMenuAttempts += 1
    if baitMenuAttempts > 20:
      error("Bait shop not closing. Retrying...")
      pressInteract(uinputTime)
    sleep(animationMenuDelay)
  sleep(animationMenuClose)

proc selectBaitMenu(): void =
  var baitMenuAttempts: int = 1
  # Wait for select to open
  while not getBaitSelect():
    baitMenuAttempts += 1
    if baitMenuAttempts > 20:
      error("Could not detect bait select. Skipping...")
      return
    sleep(animationMenuDelay)
  baitMenuAttempts = 0
  # Select baitb11
  selectBait(globalConfig.bait)
  # Wait for select to close
  pressBaitSelect(uinputTime)
  while getBaitSelect():
    baitMenuAttempts += 1
    if baitMenuAttempts > 20:
      error("Bait select not closing. Retrying...")
      pressInteract(uinputTime)
    sleep(animationMenuDelay)
  sleep(animationMenuClose)

proc doShop*(): void =
  info("Buying and selecting bait...")
  moveCursorToScreen()
  # Select phone
  equipPhone()
  # Use phone
  pressMouse(animationMenuDelay)
  # Buy bait
  pressInteract(uinputTime)
  shopBaitMenu()
  # Select bait
  pressBaitSelect(uinputTime)
  selectBaitMenu()
  # Select rod
  equipRod()    

proc doReset*(): void =
  warn("Attempting reset...")

