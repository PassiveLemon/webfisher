import
  os,
  std/json


type configType* = object
  castTime*: float
  reelInterval*: float
  reelTime*: float
  resetTime*: float


const configJson: string = """
{
  "castTime": 1.0,
  "reelInterval": 0.5,
  "reelTime": 0.3,
  "resetTime": 60.0
}
"""


# Still need to handle the case when user is root/sudo and find the true users config dir
proc createConfig(filePath: string): void =
  let parentPath: string = parentDir(filePath)

  if not existsOrCreateDir(parentPath):
    createDir(parentPath)

  if not fileExists(filePath):
    echo "Config file does not exist. Creating..."
    writeFile(filePath, configJson)

# Debug proc
proc readConfig*(filePath: string): string =
  return readFile(filePath)

# Add missing keys from the configJson const to the host config
proc updateConfig(filePath: string): void =
  let constConfig: JsonNode = parseJson(configJson)
  var hostConfig: JsonNode = parseFile(filePath)
  var hostRewrite: bool

  for key, value in constConfig:
    if not hostConfig.contains(key):
      hostConfig[key] = value
      hostRewrite = true

  if hostRewrite:
    removeFile(filePath)
    writeFile(filePath, pretty(hostConfig))

# Return parsed json file and catch errors
### Implement error handling
proc parseConfig(filePath: string): configType =
  let node: JsonNode = parseFile(filePath)
  var json: configType

  # doAssert node["castTime"].kind != JFloat
  # doAssert node["reelInterval"].kind != JFloat
  # doAssert node["reelTime"].kind != JFloat
  # doAssert node["resetTime"].kind != JFloat

  try:
    json = to(node, configType)
  # except JsonParsingError:
  #   echo "Config file is not valid json."
  #   quit(1)
  finally:
    return json

proc initConfig*(filePath: string): configType =
  createConfig(filePath)
  updateConfig(filePath)

  return parseConfig(filePath)

