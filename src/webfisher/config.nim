import
  std / [
    os,
    strformat,
    json
  ]

import
  cli,
  logging


type
  Config* = object
    autoShop*: bool
    autoSoda*: bool
    bait*: int
    bucketTime*: float
    castOnStart*: bool
    castTime*: float
    checkInterval*: float
    gameMode*: string
    holdToFish*: bool
    moveCursor*: bool
    phoneSlot*: int
    resetTime*: float
    rodSlot*: int
    screenConfig*: seq[int]
    sodaSlot*: int


const
  gameModes: seq[string] = @[ "fish", "bucket", "combo" ]
  configJson: string = """
{
  "autoShop": false,
  "autoSoda": false,
  "bait": 0,
  "bucketTime": 30.0,
  "castOnStart": false,
  "castTime": 1.0,
  "checkInterval": 0.5,
  "holdToFish": false,
  "moveCursor": true,
  "phoneSlot": 4,
  "resetTime": 120.0,
  "rodSlot": 1,
  "screenConfig": [
    0, 0, 1920, 1080
  ],
  "sodaSlot": 5
}
"""


var globalConfig*: Config


proc getRealUserConfigDir(): string =
  if defined(linux):
    if (getEnv("USER") == "root") and (getEnv("SUDO_USER") != ""):
      # Ideally we fetch the config dir for a specific user instead of assuming the location, but I couldn't find anything that does so
      return "/home" / getEnv("SUDO_USER") / "/.config/webfisher/config.json"
    return getConfigDir() / "/webfisher/config.json"

  if defined(windows):
    return getConfigDir() / "\\webfisher\\config.json"

proc createConfig(filePath: string): void =
  let parentPath = parentDir(filePath)

  if not existsOrCreateDir(parentPath):
    try:
      createDir(parentPath)
    except IOError, OSError:
      fatal(fmt"Could not create {parentPath}")
      quit(1)

  if not fileExists(filePath):
    try:
      writeFile(filePath, configJson)
    except IOError, OSError:
      fatal(fmt"Could not write to {filePath}")
    finally:
      fatal(fmt"Config file was created at {filePath}. Please configure it accordingly before running again.")
      discard readLine(stdin)
      quit(0)

# Add missing keys from the configJson const to the host config
proc updateConfig(filePath: string): void =
  let constConfig = parseJson(configJson)
  var
    hostConfig = parseFile(filePath)
    hostRewrite: bool

  for key, value in constConfig:
    if not hostConfig.contains(key):
      hostConfig[key] = value
      hostRewrite = true

  if hostRewrite:
    notice("Unspecified value in config file. Adding defaults...")
    try:
      removeFile(filePath)
      writeFile(filePath, pretty(hostConfig))
    except IOError, OSError:
      fatal("Could not update config file.")

# Check and return parsed config
proc parseConfig(filePath: string; cliArgs: CliArgs): Config =
  var
    node = parseFile(filePath)
    json: Config

  # We can load CLI options into the programs config without writing them to the config file
  if cliArgs.mode == "":
    debug(fmt"Argument MODE not provided. Defaulting to {gameModes[0]}...")
    node["gameMode"] = %gameModes[0]
  else:
    if not (cliArgs.mode in gameModes):
      fatal(fmt"{cliArgs.mode} is not a valid argument.")
      quit(1)

    node["gameMode"] = %cliArgs.mode

  if node["autoShop"].kind != JBool:
    fatal("config autoShop is not a boolean.")
    quit(1)

  if node["autoSoda"].kind != JBool:
    fatal("config autoSoda is not a boolean.")
    quit(1)

  if node["bait"].kind != JInt:
    fatal("config bait is not an int.")
    quit(1)
  if not (node["bait"].getInt() in 0..7):
    fatal("config bait is not in range 0 to 7.")
    quit(1)

  # If the user specifies an int, just quietly convert it
  if not (node["bucketTime"].kind in [ JFloat, JInt ]):
    fatal("config bucketTime is not a float.")
    quit(1)
  node["bucketTime"] = %(node["bucketTime"].getFloat())

  if node["castOnStart"].kind != JBool:
    fatal("config castOnStart is not a boolean.")
    quit(1)
  
  if node["castTime"].kind != JFloat:
    fatal("config castTime is not a float.")
    quit(1)
  # Convert seconds to ms at config time
  node["castTime"] = %(node["castTime"].getFloat() * 1000)

  if not (node["checkInterval"].kind in [ JFloat, JInt ]):
    fatal("config castTime is not a float.")
    quit(1)
  node["checkInterval"] = %(node["checkInterval"].getFloat() * 1000)

  if node["holdToFish"].kind != JBool:
    fatal("config holdToFish is not a boolean.")
    quit(1)

  if node["moveCursor"].kind != JBool:
    fatal("config moveCursor is not a boolean.")
    quit(1)

  if node["phoneSlot"].kind != JInt:
    fatal("config phoneSlot is not an int.")
    quit(1)
  if not (node["phoneSlot"].getInt() in 1..10):
    fatal("config phoneSlot is not in range 1 to 10.")
    quit(1)
  
  if not (node["resetTime"].kind in [ JFloat, JInt ]):
    fatal("config resetTime is not a float.")
    quit(1)
  node["resetTime"] = %(node["resetTime"].getFloat())

  if node["rodSlot"].kind != JInt:
    fatal("config rodSlot is not an int.")
    quit(1)
  if not (node["rodSlot"].getInt() in 1..10):
    fatal("config rodSlot is not in range 1 to 10.")
    quit(1)

  if node["screenConfig"].kind != JArray:
    fatal("config screenConfig is not a list.")
    quit(1)
  for v in 0..3:
    try:
      if node["screenConfig"][v].kind != JInt:
        fatal(fmt"config screenConfig element {v + 1} is not an integer.")
        quit(1)
    except IndexDefect:
      fatal(fmt"config screenConfig is missing a value.")
      quit(1)

  if node["sodaSlot"].kind != JInt:
    fatal("config sodaSlot is not an int.")
    quit(1)
  if not (node["sodaSlot"].getInt() in 1..10):
    fatal("config sodaSlot is not in range 1 to 10.")
    quit(1)

  try:
    json = to(node, Config)
  except JsonParsingError:
    fatal("Config file is not valid json.")
    quit(1)
  finally:
    return json

proc initConfig*(): void =
  let cliArgs = processCliArgs()
  var configDir = getRealUserConfigDir()

  initLogger(cliArgs.loglevel, cliArgs.timestamps)

  if cliArgs.file != "":
    configDir = cliArgs.file
    
  createConfig(configDir)
  updateConfig(configDir)
  globalConfig = parseConfig(configDir, cliArgs)

proc getConfig*(): Config =
  return globalConfig

