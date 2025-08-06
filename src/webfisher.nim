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
    lastCatchTime: float
    lineCast: bool
    bucketTime: float
    resetTime: float
    sodaTime: float


var globalState: GlobalState = GlobalState(
  lastCatchTime: 300.0,
  lineCast: false,
  bucketTime: epochTime(),
  resetTime: epochTime(),
  sodaTime: 0.0,
)


block webfisher:
  initConfig()
  initDisplay()
  initDevice()

  echo fmt"Started in {globalConfig.gameMode} mode."

  if globalConfig.castOnStart == true:
    castLine()
    globalState.lineCast = true

  while true:
    sleep((globalConfig.checkInterval).int)
    if (globalConfig.gameMode in ["combo", "fish"]) and getFishingGame():
      echo "Doing fishing task..."
      doFish()
      if doCatchMenu():
        globalState.lastCatchTime = 0.0
      else:
        globalState.lastCatchTime = epochTime()
      globalState.lineCast = false
      globalState.resetTime = epochTime()

    if (globalConfig.gameMode in ["combo", "bucket"]) and ((epochTime() - globalState.bucketTime) > globalConfig.bucketTime) and (globalState.lineCast == false):
      echo "Doing bucket task..."
      doBucket()
      discard doCatchMenu()
      globalState.bucketTime = epochTime()

    if (globalConfig.gameMode in ["combo", "fish"]):
      if globalConfig.autoShop and getEmptyBait() and (globalState.lineCast == false):
        echo "Buying and selecting bait..."
        doShop()

      if globalConfig.autoSoda and ((epochTime() - globalState.sodaTime) > 300.0) and (globalState.lastCatchTime < globalConfig.resetTime) and (globalState.lineCast == false):
        echo "Drinking soda..."
        doSoda()
        globalState.sodaTime = epochTime()
        
      if globalState.lineCast == false:
        equipRod()
        echo "Casting line..."
        castLine()
        globalState.lineCast = true

      if ((epochTime() - globalState.resetTime)) > globalConfig.resetTime:
        echo "Attempting reset..."
        globalState.lineCast = false
        globalState.resetTime = epochTime()
        globalState.lastCatchTime = epochTime()

