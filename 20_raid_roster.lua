-- #region: Import from Brutilities Namespace
_, Brutilities           = ...

local slashCommands      = Brutilities.slashCommands

-- Local reference to global table to hold data about current raid roster
local currentRaiders     = Brutilities.currentRaiders

local consoleOut         = Chunklib.consoleOut

-- #endregion

-- The goal of raid_roster.lua is to add raid roster management and sorting functionality customized
-- for The Brute Squad; it's primary function is sorting the raid roster into balanced groups for
-- encounters that require an "even/odd" split.

-- Note: A player's raid index is determined by the order in which they join a raid, not by their
-- current position in the raid; so relocated players will not have a new index unless they
-- leave and rejoin the raid. Assigned indices can still be used to sort players into desired
-- groups.

-- Keep track of which indices have been assigned to raiders
local assignedIndices    = {}

-- #region Getter functions to interact with the index-group-half mapping tables

-- Lists of which raid groups belong to which half of the raid (even/odd)
local raidGroupsByHalf   = {
  ["odd"] = {1, 3, 5, 7},
  ["even"] = {2, 4, 6, 8},
}

-- Lists of the raid indices that belong to each raid group
local raidIndicesByGroup = {
  [1] = {1, 2, 3, 4, 5},
  [2] = {6, 7, 8, 9, 10},
  [3] = {11, 12, 13, 14, 15},
  [4] = {16, 17, 18, 19, 20},
  [5] = {21, 22, 23, 24, 25},
  [6] = {26, 27, 28, 29, 30},
  [7] = {31, 32, 33, 34, 35},
  [8] = {36, 37, 38, 39, 40},
}

-- Lists of the raid indices that belong to each half of the raid (even/odd)
local raidIndicesByHalf  = {
  ["odd"] = {1, 2, 3, 4, 5, 11, 12, 13, 14, 15, 21, 22, 23, 24, 25, 31, 32, 33, 34, 35},
  ["even"] = {6, 7, 8, 9, 10, 16, 17, 18, 19, 20, 26, 27, 28, 29, 30, 36, 37, 38, 39, 40},
}

-- Return a list of all the raid indices that belong to a particular group
local function getIndicesByGroup( group )
  -- If the parameter is passed as a string, convert it before indexing the table
  if type( group ) ~= "number" then
    group = tonumber( group )
  end
  return raidIndicesByGroup[group]
end

-- Return the group number that a specific raid index belongs to
local function getGroupByIndex( index )
  for group, indices in pairs( raidIndicesByGroup ) do
    for _, idx in ipairs( indices ) do
      if idx == index then
        return group
      end
    end
  end
  return nil -- Index not found
end

-- Return the half of the raid that a specific raid index belongs (even or odd)
local function getHalfByIndex( index )
  for half, indices in pairs( raidIndicesByHalf ) do
    for _, idx in ipairs( indices ) do
      if idx == index then
        return half
      end
    end
  end
  return nil -- Index not found
end

-- Return a list of all the raid indices that belong to a particular half (even or odd)
local function getIndicesByHalf( half )
  return raidIndicesByHalf[half] or {}
end

-- #endregion

-- #region Functions to manage the assignment of indices to raiders

-- Check whether a specific index has been assigned to a player
local function isIndexAssigned( index )
  return assignedIndices[index] ~= nil
end

-- Get the number of the highest group which has at least one onoccupied index
local function getHighestNonfullGroup()
  local group = 8
  while group > 0 do
    local groupIndices = getIndicesByGroup( group )
  end
end

-- Determine whether the named raider has been assigned an index
local function hasAssignedIndex( raider )
  return raider.assignedIndex and raider.assignedIndex > 0
end

-- Set all raiders' assignedIndex property to -1 and clear out any tables we use to track assignments;
-- can be used at the start of a sort or if a restart is needed.
local function initializeIndexAssignments()
  for _, raider in pairs( currentRaiders ) do
    raider.assignedIndex = -1
  end
  assignedIndices = {}
end

-- Return the lowest-numbered index in the raid (1-40) which has not yet been assigned to a player
local function getLowestUnassignedIndex()
  for index = 1, 40 do
    if not isIndexAssigned( index ) then
      return index
    end
  end
  return nil -- No unassigned index available
end

-- Return the lowest-numbered unassigned index in the specified half (even or odd)
local function getLowestUnassignedIndexByHalf( half )
  local indices = getIndicesByHalf( half )
  table.sort( indices )
  for _, index in ipairs( indices ) do
    if not isIndexAssigned( index ) then
      return index
    end
  end
  return nil -- No unassigned index in this half
end

-- Return the lowest-numbered unassigned index in the specified group (1-8)
local function getLowestUnassignedIndexByGroup( group )
  local indices = getIndicesByGroup( group )
  table.sort( indices )
  for _, index in ipairs( indices ) do
    if not isIndexAssigned( index ) then
      return index
    end
  end
  return nil -- No unassigned index in this group
end

-- Return the current index and corresponding group number of a raider based on their actual
-- position to validate and plan moves
local function getPositionByName( name )
  for i = 1, 40 do
    local raiderName, _, subgroup, _, _, _, _, _, _, _, _, _ = GetRaidRosterInfo( i )
    if raiderName == name then
      return i, subgroup
    end
  end
end

-- #endregion

-- #region Assign indices to raiders in the roster to establish class and role balance

-- Ideally, only one healer should be assigned to each group; this function should return the group
-- number of the first group non-full group in that half of the raid which does not already have
-- a healer assigned to one of its indices.
local function getFirstGroupWithoutHealer( half )
  local groups = raidGroupsByHalf[half]
  for _, group in ipairs( groups ) do
    local indices = getIndicesByGroup( group )
    local hasHealer = false
    local groupFull = true

    for _, index in ipairs( indices ) do
      if not isIndexAssigned( index ) then
        groupFull = false
      else
        local assignedRaiderName = assignedIndices[index]
        local assignedRaider = currentRaiders[assignedRaiderName]
        if assignedRaider and assignedRaider.combatRole == "HEALER" then
          hasHealer = true
        end
      end
    end
    if not groupFull and not hasHealer then
      return group
    end
  end
  return nil -- No suitable group found
end

-- Returns the count of players currently assigned to the specified half.
local function getPlayerCount( half )
  local count = 0
  for _, raider in pairs( currentRaiders ) do
    if hasAssignedIndex( raider ) then
      local assignedHalf = getHalfByIndex( raider.assignedIndex )
      if assignedHalf == half then
        count = count + 1
      end
    end
  end
  return count
end

-- Returns the count of players currently assigned to the specified role in the specified half.
local function getRoleCount( role, half )
  local count = 0
  for _, raider in pairs( currentRaiders ) do
    if raider.combatRole == role and hasAssignedIndex( raider ) then
      local assignedHalf = getHalfByIndex( raider.assignedIndex )
      if assignedHalf == half then
        count = count + 1
      end
    end
  end
  return count
end

-- To support the sorting of healers and DPS in a manner that achieves as close to optimal raid
-- balance as possible, this function counts how many of a specific player class exist in the
-- specified raid half.
local function getClassCount( class, half )
  local count = 0
  for _, raider in pairs( currentRaiders ) do
    if raider.class == class and hasAssignedIndex( raider ) then
      local assignedHalf = getHalfByIndex( raider.assignedIndex )
      if assignedHalf == half then
        count = count + 1
      end
    end
  end
  return count
end

-- When assigning DPS, use this function to identify which half to assign the player to; the function
-- uses this logic:
-- 1. If the halves have different numbers of players, return the half with fewer players
-- 2. If numbers are balanced, return the half with fewer players in this role
-- 3. If numbers and role are balanced, return the half with fewer players of this class
local function getOptimalHalfForNextAssignment( role, class )
  local oddPlayerCount = getPlayerCount( "odd" )
  local evenPlayerCount = getPlayerCount( "even" )

  if oddPlayerCount < evenPlayerCount then
    return "odd"
  elseif evenPlayerCount < oddPlayerCount then
    return "even"
  else
    -- Player counts are equal, check role counts
    local oddRoleCount = getRoleCount( role, "odd" )
    local evenRoleCount = getRoleCount( role, "even" )

    if oddRoleCount < evenRoleCount then
      return "odd"
    elseif evenRoleCount < oddRoleCount then
      return "even"
    else
      -- Role counts are equal, check class counts
      local oddClassCount = getClassCount( class, "odd" )
      local evenClassCount = getClassCount( class, "even" )

      if oddClassCount < evenClassCount then
        return "odd"
      elseif evenClassCount < oddClassCount then
        return "even"
      else
        -- All counts are equal, default to "odd"
        return "odd"
      end
    end
  end
end

-- Get the optimal "next half" for a damager assignment, then return the lowest index in that half
local function getNextIndexForDamager( class )
  local half = getOptimalHalfForNextAssignment( "DAMAGER", class )
  return getLowestUnassignedIndexByHalf( half )
end

-- Get the optimal group for the next healer assignment, then return the lowest numbered index in
-- that group.
local function getNextIndexForHealer( class )
  local half  = getOptimalHalfForNextAssignment( "HEALER", class )
  local group = getFirstGroupWithoutHealer( half )
  return getLowestUnassignedIndexByGroup( group )
end

-- #endregion

-- Clear any existing raider data from the currentRaiders table without breaking the reference to
-- the global table
local function clearRoster()
  for key in pairs( currentRaiders ) do
    currentRaiders[key] = nil
  end
end

-- Use GetRaidRosterInfo to retrieve data about the current roster that will be needed for sorting;
-- it may be necessary to store this in a table defined such that it is available elsewhere in the
-- module.
local function getCurrentRosterData()
  clearRoster()
  for i = 1, 40 do
    local name, _, subgroup, _, class, _, _, online, _, _, _, combatRole = GetRaidRosterInfo( i )
    if (name and name ~= "") then
      consoleOut( "Adding " .. name .. " to raiders table", "info" )
      currentRaiders[name] = {
        name          = name,
        index         = i,
        group         = subgroup,
        class         = class,
        online        = online,
        combatRole    = combatRole,
        assignedIndex = -1,
      }
    end
  end
end

-- Following the rules laid out in the Raid Composition, Player Roles, and Class Balance section, this
-- function should assign each player a destination index based on their class and role
local function assignNewIndices()
  -- Initialize assignments or reset existing ones
  initializeIndexAssignments()

  -- Tables to segment raiders by role
  local tanks = {}
  local healers = {}
  local dps = {}

  for _, raider in pairs( currentRaiders ) do
    if raider.combatRole == "TANK" then
      table.insert( tanks, raider )
    elseif raider.combatRole == "HEALER" then
      table.insert( healers, raider )
    else -- "DAMAGER"
      table.insert( dps, raider )
    end
  end
  -- Assign tanks to indices 1 and 6 (groups 1 and 2)
  -- First, sort the tank table alphabetically by name
  table.sort( tanks, function ( a, b ) return a.name < b.name end )
  local tankIndices = {1, 6}
  for i, raider in ipairs( tanks ) do
    local index = tankIndices[i]
    if index then
      raider.assignedIndex = index
      assignedIndices[index] = raider.name
    else
      consoleOut( "Raid has more than 2 tanks.", "err" )
    end
  end
  -- Assign healers
  -- First, sort the healer table alphabetically by class
  table.sort( healers, function ( a, b ) return a.class < b.class end )
  for _, raider in ipairs( healers ) do
    local index = getNextIndexForHealer( raider.class )
    if index then
      raider.assignedIndex = index
      assignedIndices[index] = raider.name
    else
      consoleOut( "No index available for HEALER: " .. raider.name, "err" )
    end
  end
  -- Assign DPS
  table.sort( dps, function ( a, b ) return a.class < b.class end )
  for _, raider in ipairs( dps ) do
    local index = getNextIndexForDamager( raider.class )
    if index then
      raider.assignedIndex = index
      assignedIndices[index] = raider.name
    else
      consoleOut( "No index available for DAMAGER: " .. raider.name, "err" )
    end
  end
end

-- If necessary, validate assignments after assignNewIndices(); ensure that:
-- 1. Every raider has an assignedIndex > 0
-- 2. No two indices have been assigned to the same player
local function validateAssignments()
  local assigned = {}
  for _, raider in pairs( currentRaiders ) do
    if raider.assignedIndex <= 0 then
      consoleOut( raider.name .. " has no assigned index.", "err" )
      return false
    end
    if assigned[raider.assignedIndex] then
      consoleOut( raider.assignedIndex .. " assigned to multiple raiders.", "err" )
      return false
    end
    assigned[raider.assignedIndex] = true
  end
  return true
end

-- Like Vacate Group but specifically moves anyone in Group 8 into group 7
local function clearGroup8()
  local group = 8
  for i = 1, 40 do
    local name, _, subgroup, _, _, _, _, _, _, _, _, _ = GetRaidRosterInfo( i )
    if (name and name ~= "") and (subgroup and subgroup == group) then
      SetRaidSubgroup( i, 7 )
    end
  end
end

-- Once a group has been vacated, find everyone who belongs in this group and swap them into it
local function fillVacantGroup( group )
  -- Convert the chat-command parameter
  group = tonumber( group )

  -- Create a local table of raiders who need to be moved to the specified group
  local raidersToMove = {}
  for name, data in pairs( currentRaiders ) do
    if data.assignedIndex and data.assignedIndex > 0 then
      local assignedGroup = getGroupByIndex( data.assignedIndex )
      if assignedGroup == group then
        table.insert( raidersToMove, {name = name, data = data} )
      end
    end
  end
  -- Sort the table by assignedIndex
  table.sort( raidersToMove, function ( a, b )
    return a.data.assignedIndex < b.data.assignedIndex
  end )

  -- Helper function to get the current index of a raider in the raid roster
  local function getCurrentIndex( name )
    for i = 1, 40 do
      local raiderName = GetRaidRosterInfo( i )
      if raiderName == name then
        return i
      end
    end
  end

  local function validateMove( name )
  end

  -- Move each raider in `raidersToMove` to the specified group
  for _, raider in ipairs( raidersToMove ) do
    local name = raider.name
    consoleOut( "Attempting to move " .. name .. " to group " .. group )
    local currentIndex = getCurrentIndex( name )
    if currentIndex then
      consoleOut( "Moving " .. name .. " from " .. currentIndex .. " to " .. group, "info" )
      ---@diagnostic disable-next-line: param-type-mismatch
      SetRaidSubgroup( currentIndex, group )
    else
      consoleOut( "Could not find current index for " .. name, "warning" )
    end
  end
  -- Call clearGroup8() 0.25s after this
  C_Timer.After( 0.25, clearGroup8 )
end

-- Find anyone currently in the specified group and temporarily move them into Group 8 to make
-- room for assigned players.
local function vacateGroup( group )
  group = tonumber( group )
  for i = 1, 40 do
    local name, _, subgroup, _, _, _, _, _, _, _, _, _ = GetRaidRosterInfo( i )
    if (name and name ~= "") and (subgroup and subgroup == group) then
      consoleOut( "Vacating " .. name .. " from group " .. group, "info" )
      SetRaidSubgroup( i, 8 )
    end
  end
end

local function printAssignments()
  local classColor = Chunklib.classColor
  local hl = Chunklib.highlightString
  -- Gather raiders into a list
  local sortedRaiders = {}
  for name, data in pairs( currentRaiders ) do
    table.insert( sortedRaiders,
      {name = name, assignedIndex = data.assignedIndex, class = data.class} )
  end
  -- Sort the list by assignedIndex
  table.sort( sortedRaiders, function ( a, b )
    return a.assignedIndex < b.assignedIndex
  end )

  -- Print raiders in sorted order
  for _, raider in ipairs( sortedRaiders ) do
    local nameColor = classColor( raider.class )
    if not nameColor then
      consoleOut( "Couldn't find color for: " .. raider.name .. ", " .. raider.class, "err" )
      nameColor = "|cFFFFFFFF"
    end
    local nameString = nameColor .. raider.name .. "|r: "
    local grp = getGroupByIndex( raider.assignedIndex )
    -- Set local hlc to "royal_blue" of group is even, "yellow_green" if odd
    local hlc = grp % 2 == 0 and "royal_blue" or "yellow_green"
    local index_string = " [" .. raider.assignedIndex .. "]"
    local group_string = hl( " Group " .. grp .. index_string, hlc )


    consoleOut( nameString .. group_string )
  end
end

-- "Main" sort function to invoke the sort process in the correct order
local function sortRaid()
  consoleOut( "Sorting raid" )
  getCurrentRosterData()
  assignNewIndices()
  validateAssignments()
end

-- #region: Export to Brutilities Namespace; Command & Event Registration

slashCommands["SORT_RAID"]                = {cmd = {"/rsort"}, func = sortRaid}
slashCommands["PRINT_SORT"]               = {cmd = {"/printsort"}, func = printAssignments}

Brutilities.slashCommands["VACATE_GROUP"] = {
  cmd = {"/vac"},
  func = function ( group )
    vacateGroup( group )
  end
}

Brutilities.slashCommands["FILL_GROUP"]   = {
  cmd = {"/fill"},
  func = function ( group )
    fillVacantGroup( group )
  end
}
-- #endregion
