-- BH is the namespace shared across all files in the Brute Helper addon
_, BH              = ...

-- Reference to Chunklib shared library
Chunklib           = Chunklib or {}

BH.fr              = BH.fr or CreateFrame( "Frame" )

-- Table to accumulate event->handler pairs so they can be registered by wwra_reg.lua
BH.eventHandlers   = {}

-- Table to accumulate slash command->function pairs so they can be registered by wwra_reg.lua
BH.slashCommands   = {}

BH.raidTargetIcons = {
  [0] = "None",
  [1] = "Star",
  [2] = "Circle",
  [3] = "Diamond",
  [4] = "Triangle",
  [5] = "Moon",
  [6] = "Square",
  [7] = "Cross",
  [8] = "Skull"
}

-- #region Global Color Map
