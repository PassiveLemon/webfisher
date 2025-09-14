import
  std/strformat,
  x11 / [
    x,
    xlib,
    xutil
  ]

import
  ../constants,
  ../logging

from ../config import globalConfig


type
  Pixel = object
    r, g, b: int


var webfisherDisplay: PDisplay

# saveToPPM: https://github.com/nim-lang/x11/blob/29aca5e519ebf5d833f63a6a2769e62ec7bfb83a/examples/xshmex.nim#L40
# Only here for testing
# proc saveToPPM(image: PXImage, filePath: string) =
#   var f = open(filePath, fmWrite)
#   defer: f.close
#   writeLine(f, "P6")
#   writeLine(f, image.width, " ", image.height)
#   writeLine(f, 255)
#   for i in 0..<(image.width * image.height):
#     f.write(image.data[i * 4 + 2])
#     f.write(image.data[i * 4 + 1])
#     f.write(image.data[i * 4 + 0])

proc initDisplay*(): void =
  debug("Attaching to display...")
  webfisherDisplay = XOpenDisplay(nil)

proc cleanupDisplay*(): void =
  debug("Detaching from display...")
  discard XCloseDisplay(webfisherDisplay)

proc getScreenshot(): PXImage =
  debug("Getting screenshot...")
  var screenshot = XGetImage(webfisherDisplay,
    RootWindow(webfisherDisplay, DefaultScreen(webfisherDisplay)),
    globalConfig.screenConfig[0].cint,
    globalConfig.screenConfig[1].cint,
    globalConfig.screenConfig[2].cuint,
    globalConfig.screenConfig[3].cuint,
    AllPlanes, ZPixmap)
  # screenshot.saveToPPM("./screenshot.ppm")
  return screenshot

proc getPixelColor(screenshot: PXImage; x: int; y: int): Pixel =
  let color = XGetPixel(screenshot, x.cint, y.cint)
  var pixel: Pixel
  pixel.r = ((color shr 16) and 0xFF).int
  pixel.g = ((color shr 8) and 0xFF).int
  pixel.b = (color and 0xFF).int
  return pixel

proc checkPixels(screenshot: PXImage, pixelList: PixelList, count: int): bool =
  var valid = 0
  for checkPixel in pixelList:
    let pixel = getPixelColor(screenshot, checkPixel.x, checkPixel.y)
    debug(fmt"Pixel check real:ideal | r {pixel.r}:{checkPixel.r} | g {pixel.g}:{checkPixel.g} | b {pixel.b}:{checkPixel.b}")
    if pixel.r == checkPixel.r and
        pixel.g == checkPixel.g and
        pixel.b == checkPixel.b:
      # We test if most of the pixels match since the reel could block the pixel
      valid += 1
      debug(fmt"Pixel match, valid +1 {valid}")
  discard XDestroyImage(screenshot)
  if valid >= count:
    return true
  else:
    return false

proc getFishingGame*(): bool =
  debug("Checking for fishing game...")
  let screenshot = getScreenshot()
  return checkPixels(screenshot, FISHINGREELPIXELS, 3)

proc getCatchMenu*(): bool =
  debug("Checking for catch menu...")
  let screenshot = getScreenshot()
  return checkPixels(screenshot, CATCHMENUPIXELS, 3)

proc getEmptyBait*(): bool =
  debug("Checking for empty bait...")
  let screenshot = getScreenshot()
  return checkPixels(screenshot, EMPTYBAITPIXELS, 2)

proc getBaitShop*(): bool =
  debug("Checking for bait shop...")
  let screenshot = getScreenshot()
  return checkPixels(screenshot, BAITSHOPPIXELS, 3)

proc getBaitSelect*(): bool =
  debug("Checking for bait select...")
  let screenshot = getScreenshot()
  return checkPixels(screenshot, BAITSELECTPIXELS, 3)

