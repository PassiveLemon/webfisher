import
  std / [
    os,
    strformat
  ],
  x11 / [
    x,
    xlib
  ]

import ./constants

import
  libevdev,
  linux/input



var
  webfisherDevice: ptr libevdev_uinput
  webfisherDisplay: PDisplay


proc createDevice(): ptr libevdev_uinput =
  var
    evdev = libevdev_new()
    uinput: ptr libevdev_uinput

  libevdev_set_name(evdev, "Webfisher Input");
  discard libevdev_enable_property(evdev, INPUT_PROP_POINTER);

  discard libevdev_enable_event_type(evdev, EV_REL);
  discard libevdev_enable_event_code(evdev, EV_REL, REL_X, nil);
  discard libevdev_enable_event_code(evdev, EV_REL, REL_Y, nil);

  discard libevdev_enable_event_type(evdev, EV_KEY);
  discard libevdev_enable_event_code(evdev, EV_KEY, BTN_LEFT, nil);
  discard libevdev_enable_event_code(evdev, EV_KEY, KEY_E, nil);
  discard libevdev_enable_event_code(evdev, EV_KEY, KEY_B, nil);

  # The const for KEY_num is the number + 1. Ex: KEY_1 = 2
  for keyCode in 2..11:
    discard libevdev_enable_event_code(evdev, EV_KEY, keyCode.cuint, nil)

  let libevdevUinputRet = libevdev_uinput_create_from_device(evdev, LIBEVDEV_UINPUT_OPEN_MANAGED, addr uinput)
  if libevdevUinputRet < 0:
    echo fmt"Could not create libevdev uinput device: code {libevdevUinputRet}"
    quit(1)

  return uinput

proc initDevice*(): void =
  webfisherDevice = createDevice()
  webfisherDisplay = XOpenDisplay(nil)

proc cleanupDevice*(): void =
  libevdev_uinput_destroy(webfisherDevice)
  discard XCloseDisplay(webfisherDisplay)

proc manageKey(key: int, state: int): void =
  libevdev_uinput_write_event(webfisherDevice, EV_KEY, key, state)
  sleep(uinputTimeout) # Buffer time so listeners can see events more consistently
  libevdev_uinput_write_event(webfisherDevice, EV_SYN, SYN_REPORT, 0)
  sleep(uinputTimeout)

proc pressKey(key: int): void =
  manageKey(key, 1)

proc releaseKey(key: int): void =
  manageKey(key, 0)

proc pressInteract*(time: int): void =
  pressKey(KEY_E)
  sleep(time)
  releaseKey(KEY_E)

proc pressBaitSelect*(time: int): void =
  pressKey(KEY_B)
  sleep(time)
  releaseKey(KEY_B)

proc pressNum*(num: int, time: int): void =
  # The const for KEY_num is the number + 1. Ex: KEY_1 = 2
  # We also tell the user to use 10 instead of 0
  pressKey(num + 1)
  sleep(time)
  releaseKey(num + 1)

proc manageMouse(state: int): void =
  libevdev_uinput_write_event(webfisherDevice, EV_KEY, BTN_LEFT, state)
  sleep(uinputTimeout)
  libevdev_uinput_write_event(webfisherDevice, EV_SYN, SYN_REPORT, 0)
  sleep(uinputTimeout)

proc pressMouse*(): void =
  manageMouse(1)

proc releaseMouse*(): void =
  manageMouse(0)

proc pressMouse*(time: int): void =
  pressMouse()
  sleep(time)
  releaseMouse()

proc moveMouseAbs*(x, y: int): void =
  var
    # Most of this is unused since we use the root display so source doesn't apply
    # wSrc, wDest: Window # Unused
    srcX, srcY: cint # Unused
    srcW, srcH: cuint # Unused
    (destX, destY) = (x.cint, y.cint)

  discard XWarpPointer(webfisherDisplay,
    None,
    RootWindow(webfisherDisplay, DefaultScreen(webfisherDisplay)),
    srcX, srcY,
    srcW, srcH,
    destX, destY)

  discard XFlush(webfisherDisplay)
  sleep(uinputTimeout)

proc moveMouseRel*(x, y: int): void =
  var
    # Most of this is unused since we use the root display so source doesn't apply
    # wSrc, wDest: Window # Unused
    srcX, srcY: cint # Unused
    srcW, srcH: cuint # Unused
    (destX, destY) = (x.cint, y.cint)

  discard XWarpPointer(webfisherDisplay,
    None,
    None,
    srcX, srcY,
    srcW, srcH,
    destX, destY)

  discard XFlush(webfisherDisplay)
  sleep(uinputTimeout)

