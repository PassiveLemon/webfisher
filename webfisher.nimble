# Package
version = "0.4.1"
author = "PassiveLemon"
description = "A Nim based fishing script for Webfishing"
license = "GPL-3.0-only"
srcDir = "src"
bin = @["webfisher"]

# Dependencies
requires "nim >= 2.2.0"
requires "https://github.com/PassiveLemon/libevdev-nim.git#c509da320c45b3b77c2da2d45e695511ff457ba0" # Libevdev
requires "x11 >= 1.2"

