import
  std / [
    os,
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
    # sodaTime: float
    # shopCount: int


var globalState*: GlobalState = GlobalState(
  lineCast: true,
  bucketTime: epochTime(),
  # sodaTime: epochTime(),
  # shopCount: 0
)
  

block webfisher:
  let config = initConfig()
  if config.castOnStart == true:
    globalState.lineCast = false
  initDisplay()
  initDevice()

  while true:
    sleep((config.checkInterval * 1000).int)
    if (config.gameMode == "fish" or config.gameMode == "combo") and getFishingGame():
      echo "Doing fishing task"
      doFish()
      sleep(3000)
      if getCatchMenu():
        echo "Clicking through menu"
        clickCatchMenu()
      else:
        echo "No catch detected"
      globalState.lineCast = false
      sleep(1000)

    if (config.gameMode == "bucket" or config.gameMode == "combo") and ((epochTime() - globalState.bucketTime) > 30) and globalState.lineCast == false:
      echo "Doing bucket task"
      doBucket()
      sleep(1000)
      if getCatchMenu():
        echo "Clicking through menu"
        clickCatchMenu()
      else:
        echo "No catch detected"
      globalState.bucketTime = epochTime()
      sleep(1000)

    if globalState.lineCast == false:
      sleep(1000)
      echo "Casting line"
      castLine(config.castTime)
      globalState.lineCast = true

