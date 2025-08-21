import std/os

import winim

import
  ../constants,
  ../logging

from ../config import globalConfig


proc initDevice*(): void =
  return

proc cleanupDevice*(): void =
  return

proc manageKey(key: int16, state: DWORD): void =
  var input: INPUT
  input.type = INPUT_KEYBOARD
  input.ki.wVk = key.WORD
  input.ki.dwFlags = state
  discard SendInput(1, addr input, sizeof(input).int32)
  sleep(uinputTimeout)

proc pressKey(key: int16): void =
  manageKey(key, 0)

proc releaseKey(key: int16): void =
  manageKey(key, KEYEVENTF_KEYUP)

proc pressInteract*(time: int): void =
  pressKey(0x45) # E
  sleep(time)
  releaseKey(0x45)

proc pressBaitSelect*(time: int): void =
  pressKey(0x42) # B
  sleep(time)
  releaseKey(0x42)

proc pressNum*(num: int, time: int): void =
  let numVk = (0x30 + num).int16
  pressKey(numVk)
  sleep(time)
  releaseKey(numVk)

proc manageMouse(state: DWORD): void =
  var input: INPUT
  input.type = INPUT_MOUSE
  input.mi.dwFlags = state
  discard SendInput(1, addr input, sizeof(input).int32)
  sleep(uinputTimeout)

proc pressMouse*(): void =
  manageMouse(MOUSEEVENTF_LEFTDOWN)

proc releaseMouse*(): void =
  manageMouse(MOUSEEVENTF_LEFTUP)

proc pressMouse*(time: int): void =
  pressMouse()
  sleep(time)
  releaseMouse()

proc moveMouseAbs*(x, y: int): void =
  var input: INPUT
  input.type = INPUT_MOUSE
  input.mi.dx = ((x * 65535) div (globalConfig.screenConfig[2] - 1)).LONG
  input.mi.dy = ((y * 65535) div (globalConfig.screenConfig[3] - 1)).LONG
  input.mi.dwFlags = MOUSEEVENTF_MOVE or MOUSEEVENTF_ABSOLUTE
  discard SendInput(1, addr input, sizeof(INPUT).int32)
  sleep(uinputTimeout)

proc moveMouseRel*(x, y: int): void =
  var input: INPUT
  input.type = INPUT_MOUSE
  input.mi.dx = x.LONG
  input.mi.dy = y.LONG
  input.mi.dwFlags = MOUSEEVENTF_MOVE
  discard SendInput(1, addr input, sizeof(INPUT).int32)
  sleep(uinputTimeout)

