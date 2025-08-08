import
  std / [
    os,
    strformat,
    parseopt,
    tables,
    strutils
  ]

import
  ./constants


type
  CliArgs* = object
    file*: string
    loglevel*: int
    mode*: string
    timestamps*: bool


const logLevel = {
  "info": 5,
  "notice": 4,
  "warn": 3,
  "error": 2,
  "fatal": 1,
  "none": 0
}.toTable


proc cliHelp(): void =
  echo """
Usage: webfisher [Options] [MODE]

Arguments:
  MODE                        One of "fish", "bucket", or "combo"

Options:
  -h, --help                  Show help and exit
  -v, --version               Show version and exit
  -t, --timestamps            Print timestamps when logging
  -l=LVL, --log=LVL           Logging level. One of "info", "notice", "warn", "error", "fatal", "none"
  -f=FILE, --file=FILE        Location of the configuration file
"""
  quit(0)

proc cliVersion(): void =
  echo fmt"Webfisher {releaseVersion}"
  quit(0)

proc processCliArgs*(): CliArgs =
  var cliArgs: CliArgs

  cliArgs.timestamps = false

  for kind, key, val in getopt():
    case kind
      of cmdArgument:
        cliArgs.mode = key
      of cmdShortOption, cmdLongOption:
        case key
          of "h", "help":
            cliHelp()
          of "v", "version":
            cliVersion()
          of "t", "timestamps":
            cliArgs.timestamps = true
          of "l", "log-level":
            try:
              cliArgs.loglevel = logLevel[toLower(val)]
            except KeyError:
              echo fmt"[FATAL]: {val} is not a valid value for log-level."
          of "f", "file":
            cliArgs.file = expandTilde(val)
      of cmdEnd: assert(false)
  return cliArgs

