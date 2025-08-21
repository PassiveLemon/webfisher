# Package
packageName = "webfisher"
version = "1.1.1"
author = "PassiveLemon"
description = "A Nim based fishing script for Webfishing"
license = "GPL-3.0-only"
srcDir = "src"
bin = @["webfisher"]

# Dependencies
requires "nim >= 2.2.0"
requires "https://github.com/PassiveLemon/libevdev-nim.git#a191a1b1618e85374e892e40330356fce9886eed" # Libevdev
requires "x11 >= 1.2"
requires "winim >= 3.9.4"

