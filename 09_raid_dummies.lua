-- #region: Import from Brutilities Namespace
_, Brutilities          = ...

local consoleOut        = Chunklib.consoleOut
-- #endregion

-- raid_dummies.lua exists to provide a "dummy roster" to the raid_roster module in order to test
-- its sorting mechanisms. This file will not be used in a live raid environment.

Brutilities.dummyRoster = {}

-- Return three integers representing the number of tanks, healers, and DPS in a fictional dummy raid
local function getDummyComposition()
  -- Generate a random number of total raiders between 16 and 29
  local totalRaiderCount = math.random( 16, 29 )
  -- Always 2 tanks
  local tankCount = 2
  -- Set healers to a ratio of 1:4 or 1:5 with equal probability
  local healerRatio = math.random( 4, 5 )
  local healerCount = math.floor( totalRaiderCount / healerRatio )
  -- DPS comprise the remaining to fill to the total
  local dpsCount = totalRaiderCount - (tankCount + healerCount)
  return tankCount, healerCount, dpsCount
end

-- Get n unique (non-repeating) names from the namesForDummies table to assign to new dummy raiders
-- Return a list of n dummy names without repeats
local function getNamesForDummies( n )
  -- List of dummy names for use in creating simulated raid rosters
  local namesForDummies = {
    "Pholora",
    "Creamis",
    "Elata",
    "Helenium",
    "Amaranthis",
    "Dammeri",
    "Juniper",
    "Saffronea",
    "Gilliphae",
    "Haldia",
    "Nyxie",
    "Marynae",
    "Myrica",
    "Cymosa",
    "Sinense",
    "Nassella",
    "Cloverae",
    "Barbarina",
    "Harlequine",
    "Boabaya",
    "Astachus",
    "Pegus",
    "Acheus",
    "Absanus",
    "Darriss",
    "Alakos",
    "Asules",
    "Lakasos",
    "Vasasius",
    "Feodeimon",
    "Phaenine",
    "Eudatea",
    "Aikeope",
    "Monothea",
    "Semassa",
    "Maerica",
    "Naerora",
    "Deinaia",
    "Pronobe",
    "Nemamna",
    "Rabdos",
    "Gagiel",
    "Salathiel",
    "Jehudiel",
    "Verchiel",
    "Raziel",
    "Cathetel",
    "Onoel",
    "Quabriel",
    "Zerachiel",
    "Hayyel",
    "Zazriel",
    "Temperance",
    "Rachiel",
    "Tabris",
    "Maliel",
    "Sachael",
    "Gamaliel",
    "Sachiel",
    "Elemiah",
    "Malakh",
    "Karael",
    "Pamyel",
    "Virgil",
    "Yabbashael",
    "Dardariel",
    "Semsapiel",
    "Zadkiel",
    "Leo",
    "Izrail",
  }

  local dummyNames = {}

  for i = 1, n do
    -- Randomly select a name and remove it from the available pool
    local index = math.random( 1, #namesForDummies )
    -- Put dummies on our home server of Hyjal
    local dummyName = table.remove( namesForDummies, index ) .. "-Hyjal"
    table.insert( dummyNames, dummyName )
  end
  return dummyNames
end

-- Given a combat role, return a random class capable of filling that role
local function getDummyClassByRole( combatRole )
  local classRoles = {
    {class = "Death Knight", role = "DAMAGER"},
    {class = "Death Knight", role = "TANK"},
    {class = "Demon Hunter", role = "DAMAGER"},
    {class = "Demon Hunter", role = "TANK"},
    {class = "Druid",        role = "DAMAGER"},
    {class = "Druid",        role = "HEALER"},
    {class = "Druid",        role = "TANK"},
    {class = "Evoker",       role = "DAMAGER"},
    {class = "Evoker",       role = "HEALER"},
    {class = "Hunter",       role = "DAMAGER"},
    {class = "Mage",         role = "DAMAGER"},
    {class = "Monk",         role = "DAMAGER"},
    {class = "Monk",         role = "HEALER"},
    {class = "Monk",         role = "TANK"},
    {class = "Paladin",      role = "DAMAGER"},
    {class = "Paladin",      role = "HEALER"},
    {class = "Paladin",      role = "TANK"},
    {class = "Priest",       role = "DAMAGER"},
    {class = "Priest",       role = "HEALER"},
    {class = "Rogue",        role = "DAMAGER"},
    {class = "Shaman",       role = "DAMAGER"},
    {class = "Shaman",       role = "HEALER"},
    {class = "Warlock",      role = "DAMAGER"},
    {class = "Warrior",      role = "DAMAGER"},
    {class = "Warrior",      role = "TANK"}
  }

  local classes = {}
  -- Collect all classes that match the given combat role
  for _, classRole in pairs( classRoles ) do
    if classRole.role == combatRole then
      table.insert( classes, classRole.class )
    end
  end
  -- Ensure there are valid classes for the given role
  if #classes > 0 then
    -- Select a random class from the list
    local randomIndex = math.random( #classes )
    return classes[randomIndex]
  else
    return nil -- In case no classes are found for the given role
  end
end

local function createDummyRoster()
  local tanks, healers, dps = getDummyComposition()
  local totalDummies        = tanks + healers + dps
  local dummyNames          = getNamesForDummies( totalDummies )
  for i = 1, totalDummies do
    local dummy = {
      name       = dummyNames and dummyNames[i],
      class      = getDummyClassByRole( "DAMAGER" ),
      combatRole = "DAMAGER"
    }
    if i <= tanks then
      dummy.combatRole = "TANK"
    elseif i <= tanks + healers then
      dummy.combatRole = "HEALER"
    end
    table.insert( Brutilities.dummyRoster, dummy )
  end
end
