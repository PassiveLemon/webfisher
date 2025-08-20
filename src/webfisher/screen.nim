when defined(linux):
  import ./linux/screen
  export screen

when defined(windows):
  import ./windows/screen
  export screen

