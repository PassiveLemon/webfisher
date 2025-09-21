import
  std / [
    os,
    strformat,
    times
  ]

import
  webfisher / [
    config,
    input,
    logging,
    screen,
    task
  ]


type
  GlobalState* = object
    lineCast: bool
    lastCatchTime: float
    bucketTime: float
    resetTime: float
    sodaTime: float


var globalState: GlobalState = GlobalState(
  lineCast: false,
  # Add a bunch of buffer time so it won't attempt to use soda until after the first catch
  lastCatchTime: (epochTime() + 300.0),
  bucketTime: epochTime(),
  resetTime: epochTime(),
  sodaTime: 0.0
)


block webfisher:
  initConfig()
  initDisplay()
  initDevice()
  debug("Starting Webfisher...")

  notice(fmt"Started in {globalConfig.gameMode} mode.")
  if globalConfig.autoSoda:
    info("AutoSoda enabled.")
  if globalConfig.autoShop:
    info(fmt"AutoShop enabled, using bait {globalConfig.bait}.")

  # Add some wait time so the user can get situated
  debug("Waiting for 5 seconds...")
  sleep(5000)

  if globalConfig.castOnStart == true:
    castLine()
    globalState.lineCast = true

  while true:
    sleep((globalConfig.checkInterval).int)
    if (globalConfig.gameMode in ["combo", "fish"]) and getFishingGame():
      doFish()
      if doCatchMenu():
        globalState.lastCatchTime = 0.0
      else:
        globalState.lastCatchTime = epochTime()
      globalState.lineCast = false
      globalState.resetTime = epochTime()

    if (globalConfig.gameMode in ["combo", "bucket"]) and ((epochTime() - globalState.bucketTime) > globalConfig.bucketTime) and (globalState.lineCast == false):
      doBucket()
      discard doCatchMenu()
      globalState.bucketTime = epochTime()

    if (globalConfig.gameMode in ["combo", "fish"]):
      if globalConfig.autoShop and getEmptyBait() and (globalState.lineCast == false):
        doShop()

      if globalConfig.autoSoda and ((epochTime() - globalState.sodaTime) > 300.0) and (globalState.lastCatchTime < globalConfig.resetTime) and (globalState.lineCast == false):
        doSoda()
        globalState.sodaTime = epochTime()
        
      if globalState.lineCast == false:
        castLine()
        globalState.lineCast = true

      if ((epochTime() - globalState.resetTime) > globalConfig.resetTime):
        doReset()
        globalState.lineCast = false
        globalState.resetTime = epochTime()
        globalState.lastCatchTime = epochTime()

