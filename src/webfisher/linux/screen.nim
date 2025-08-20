import
  x11 / [
    x,
    xlib,
    xutil
  ]

import ../constants

from ../config import globalConfig


type
  Pixel = object
    color*: culong
    r*, g*, b*: int


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
  webfisherDisplay = XOpenDisplay(nil)

proc cleanupDisplay*(): void =
  discard XCloseDisplay(webfisherDisplay)

proc getScreenshot(): PXImage =
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
  var pixel: Pixel
  pixel.color = XGetPixel(screenshot, x.cint, y.cint)
  pixel.r = ((pixel.color shr 16) and 0xFF).int
  pixel.g = ((pixel.color shr 8) and 0xFF).int
  pixel.b = (pixel.color and 0xFF).int
  return pixel

proc checkPixels(screenshot: PXImage, pixelList: PixelList, count: int): bool =
  var valid = 0
  for checkPixel in pixelList:
    let pixel = getPixelColor(screenshot, checkPixel.x, checkPixel.y)
    if pixel.r == checkPixel.r and
        pixel.g == checkPixel.g and
        pixel.b == checkPixel.b:
      # We test if at least 3 of the pixels match since the reel could block the pixel
      valid += 1
  discard XDestroyImage(screenshot)
  if valid >= count:
    return true
  else:
    return false

proc getFishingGame*(): bool =
  let screenshot = getScreenshot()
  return checkPixels(screenshot, fishingReelPixels, 3)

proc getCatchMenu*(): bool =
  let screenshot = getScreenshot()
  return checkPixels(screenshot, catchMenuPixels, 3)

proc getEmptyBait*(): bool =
  let screenshot = getScreenshot()
  return checkPixels(screenshot, emptyBaitPixels, 2)

proc getBaitShop*(): bool =
  let screenshot = getScreenshot()
  return checkPixels(screenshot, baitShopPixels, 3)

proc getBaitSelect*(): bool =
  let screenshot = getScreenshot()
  return checkPixels(screenshot, baitSelectPixels, 3)

