import winim

import ../constants

from ../config import globalConfig


type
  Pixel = object
    b, g, r, a: byte
  PixelSeq = seq[Pixel]


proc initDisplay*(): void =
  return

proc cleanupDisplay*(): void =
  return

proc getScreenshot(): PixelSeq =
  let
    hDesktop = GetDesktopWindow()
    hDC = GetDC(hDesktop)
    hMem = CreateCompatibleDC(hDC)
    hBmp = CreateCompatibleBitmap(hDC, globalConfig.screenConfig[2].int32, globalConfig.screenConfig[3].int32)
    oldBmp = SelectObject(hMem, hBmp)

  discard BitBlt(hMem,
    0, 0,
    globalConfig.screenConfig[2].int32, globalConfig.screenConfig[3].int32,
    hDC,
    globalConfig.screenConfig[0].int32, globalConfig.screenConfig[1].int32,
    SRCCOPY)

  var bi: BITMAPINFO
  bi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER).DWORD
  bi.bmiHeader.biWidth = globalConfig.screenConfig[2].LONG
  bi.bmiHeader.biHeight = -globalConfig.screenConfig[3].LONG
  bi.bmiHeader.biPlanes = 1
  bi.bmiHeader.biBitCount = 32
  bi.bmiHeader.biCompression = BI_RGB
  bi.bmiHeader.biSizeImage = (globalConfig.screenConfig[2] * globalConfig.screenConfig[3] * 4).DWORD

  var pixels = newSeq[Pixel](globalConfig.screenConfig[2] * globalConfig.screenConfig[3])
  discard GetDIBits(hMem, hBmp, 0, globalConfig.screenConfig[3].UINT, unsafeAddr pixels[0], addr bi, DIB_RGB_COLORS)

  discard SelectObject(hMem, oldBmp)
  DeleteObject(hBmp)
  DeleteDC(hMem)
  ReleaseDC(hDesktop, hDC)

  return pixels

proc getPixelColor(pixelSeq: PixelSeq; x: int; y: int): Pixel =
  let
    # We start at red in the r, g, b, a sequence
    pixelIndex: int = (y * globalConfig.screenConfig[2] + x)
  var pixel: Pixel
  pixel.r = pixelSeq[pixelIndex].r
  pixel.g = pixelSeq[pixelIndex].g
  pixel.b = pixelSeq[pixelIndex].b
  return pixel

proc checkPixels(pixelSeq: PixelSeq; pixelList: PixelList; count: int): bool =
  var valid = 0
  for checkPixel in pixelList:
    let pixel = getPixelColor(pixelSeq, checkPixel.x, checkPixel.y)
    if pixel.r.int == checkPixel.r and
        pixel.g.int == checkPixel.g and
        pixel.b.int == checkPixel.b:
      # We test if most of the pixels match since the reel could block the pixel
      valid += 1
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