import
  std / [
    os,
    strformat
  ]

import
  constants,
  input,
  logging,
  screen

from config import globalConfig


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
    debug("Moving cursor to screen...")
    var x, y: int
    # Center-right quarter of the screen so we aren't on top of buttons when navigating interfaces
    x = (globalConfig.screenConfig[0] + ((globalConfig.screenConfig[2] / 2) * 1.5).int)
    y = (globalConfig.screenConfig[1] + (globalConfig.screenConfig[3] / 2).int)
    moveMouseAbs(x, y)
    sleep(UINPUTTIMEOUT)

proc equipRod(): void =
  moveCursorToScreen()
  debug("Equipping rod...")
  pressNum(globalConfig.rodSlot, ANIMATIONEQUIPITEM)

proc equipSoda(): void =
  moveCursorToScreen()
  debug("Equiping soda...")
  pressNum(globalConfig.sodaSlot, ANIMATIONEQUIPITEM)

proc equipPhone(): void =
  moveCursorToScreen()
  debug("Equiping phone...")
  pressNum(globalConfig.phoneSlot, ANIMATIONEQUIPITEM)

proc doCatchMenu*(): bool =
  moveCursorToScreen()
  debug("Doing catch menu...")
  var catchMenuAttempts: int = 1
  while not getCatchMenu():
    catchMenuAttempts += 1
    if catchMenuAttempts > 20:
      notice("No catch detected.")
      return false
    sleep(ANIMATIONMENUDELAY)

  info("Nice catch!")
  while getCatchMenu():
    pressMouse(UINPUTTIME)
    sleep(ANIMATIONMENUDELAY)
  sleep(ANIMATIONCATCHMENU - ANIMATIONMENUCLOSE)
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
    while not getFishingGame():
      sleep(UINPUTTIME)
    pressMouse()
    while getFishingGame():
      sleep(UINPUTTIME)
    releaseMouse()
  else:
    while getFishingGame():
      pressMouse(UINPUTTIME)
  sleep(ANIMATIONCATCHFISH)

proc doBucket*(): void =
  info("Doing bucket task...")
  moveCursorToScreen()
  pressInteract(UINPUTTIME)

proc doSoda*(): void =
  info("Drinking soda...")
  moveCursorToScreen()
  # Select soda
  equipSoda()
  # Use soda
  pressMouse(ANIMATIONDRINKSODA)
  # Select rod
  equipRod()

proc shopBait(num: int): void =
  debug(fmt"Shopping for bait {num}...")
  let
    # Add additional X distance based on the selected bait multiplier
    baitShopWormX: int = (globalConfig.screenConfig[0] + BAITSHOPWORM[0])
    baitShopWormY: int = (globalConfig.screenConfig[1] + BAITSHOPWORM[1])
  moveMouseAbs(baitShopWormX, baitShopWormY)
  if num > 0:
    moveMouseRel(((num - 1) * BAITSHOPPIXELSHOPDISTANCE), 0)
    pressMouse(UINPUTTIME)
  else:
    for i in 1..7:
      pressMouse(UINPUTTIME)
      moveMouseRel(BAITSHOPPIXELSHOPDISTANCE, 0)

proc selectBait(num: int): void =
  debug(fmt"Selecting bait {num}...")
  let
    baitSelectWormX: int = (globalConfig.screenConfig[0] + BAITSELECTWORM[0])
    # Add additional Y distance based on the selected bait multiplier
    baitSelectWormY: int = (globalConfig.screenConfig[1] + BAITSELECTWORM[1])
  moveMouseAbs(baitSelectWormX, baitSelectWormY)
  if num > 0:
    moveMouseRel(0, ((num - 1) * BAITSELECTPIXELDISTANCE))
    pressMouse(UINPUTTIME)
  else:
    # Not really smart but it should result in the best bait being selected
    for i in 1..7:
      pressMouse(UINPUTTIME)
      moveMouseRel(0, BAITSELECTPIXELDISTANCE)

proc shopBaitMenu(): void =
  debug("Doing bait shop menu...")
  var baitMenuAttempts: int = 1
  while not getBaitShop():
    baitMenuAttempts += 1
    if baitMenuAttempts > 20:
      error("Could not detect bait shop. Skipping...")
      return
    sleep(ANIMATIONMENUDELAY)
  baitMenuAttempts = 0
  # Buy bait
  shopBait(globalConfig.bait)
  # Wait for shop to close
  pressInteract(UINPUTTIME)
  while getBaitShop():
    baitMenuAttempts += 1
    if baitMenuAttempts > 20:
      error("Bait shop not closing. Retrying...")
      pressInteract(UINPUTTIME)
    sleep(ANIMATIONMENUDELAY)
  sleep(ANIMATIONMENUCLOSE)

proc selectBaitMenu(): void =
  debug("Doing bait select menu")
  var baitMenuAttempts: int = 1
  # Wait for select to open
  while not getBaitSelect():
    baitMenuAttempts += 1
    if baitMenuAttempts > 20:
      error("Could not detect bait select. Skipping...")
      return
    sleep(ANIMATIONMENUDELAY)
  baitMenuAttempts = 0
  # Select bait
  selectBait(globalConfig.bait)
  # Wait for select to close
  pressBaitSelect(UINPUTTIME)
  while getBaitSelect():
    baitMenuAttempts += 1
    if baitMenuAttempts > 20:
      error("Bait select not closing. Retrying...")
      pressInteract(UINPUTTIME)
    sleep(ANIMATIONMENUDELAY)
  sleep(ANIMATIONMENUCLOSE)

proc doShop*(): void =
  info("Buying and selecting bait...")
  moveCursorToScreen()
  # Select phone
  equipPhone()
  # Use phone
  pressMouse(ANIMATIONMENUDELAY)
  # Buy bait
  pressInteract(UINPUTTIME)
  shopBaitMenu()
  # Select bait
  pressBaitSelect(UINPUTTIME)
  selectBaitMenu()
  # Select rod
  equipRod()    

proc doReset*(): void =
  warn("Attempting reset...")

