import
  std / [
    os,
    strformat,
    times
  ]

import
  webfisher / [
    config,
    evdev,
    screen,
    task,
  ]


type
  GlobalState* = object
    lineCast: bool
    bucketTime: float
    resetTime: float
    # sodaTime: float
    # shopCount: int


var globalState*: GlobalState = GlobalState(
  lineCast: true,
  bucketTime: epochTime(),
  resetTime: epochTime(),
  # sodaTime: epochTime(),
  # shopCount: 0
)
  

block webfisher:
  initConfig()
  initDisplay()
  initDevice()

  if globalConfig.castOnStart == true:
    globalState.lineCast = false

  echo fmt"Started in {globalConfig.gameMode} mode."

  while true:
    sleep((globalConfig.checkInterval).int)
    if (globalConfig.gameMode in ["combo", "fish"]) and getFishingGame():
      echo "Doing fishing task..."
      doFish()
      sleep(2500)
      doCatchMenu()
      globalState.lineCast = false
      globalState.resetTime = epochTime()
      sleep(1000)

    if (globalConfig.gameMode in ["combo", "bucket"]) and ((epochTime() - globalState.bucketTime) > globalConfig.bucketTime) and (globalState.lineCast == false):
      echo "Doing bucket task..."
      doBucket()
      sleep(1500)
      doCatchMenu()
      globalState.bucketTime = epochTime()
      sleep(1000)

    if globalState.lineCast == false:
      sleep(1000)
      echo "Casting line..."
      castLine()
      globalState.lineCast = true

    if ((epochTime() - globalState.resetTime)) > globalConfig.resetTime:
      echo "Attempting reset..."
      resetClick()
      globalState.resetTime = epochTime()

