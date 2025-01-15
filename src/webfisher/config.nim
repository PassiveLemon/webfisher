import
  std / [
    os,
    strformat,
    json
  ]

import
  ./cli

type
  Config* = object
    castOnStart*: bool
    castTime*: float
    checkInterval*: float
    gameMode*: string


const
  gameModes: seq[string] = @[ "fish", "bucket", "combo" ]
  configJson: string = """
{
  "castOnStart": false,
  "castTime": 1.0,
  "checkInterval": 0.5,
}
"""


proc getRealUserConfigDir(): string =
  if (getEnv("USER") == "root") and (getEnv("SUDO_USER") != ""):
    # Ideally we fetch the config dir for a specific user instead of assuming the location, but I couldn't find anything that does so
    return "/home" / getEnv("SUDO_USER") / "/.config/webfisher/config.json"

  return getConfigDir() / "/webfisher/config.json"

proc createConfig(filePath: string): void =
  let parentPath = parentDir(filePath)

  if not existsOrCreateDir(parentPath):
    try:
      createDir(parentPath)
    except IOError, OSError:
      echo fmt"Could not create {parentPath}"
      quit(1)

  if not fileExists(filePath):
    try:
      writeFile(filePath, configJson)
    except IOError, OSError:
      echo fmt"Could not write to {filePath}"
    finally:
      echo "Config file does not exist. Creating..."

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
    try:
      removeFile(filePath)
      writeFile(filePath, pretty(hostConfig))
    except IOError, OSError:
      echo "Could not update config file."

# Check and return parsed config
proc parseConfig(filePath: string; cliArgs: CliArgs): Config =
  var
    node = parseFile(filePath)
    json: Config

  # We can load CLI options into the programs config without writing them to the config file
  if cliArgs.mode == "":
    echo fmt"Argument MODE not provided. Defaulting to {gameModes[0]}..."
    node["gameMode"] = %gameModes[0]
  else:
    if not gameModes.contains(cliArgs.mode):
      echo fmt"{cliArgs.mode} is not a valid argument."
      quit(1)

    node["gameMode"] = %cliArgs.mode

  if node["castOnStart"].kind != JBool:
    echo "config castOnStart is not a boolean."
    quit(1)
  if node["castTime"].kind != JFloat:
    echo "config castTime is not a float."
    quit(1)
  if node["checkInterval"].kind != JFloat:
    echo "config castTime is not a float."
    quit(1)

  try:
    json = to(node, Config)
  except JsonParsingError:
    echo "Config file is not valid json."
    quit(1)
  finally:
    return json

proc initConfig*(): Config =
  let cliArgs = processCliArgs()
  var configDir = getRealUserConfigDir()

  if cliArgs.file != "":
    configDir = cliArgs.file
    
  createConfig(configDir)
  updateConfig(configDir)
  return parseConfig(configDir, cliArgs)

