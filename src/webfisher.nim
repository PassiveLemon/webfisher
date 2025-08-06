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
    # shopCount: int


var globalState: GlobalState = GlobalState(
  lastCatchTime: 300.0,
  lineCast: false,
  bucketTime: epochTime(),
  resetTime: epochTime(),
  sodaTime: 0.0,
  # shopCount: 0
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
      sleep(2500)
      if doCatchMenu():
        globalState.lastCatchTime = 0
      else:
        globalState.lastCatchTime = epochTime()
      globalState.lineCast = false
      globalState.resetTime = epochTime()

    if (globalConfig.gameMode in ["combo", "bucket"]) and ((epochTime() - globalState.bucketTime) > globalConfig.bucketTime) and (globalState.lineCast == false):
      echo "Doing bucket task..."
      doBucket()
      sleep(1500)
      discard doCatchMenu()
      globalState.bucketTime = epochTime()

    if (globalConfig.gameMode in ["combo", "fish"]):
      if globalConfig.useSoda and ((epochTime() - globalState.sodaTime) > 300) and (globalState.lastCatchTime < globalConfig.resetTime):
        echo "Drinking soda..."
        doSoda()
        globalState.sodaTime = epochTime()
        
      if globalState.lineCast == false:
        sleep(500)
        echo "Casting line..."
        castLine()
        globalState.lineCast = true

      if (globalConfig.gameMode in ["combo", "fish"]) and ((epochTime() - globalState.resetTime)) > globalConfig.resetTime:
        echo "Attempting reset..."
        globalState.lineCast = false
        globalState.resetTime = epochTime()
        globalState.lastCatchTime = epochTime()

