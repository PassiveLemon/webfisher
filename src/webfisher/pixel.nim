import
  ./config

import
  x11/xlib,
  x11/xutil,
  x11/x


type
  Pixel* = object
    color*: culong
    r*, g*, b*: int

  PixelList = seq[tuple[x, y, r, g, b: int]]


const# 428, 745
  fishingGamePixels: PixelList = @[(428, 785, 156, 145, 74), (388, 745, 156, 145, 74), (428, 705, 156, 145, 74), (468, 745, 156, 145, 74)]


# saveToPPM: https://github.com/nim-lang/x11/blob/29aca5e519ebf5d833f63a6a2769e62ec7bfb83a/examples/xshmex.nim#L40
proc saveToPPM(image: PXImage, filePath: string) =
  var f = open(filePath, fmWrite)
  defer: f.close
  writeLine(f, "P6")
  writeLine(f, image.width, " ", image.height)
  writeLine(f, 255)
  for i in 0..<(image.width * image.height):
    f.write(image.data[i * 4 + 2])
    f.write(image.data[i * 4 + 1])
    f.write(image.data[i * 4 + 0])

proc getScreenshot(display: PDisplay): PXImage =
  return XGetImage(display, RootWindow(display, DefaultScreen(display)), 1920, 0, 1920, 1080, AllPlanes, ZPixmap)

proc getPixelColor(display: PDisplay, image: PXImage, x: int, y: int): Pixel =
  var pixel: Pixel

  pixel.color = XGetPixel(image, x.cint, y.cint)
  # Could not figure out how to use this
  #discard XQueryColor(display, DefaultColormap(display, Defaultscreen(display)), pixelX)
  pixel.r = ((pixel.color shr 16) and 0xFF).int
  pixel.g = ((pixel.color shr 8) and 0xFF).int
  pixel.b = (pixel.color and 0xFF).int
  
  return pixel

proc getFishingGame*(display: PDisplay): bool =
  let screenshot: PXImage = getScreenshot(display)
  var yes1, yes2, yes3: bool = false
    
  # screenshot.saveToPPM("./screenshot.ppm")
  for gamePixel in fishingGamePixels:
    let pixel: Pixel = getPixelColor(display, screenshot, gamePixel.x, gamePixel.y)
    #echo pixel
    #echo gamePixel
    if
      pixel.r == gamePixel.r and
      pixel.g == gamePixel.g and
      pixel.b == gamePixel.b:

      if not yes1:
        yes1 = true
      elif not yes2:
        yes2 = true
      else:
        yes3 = true

  if yes1 and yes2 and yes3:
    return true
  else:
    return false
  
  discard XDestroyImage(screenshot)

