# Package
packageName = "webfisher"
version = "1.3.2"
author = "PassiveLemon"
description = "A Nim based fishing script for Webfishing"
license = "GPL-3.0-only"
srcDir = "src"
bin = @["webfisher"]

# Dependencies
requires "nim >= 2.2.0"
requires "https://github.com/PassiveLemon/libevdev-nim.git#4d9b3581df1b95ffc400ae965958039e0687f1d0" # Libevdev
requires "x11 >= 1.2"
requires "winim >= 3.9.4"

