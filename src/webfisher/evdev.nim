import
  std / [
    os,
    strformat
  ]

import
  ./libevdev/libevdev, # Upstream does not have any uinput procs so currently using a fork
  ./libevdev/linuxinput


var webfisherDevice: ptr libevdev_uinput


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

  let libevdevUinputRet = libevdev_uinput_create_from_device(evdev, LIBEVDEV_UINPUT_OPEN_MANAGED, addr uinput)
  if libevdevUinputRet < 0:
    echo fmt"Could not create libevdev uinput mouse device: code {libevdevUinputRet}"
    quit(1)

  return uinput

proc initDevice*(): void =
  webfisherDevice = createDevice()

proc cleanupDevice*(): void =
  libevdev_uinput_destroy(webfisherDevice)

proc pressKey*(): void =
  libevdev_uinput_write_event(webfisherDevice, EV_KEY, KEY_E, 1)
  sleep(20) # Buffer time so listeners can see events more consistently
  libevdev_uinput_write_event(webfisherDevice, EV_SYN, SYN_REPORT, 0)
  sleep(20)

proc releaseKey*(): void =
  libevdev_uinput_write_event(webfisherDevice, EV_KEY, KEY_E, 0)
  sleep(20)
  libevdev_uinput_write_event(webfisherDevice, EV_SYN, SYN_REPORT, 0)
  sleep(20)

proc pressKey*(time: float): void =
  pressKey()
  sleep(time.int)
  releaseKey()

proc pressMouse*(): void =
  libevdev_uinput_write_event(webfisherDevice, EV_KEY, BTN_LEFT, 1)
  sleep(20)
  libevdev_uinput_write_event(webfisherDevice, EV_SYN, SYN_REPORT, 0)
  sleep(20)

proc releaseMouse*(): void =
  libevdev_uinput_write_event(webfisherDevice, EV_KEY, BTN_LEFT, 0)
  sleep(20)
  libevdev_uinput_write_event(webfisherDevice, EV_SYN, SYN_REPORT, 0)
  sleep(20)

proc pressMouse*(time: float): void =
  pressMouse()
  sleep(time.int)
  releaseMouse()

