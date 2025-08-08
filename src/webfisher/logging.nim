import std/logging

var
  consoleLog = newConsoleLogger(fmtStr="[$levelname]: ")
  lowestLogLevel = 1

proc initLogger*(timestamps: bool, loglevel: int): void =
  lowestLogLevel = loglevel
  if timestamps:
    consoleLog = newConsoleLogger(fmtStr="[$datetime][$levelname]: ")

proc info*(str: string): void =
  if lowestLogLevel > 4:
    consoleLog.log(lvlInfo, str)

proc notice*(str: string): void =
  if lowestLogLevel > 3:
    consoleLog.log(lvlNotice, str)

proc warn*(str: string): void =
  if lowestLogLevel > 2:
    consoleLog.log(lvlWarn, str)

proc error*(str: string): void =
  if lowestLogLevel > 1:
    consoleLog.log(lvlError, str)

proc fatal*(str: string): void =
  if lowestLogLevel > 0:
    consoleLog.log(lvlFatal, str)

