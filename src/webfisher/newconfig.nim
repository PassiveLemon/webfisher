type
  #  config      type    cli description
  # ("autoShop", "type", "desc")
  ConfigOption* = seq[tuple[c, t, d: string]]


const
  configFile*: ConfigOption = @[
    ("autoShop", "bool", "Whether to automatically purchase bait")
  ]
  # configCli should inherit configFile options so Webfisher can be configured from Cli
  configCli*: ConfigOption = @[
    ("version", "bool", "Show version and exit")
  ]

