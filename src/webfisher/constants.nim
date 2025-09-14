type
  PixelList* = seq[tuple[x, y, r, g, b: int]]
  CursorPos* = tuple[x, y: int]


const
  RELEASEVERSION* = "1.3.2"

  FISHINGREELPIXELS*: PixelList = @[
    (428, 785, 156, 145, 74),
    (388, 745, 156, 145, 74), 
    (428, 705, 156, 145, 74),
    (468, 745, 156, 145, 74)
  ]
  CATCHMENUPIXELS*: PixelList = @[
    (320, 800, 90, 117, 90),
    (1500, 850, 255, 238, 213), 
    (1500, 950, 255, 238, 213), 
    (400, 950, 255, 238, 213)
  ]
  EMPTYBAITPIXELS*: PixelList = @[
    (1853, 1033, 16, 28, 49),
    (1845, 1025, 16, 28, 49),
    (1838, 1017, 16, 28, 49)
  ]
  BAITSHOPPIXELS*: PixelList = @[
    (192, 157, 90, 117, 90),
    (1161, 157, 90, 117, 90), 
    (1135, 900, 255, 238, 213), 
    (210, 900, 255, 238, 213)
  ]
  BAITSELECTPIXELS*: PixelList = @[
    (400, 350, 255, 238, 213),
    (1515, 350, 90, 117, 90), 
    (1521, 741, 255, 238, 213), 
    (397, 741, 255, 238, 213)
  ]

  # We only use the worms as the start since we then just move the cursor by known a known pixel distance to hit the other baits
  BAITSHOPWORM*: CursorPos = (280, 370)
  BAITSHOPPIXELSHOPDISTANCE*: int = 107
  BAITSELECTWORM*: CursorPos = (566, 495)
  BAITSELECTPIXELDISTANCE*: int = 38

  ANIMATIONCATCHFISH*: int = 2000
  ANIMATIONCATCHMENU*: int = 1250
  ANIMATIONEQUIPITEM*: int = 1250
  ANIMATIONDRINKSODA*: int = 1750

  ANIMATIONMENUDELAY*: int = 250
  ANIMATIONMENUCLOSE*: int = 500

  UINPUTTIMEOUT*: int = 10
  UINPUTTIME*: int = 20

