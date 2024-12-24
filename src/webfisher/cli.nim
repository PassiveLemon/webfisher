import
  std/os,
  std/strformat,
  std/parseopt

import
  ./meta


type
  CliArgs* = object
    file*: string
    device*: string
    mode*: string


proc cliHelp(): void =
  echo """
Usage: webfisher [Options] [MODE]

Arguments:
  MODE                        One of "fish", "bucket", or "combo"

Options:
  -h, --help                  Show help and exit
  -v, --version               Show version and exit
  -f=FILE, --file=FILE        Location of the configuration file
  -d=DEVICE, --device=DEVICE  Input device to use
"""
  quit(0)

proc cliVersion(): void =
  echo fmt"Webfisher {releaseVersion}"
  quit(0)

proc processCliArgs*(): CliArgs =
  var cliArgs: CliArgs

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
          of "f", "file":
            cliArgs.file = expandTilde(val)
          of "d", "device":
            cliArgs.device = val
      of cmdEnd: assert(false)
  return cliArgs

