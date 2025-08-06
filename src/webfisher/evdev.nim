import
  std / [
    os,
    strformat
  ],
  x11 / [
    x,
    xlib
  ]

import
  libevdev,
  linux/input


type
  CursorPos* = tuple[x, y: int]


var
  webfisherDevice: ptr libevdev_uinput
  webfisherDisplay: PDisplay


proc createDevice(): ptr libevdev_uinput =
  var
    evdev = libevdev_new()
    uinput: ptr libevdev_uinput

  webfisherDisplay = XOpenDisplay(nil)

  libevdev_set_name(evdev, "Webfisher Input");
  discard libevdev_enable_property(evdev, INPUT_PROP_POINTER);

  discard libevdev_enable_event_type(evdev, EV_REL);
  discard libevdev_enable_event_code(evdev, EV_REL, REL_X, nil);
  discard libevdev_enable_event_code(evdev, EV_REL, REL_Y, nil);

  discard libevdev_enable_event_type(evdev, EV_KEY);
  discard libevdev_enable_event_code(evdev, EV_KEY, BTN_LEFT, nil);
  discard libevdev_enable_event_code(evdev, EV_KEY, KEY_E, nil);

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

proc cleanupDevice*(): void =
  libevdev_uinput_destroy(webfisherDevice)
  discard XCloseDisplay(webfisherDisplay)

proc manageKey(key: int, state: int): void =
  libevdev_uinput_write_event(webfisherDevice, EV_KEY, key, state)
  sleep(10) # Buffer time so listeners can see events more consistently
  libevdev_uinput_write_event(webfisherDevice, EV_SYN, SYN_REPORT, 0)
  sleep(10)

proc pressKey(key: int): void =
  manageKey(key, 1)

proc releaseKey(key: int): void =
  manageKey(key, 0)

proc pressInteract*(time: float): void =
  pressKey(KEY_E)
  sleep(time.int)
  releaseKey(KEY_E)

proc pressNum*(num: int, time: float): void =
  # The const for KEY_num is the number + 1. Ex: KEY_1 = 2
  # We also tell the user to use 10 instead of 0
  pressKey(num + 1)
  sleep(time.int)
  releaseKey(num + 1)

proc manageMouse(state: int): void =
  libevdev_uinput_write_event(webfisherDevice, EV_KEY, BTN_LEFT, state)
  sleep(10)
  libevdev_uinput_write_event(webfisherDevice, EV_SYN, SYN_REPORT, 0)
  sleep(10)

proc pressMouse*(): void =
  manageMouse(1)

proc releaseMouse*(): void =
  manageMouse(0)

proc pressMouse*(time: float): void =
  pressMouse()
  sleep(time.int)
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
  sleep(10)

# Stuff that may get used in the future idk
# proc getCursorPosition(): CursorPos =
#   var
#     rootReturn, childReturn: Window
#     # winX and winY are unused because the child window is the root display but maybe we add program detection and no longer need the root window in the future
#     rootX, rootY, winX, winY: cint
#     maskReturn: cuint

#   discard XQueryPointer(webfisherDisplay,
#     RootWindow(webfisherDisplay, DefaultScreen(webfisherDisplay)),
#     addr rootReturn, addr childReturn,
#     addr rootX, addr rootY, addr winX, addr winY,
#     addr maskReturn)

#   return (rootX, rootY)

# proc printMousePos*(): void =
#   let (mouseX, mouseY) = getCursorPosition()
#   echo mouseX, " ", mouseY

# proc moveMouseRel*(x, y: int): void =
#   libevdev_uinput_write_event(webfisherDevice, EV_REL, REL_X, x)
#   libevdev_uinput_write_event(webfisherDevice, EV_REL, REL_Y, y)
#   sleep(20)
#   libevdev_uinput_write_event(webfisherDevice, EV_SYN, SYN_REPORT, 0)
#   sleep(20)

