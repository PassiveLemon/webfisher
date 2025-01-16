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
  let config = initConfig()
  if config.castOnStart == true:
    globalState.lineCast = false
  initDisplay()
  initDevice()

  echo fmt"Started in {config.gameMode} mode."

  while true:
    sleep((config.checkInterval * 1000).int)
    if (config.gameMode in ["combo", "fish"]) and getFishingGame():
      echo "Doing fishing task..."
      doFish()
      sleep(3000)
      if getCatchMenu():
        echo "Nice catch!"
        clickCatchMenu()
      else:
        echo "No catch detected."
      globalState.lineCast = false
      globalState.resetTime = epochTime()
      sleep(1000)

    if (config.gameMode in ["combo", "bucket"]) and ((epochTime() - globalState.bucketTime) > config.bucketTime) and (globalState.lineCast == false):
      echo "Doing bucket task..."
      doBucket()
      sleep(2000)
      if getCatchMenu():
        echo "Nice catch!"
        clickCatchMenu()
      else:
        echo "No catch detected."
      globalState.bucketTime = epochTime()
      sleep(1000)

    if globalState.lineCast == false:
      sleep(1000)
      echo "Casting line..."
      castLine(config.castTime)
      globalState.lineCast = true

    # If the time since the last catch exceeds 2 minutes, we click just once. This action should help resynchronize the loop if something is missed.
    if (epochTime() - globalState.resetTime) > config.resetTime:
      echo "Attempting reset..."
      resetClick()
      globalState.resetTime = epochTime()

