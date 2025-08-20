when defined(linux):
  import ./linux/input
  export input

when defined(windows):
  import ./windows/input
  export input

