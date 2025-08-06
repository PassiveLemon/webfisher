type
  PixelList* = seq[tuple[x, y, r, g, b: int]]
  CursorPos* = tuple[x, y: int]


const
  releaseVersion* = "1.0.0"

  fishingReelPixels*: PixelList = @[
    (428, 785, 156, 145, 74),
    (388, 745, 156, 145, 74), 
    (428, 705, 156, 145, 74),
    (468, 745, 156, 145, 74)
  ]
  catchMenuPixels*: PixelList = @[
    (320, 800, 90, 117, 90),
    (1500, 850, 255, 238, 213), 
    (1500, 950, 255, 238, 213), 
    (400, 950, 255, 238, 213)
  ]
  emptyBaitPixels*: PixelList = @[
    (1853, 1033, 16, 28, 49),
    (1845, 1025, 16, 28, 49),
    (1838, 1017, 16, 28, 49)
  ]

  # We only use the worms as the start since we then just move the cursor by known a known pixel distance to hit the other baits
  baitShopWorm*: CursorPos = (280, 370)
  baitShopPixelDistance*: int = 107

  baitSelectWorm*: CursorPos = (566, 495)
  baitSelectPixelDistance*: int = 38

  animationCatchFish*: int = 2000
  animationMenuTimeout*: int = 250
  animationCatchMenu*: int = 1250
  animationBaitShop*: int = 1250 # Needs a high delay because of a large lag spike when opening the shop
  animationBaitSelect*: int = 650
  animationEquipItem*: int = 1250
  animationDrinkSoda*: int = 1750

  animationMenuClose*: int = 500 # This is to cut the time on a closing animation because they do not take as long

  uinputTimeout*: int = 10
  uinputTime*: int = 20

