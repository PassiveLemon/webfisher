import std/strformat

import winim

import
  ../constants,
  ../logging

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
  debug("Getting screenshot...")
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
  debug(fmt"Pixel r {pixel.r} g {pixel.g} b {pixel.b}")
  return pixel

proc checkPixels(pixelSeq: PixelSeq; pixelList: PixelList; count: int): bool =
  var valid = 0
  for checkPixel in pixelList:
    let pixel = getPixelColor(pixelSeq, checkPixel.x, checkPixel.y)
    debug(fmt"checkPixel r {checkPixel.r} g {checkPixel.g} b {checkPixel.b}")
    if pixel.r.int == checkPixel.r and
        pixel.g.int == checkPixel.g and
        pixel.b.int == checkPixel.b:
      # We test if most of the pixels match since the reel could block the pixel
      valid += 1
      debug(fmt"Pixel match, valid +1 {valid}")
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

