import
  x11 / [
    x,
    xlib,
    xutil
  ]

import ./constants

from ./config import globalConfig


type
  Pixel* = object
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

proc getFishingGame*(): bool =
  let screenshot = getScreenshot()
  var valid = 0

  for reelPixel in fishingReelPixels:
    let pixel = getPixelColor(screenshot, reelPixel.x, reelPixel.y)
    if pixel.r == reelPixel.r and
        pixel.g == reelPixel.g and
        pixel.b == reelPixel.b:
      # We test if at least 3 of the pixels match since the reel could block the pixel
      valid += 1
  discard XDestroyImage(screenshot)
  if valid >= 3:
    return true
  else:
    return false

proc getCatchMenu*(): bool =
  let screenshot = getScreenshot()
  var valid = 0

  for menuPixel in catchMenuPixels:
    let pixel = getPixelColor(screenshot, menuPixel.x, menuPixel.y)
    if pixel.r == menuPixel.r and
        pixel.g == menuPixel.g and
        pixel.b == menuPixel.b:
      valid += 1
  discard XDestroyImage(screenshot)
  if valid >= 3:
    return true
  else:
    return false

