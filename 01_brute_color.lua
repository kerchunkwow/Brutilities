-- BH is the namespace shared across all files in the Brute Helper addon
_, BH = ...

-- brute_color.lua is an extension of brute_globals.lua focused on defining a table of colors and
-- precomputing the various formats that will be needed elsewhere; we just put it here because it's
-- an obnoxiously long table and annoying when it unfolds

-- Master table mapping colors to their RGBA values
BH.clr = {
  antique_white = {
    rgba = {r = 250, g = 235, b = 215, a = 255},
  },
  aquamarine = {
    rgba = {r = 127, g = 255, b = 212, a = 255},
  },
  azure = {
    rgba = {r = 240, g = 255, b = 255, a = 255},
  },
  bisque = {
    rgba = {r = 255, g = 228, b = 196, a = 255},
  },
  black = {
    rgba = {r = 0, g = 0, b = 0, a = 255},
  },
  blanched_almond = {
    rgba = {r = 255, g = 235, b = 205, a = 255},
  },
  blue = {
    rgba = {r = 0, g = 0, b = 255, a = 255},
  },
  blue_violet = {
    rgba = {r = 138, g = 43, b = 226, a = 255},
  },
  brown = {
    rgba = {r = 165, g = 42, b = 42, a = 255},
  },
  burlywood = {
    rgba = {r = 222, g = 184, b = 135, a = 255},
  },
  cadet_blue = {
    rgba = {r = 95, g = 158, b = 160, a = 255},
  },
  chartreuse = {
    rgba = {r = 127, g = 255, b = 0, a = 255},
  },
  chocolate = {
    rgba = {r = 210, g = 105, b = 30, a = 255},
  },
  coral = {
    rgba = {r = 255, g = 127, b = 80, a = 255},
  },
  cornflower_blue = {
    rgba = {r = 100, g = 149, b = 237, a = 255},
  },
  cornsilk = {
    rgba = {r = 255, g = 248, b = 220, a = 255},
  },
  cyan = {
    rgba = {r = 0, g = 255, b = 255, a = 255},
  },
  dark_goldenrod = {
    rgba = {r = 184, g = 134, b = 11, a = 255},
  },
  dark_green = {
    rgba = {r = 0, g = 100, b = 0, a = 255},
  },
  dark_khaki = {
    rgba = {r = 189, g = 183, b = 107, a = 255},
  },
  dark_olive_green = {
    rgba = {r = 85, g = 107, b = 47, a = 255},
  },
  dark_orange = {
    rgba = {r = 255, g = 140, b = 0, a = 255},
  },
  dark_orchid = {
    rgba = {r = 153, g = 50, b = 204, a = 255},
  },
  dark_salmon = {
    rgba = {r = 233, g = 150, b = 122, a = 255},
  },
  dark_sea_green = {
    rgba = {r = 143, g = 188, b = 143, a = 255},
  },
  dark_slate_blue = {
    rgba = {r = 72, g = 61, b = 139, a = 255},
  },
  dark_slate_gray = {
    rgba = {r = 47, g = 79, b = 79, a = 255},
  },
  dark_slate_grey = {
    rgba = {r = 47, g = 79, b = 79, a = 255},
  },
  dark_turquoise = {
    rgba = {r = 0, g = 206, b = 209, a = 255},
  },
  dark_violet = {
    rgba = {r = 148, g = 0, b = 211, a = 255},
  },
  deep_pink = {
    rgba = {r = 255, g = 20, b = 147, a = 255},
  },
  deep_sky_blue = {
    rgba = {r = 0, g = 191, b = 255, a = 255},
  },
  dim_gray = {
    rgba = {r = 105, g = 105, b = 105, a = 255},
  },
  dim_grey = {
    rgba = {r = 105, g = 105, b = 105, a = 255},
  },
  dodger_blue = {
    rgba = {r = 30, g = 144, b = 255, a = 255},
  },
  firebrick = {
    rgba = {r = 178, g = 34, b = 34, a = 255},
  },
  floral_white = {
    rgba = {r = 255, g = 250, b = 240, a = 255},
  },
  forest_green = {
    rgba = {r = 34, g = 139, b = 34, a = 255},
  },
  gainsboro = {
    rgba = {r = 220, g = 220, b = 220, a = 255},
  },
  ghost_white = {
    rgba = {r = 248, g = 248, b = 255, a = 255},
  },
  gold = {
    rgba = {r = 255, g = 215, b = 0, a = 255},
  },
  goldenrod = {
    rgba = {r = 218, g = 165, b = 32, a = 255},
  },
  gray = {
    rgba = {r = 190, g = 190, b = 190, a = 255},
  },
  green = {
    rgba = {r = 0, g = 255, b = 0, a = 255},
  },
  green_yellow = {
    rgba = {r = 173, g = 255, b = 47, a = 255},
  },
  grey = {
    rgba = {r = 190, g = 190, b = 190, a = 255},
  },
  honeydew = {
    rgba = {r = 240, g = 255, b = 240, a = 255},
  },
  hot_pink = {
    rgba = {r = 255, g = 105, b = 180, a = 255},
  },
  indian_red = {
    rgba = {r = 205, g = 92, b = 92, a = 255},
  },
  ivory = {
    rgba = {r = 255, g = 255, b = 240, a = 255},
  },
  khaki = {
    rgba = {r = 240, g = 230, b = 140, a = 255},
  },
  lavender = {
    rgba = {r = 230, g = 230, b = 250, a = 255},
  },
  lavender_blush = {
    rgba = {r = 255, g = 240, b = 245, a = 255},
  },
  lawn_green = {
    rgba = {r = 124, g = 252, b = 0, a = 255},
  },
  lemon_chiffon = {
    rgba = {r = 255, g = 250, b = 205, a = 255},
  },
  light_blue = {
    rgba = {r = 173, g = 216, b = 230, a = 255},
  },
  light_coral = {
    rgba = {r = 240, g = 128, b = 128, a = 255},
  },
  light_cyan = {
    rgba = {r = 224, g = 255, b = 255, a = 255},
  },
  light_goldenrod = {
    rgba = {r = 238, g = 221, b = 130, a = 255},
  },
  light_goldenrod_yellow = {
    rgba = {r = 250, g = 250, b = 210, a = 255},
  },
  light_gray = {
    rgba = {r = 211, g = 211, b = 211, a = 255},
  },
  light_grey = {
    rgba = {r = 211, g = 211, b = 211, a = 255},
  },
  light_pink = {
    rgba = {r = 255, g = 182, b = 193, a = 255},
  },
  light_salmon = {
    rgba = {r = 255, g = 160, b = 122, a = 255},
  },
  light_sea_green = {
    rgba = {r = 32, g = 178, b = 170, a = 255},
  },
  light_sky_blue = {
    rgba = {r = 135, g = 206, b = 250, a = 255},
  },
  light_slate_blue = {
    rgba = {r = 132, g = 112, b = 255, a = 255},
  },
  light_slate_gray = {
    rgba = {r = 119, g = 136, b = 153, a = 255},
  },
  light_slate_grey = {
    rgba = {r = 119, g = 136, b = 153, a = 255},
  },
  light_steel_blue = {
    rgba = {r = 176, g = 196, b = 222, a = 255},
  },
  light_yellow = {
    rgba = {r = 255, g = 255, b = 224, a = 255},
  },
  lime_green = {
    rgba = {r = 50, g = 205, b = 50, a = 255},
  },
  linen = {
    rgba = {r = 250, g = 240, b = 230, a = 255},
  },
  magenta = {
    rgba = {r = 255, g = 0, b = 255, a = 255},
  },
  maroon = {
    rgba = {r = 176, g = 48, b = 96, a = 255},
  },
  medium_aquamarine = {
    rgba = {r = 102, g = 205, b = 170, a = 255},
  },
  medium_blue = {
    rgba = {r = 0, g = 0, b = 205, a = 255},
  },
  medium_orchid = {
    rgba = {r = 186, g = 85, b = 211, a = 255},
  },
  medium_purple = {
    rgba = {r = 147, g = 112, b = 219, a = 255},
  },
  medium_sea_green = {
    rgba = {r = 60, g = 179, b = 113, a = 255},
  },
  medium_slate_blue = {
    rgba = {r = 123, g = 104, b = 238, a = 255},
  },
  medium_spring_green = {
    rgba = {r = 0, g = 250, b = 154, a = 255},
  },
  medium_turquoise = {
    rgba = {r = 72, g = 209, b = 204, a = 255},
  },
  medium_violet_red = {
    rgba = {r = 199, g = 21, b = 133, a = 255},
  },
  midnight_blue = {
    rgba = {r = 25, g = 25, b = 112, a = 255},
  },
  mint_cream = {
    rgba = {r = 245, g = 255, b = 250, a = 255},
  },
  misty_rose = {
    rgba = {r = 255, g = 228, b = 225, a = 255},
  },
  moccasin = {
    rgba = {r = 255, g = 228, b = 181, a = 255},
  },
  navajo_white = {
    rgba = {r = 255, g = 222, b = 173, a = 255},
  },
  navy = {
    rgba = {r = 0, g = 0, b = 128, a = 255},
  },
  navy_blue = {
    rgba = {r = 0, g = 0, b = 128, a = 255},
  },
  old_lace = {
    rgba = {r = 253, g = 245, b = 230, a = 255},
  },
  olive_drab = {
    rgba = {r = 107, g = 142, b = 35, a = 255},
  },
  orange = {
    rgba = {r = 255, g = 165, b = 0, a = 255},
  },
  orange_red = {
    rgba = {r = 255, g = 69, b = 0, a = 255},
  },
  orchid = {
    rgba = {r = 218, g = 112, b = 214, a = 255},
  },
  pale_goldenrod = {
    rgba = {r = 238, g = 232, b = 170, a = 255},
  },
  pale_green = {
    rgba = {r = 152, g = 251, b = 152, a = 255},
  },
  pale_turquoise = {
    rgba = {r = 175, g = 238, b = 238, a = 255},
  },
  pale_violet_red = {
    rgba = {r = 219, g = 112, b = 147, a = 255},
  },
  papaya_whip = {
    rgba = {r = 255, g = 239, b = 213, a = 255},
  },
  peach_puff = {
    rgba = {r = 255, g = 218, b = 185, a = 255},
  },
  peru = {
    rgba = {r = 205, g = 133, b = 63, a = 255},
  },
  pink = {
    rgba = {r = 255, g = 192, b = 203, a = 255},
  },
  plum = {
    rgba = {r = 221, g = 160, b = 221, a = 255},
  },
  powder_blue = {
    rgba = {r = 176, g = 224, b = 230, a = 255},
  },
  purple = {
    rgba = {r = 160, g = 32, b = 240, a = 255},
  },
  red = {
    rgba = {r = 255, g = 0, b = 0, a = 255},
  },
  rosy_brown = {
    rgba = {r = 188, g = 143, b = 143, a = 255},
  },
  royal_blue = {
    rgba = {r = 65, g = 105, b = 225, a = 255},
  },
  saddle_brown = {
    rgba = {r = 139, g = 69, b = 19, a = 255},
  },
  salmon = {
    rgba = {r = 250, g = 128, b = 114, a = 255},
  },
  sandy_brown = {
    rgba = {r = 244, g = 164, b = 96, a = 255},
  },
  sea_green = {
    rgba = {r = 46, g = 139, b = 87, a = 255},
  },
  seashell = {
    rgba = {r = 255, g = 245, b = 238, a = 255},
  },
  sienna = {
    rgba = {r = 160, g = 82, b = 45, a = 255},
  },
  sky_blue = {
    rgba = {r = 135, g = 206, b = 235, a = 255},
  },
  slate_blue = {
    rgba = {r = 106, g = 90, b = 205, a = 255},
  },
  slate_gray = {
    rgba = {r = 112, g = 128, b = 144, a = 255},
  },
  slate_grey = {
    rgba = {r = 112, g = 128, b = 144, a = 255},
  },
  snow = {
    rgba = {r = 255, g = 250, b = 250, a = 255},
  },
  spring_green = {
    rgba = {r = 0, g = 255, b = 127, a = 255},
  },
  steel_blue = {
    rgba = {r = 70, g = 130, b = 180, a = 255},
  },
  tan = {
    rgba = {r = 210, g = 180, b = 140, a = 255},
  },
  thistle = {
    rgba = {r = 216, g = 191, b = 216, a = 255},
  },
  tomato = {
    rgba = {r = 255, g = 99, b = 71, a = 255},
  },
  turquoise = {
    rgba = {r = 64, g = 224, b = 208, a = 255},
  },
  violet = {
    rgba = {r = 238, g = 130, b = 238, a = 255},
  },
  violet_red = {
    rgba = {r = 208, g = 32, b = 144, a = 255},
  },
  wheat = {
    rgba = {r = 245, g = 222, b = 179, a = 255},
  },
  white = {
    rgba = {r = 255, g = 255, b = 255, a = 255},
  },
  white_smoke = {
    rgba = {r = 245, g = 245, b = 245, a = 255},
  },
  yellow = {
    rgba = {r = 255, g = 255, b = 0, a = 255},
  },
  yellow_green = {
    rgba = {r = 154, g = 205, b = 50, a = 255},
  },
}

local clr = BH.clr

-- Extend the clr table to include additional precomputed formats of the named colors:
-- tex: RGBA values clamped between 0 and 1 for use stylizing textures
-- hex: Hexidecimal value of the color (i.e., 0xFFFFFF)
-- tag: WoW chat/output compatible text color tag ("|cFFRRGGBB"); close with "|r"
for color, data in pairs( clr ) do
  data.name = color
  local rgba = data.rgba
  -- Set data.tex equal rgba values divided by 255 for use with textures
  data.tex = {r = rgba.r / 255, g = rgba.g / 255, b = rgba.b / 255, a = rgba.a / 255}
  -- Set data.hex equal to the hexidecimal value of the color (i.e., 0xFFFFFF)
  data.hex = (rgba.r * 0x10000) + (rgba.g * 0x100) + rgba.b
  -- Set data.tag equal to a WoW-compatible text color tag ("|cFFRRGGBB")
  data.tag = string.format( "|cFF%02X%02X%02X", rgba.r, rgba.g, rgba.b )
  -- Use chat as an alias for tag
  data.chat = data.tag
end
-- Shorthand function to add opening & closing color tags to the string parameter
local function hl( s, c )
  return clr[c].tag .. s .. "|r"
end
