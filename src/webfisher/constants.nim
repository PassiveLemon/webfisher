type
  PixelList = seq[tuple[x, y, r, g, b: int]]


const
  fishingReelPixels*: PixelList = @[(428, 785, 156, 145, 74),
                                    (388, 745, 156, 145, 74), 
                                    (428, 705, 156, 145, 74),
                                    (468, 745, 156, 145, 74)]

  catchMenuPixels*: PixelList = @[(320, 800, 90, 117, 90),
                                  (1500, 850, 255, 238, 213), 
                                  (1500, 950, 255, 238, 213), 
                                  (400, 950, 255, 238, 213)]


# General uinput delays/lengths (default 20 ms)
# Key press delays/lengths
# Animation delays/lengths
# Equiping item
# Drinking soda

