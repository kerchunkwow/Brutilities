-- #region: Import from Brutilities Namespace
_, Brutilities    = ...

local trimName    = Chunklib.trimName
local consoleOut  = Chunklib.consoleOut
-- #endregion

-- raid_marks.lua implements "sticky" player marking within a raid to ensure that certain marks
-- remain assigned to specific players and to reclaim them if they are moved or resassigned by
-- other players or addons.

-- Only players in the raid are eligible for sticky marks.
-- Only marks 0-7 are eligible for sticking; skull cannot be stuck.

-- Get the "official" name (token) for each raid marker by their unique in-game id/index
local markNames   = {
  [1] = "star",
  [2] = "circle",
  [3] = "diamond",
  [4] = "triangle",
  [5] = "moon",
  [6] = "square",
  [7] = "cross",
  [8] = "skull",
}

-- Get the index of a mark by its name or alias
local markIndices = {
  star     = 1,
  yellow   = 1,
  circle   = 2,
  orange   = 2,
  condom   = 2,
  diamond  = 3,
  purple   = 3,
  triangle = 4,
  green    = 4,
  moon     = 5,
  silver   = 5,
  tank1    = 5,
  oddtank  = 5,
  square   = 6,
  tank2    = 6,
  eventank = 6,
  blue     = 6,
  box      = 6,
  cross    = 7,
  red      = 7,
  x        = 7,
}

-- Map player names to the index of the mark they're stuck to
local playerMarks = {}

-- If the player's current target is a valid recipient of sticky marks, return their name w/o realm,
-- otherwise nil.
local function nameIfValidTarget()
  if UnitExists( "target" ) and UnitIsPlayer( "target" ) and UnitInRaid( "target" ) then
    return trimName( UnitName( "target" ) )
  end
  return nil
end

-- If the parameter is valid index for marking or the name or alias of a valid index, return that
-- index; else nil
local function indexIfValidMark( mark )
  if type( mark ) == "number" and mark > 0 and mark < 8 then
    return mark
  end
  if type( mark ) == "string" then
    local lowerMark = string.lower( mark )
    return markIndices[lowerMark]
  end
  return nil
end

-- Having validated the target and mark, this function will assign the mark to the target, clearing
-- any previous settings for either this player or the mark
local function stickMark( markIndex, name )
  -- If stick is called for a player that already has the mark in question, clear the assignment
  -- and unmark that player.
  if playerMarks[name] and playerMarks[name] == markIndex then
    playerMarks[name] = nil
    SetRaidTarget( name, 0 )
    return
  end
  playerMarks[name] = markIndex
  -- Set the mark in game
  SetRaidTarget( name, markIndex )
end

-- Restick all currently assigned marks, useful on reload until we can set up a saved variable
-- persistence model.
local function stickAllCurrentMarks()
  for i = 1, 40 do
    local currentMark = GetRaidTargetIndex( "raid" .. i )
    local currentName = trimName( UnitName( "raid" .. i ) )
    local validName = currentName and currentName ~= ""
    local validMark = currentMark and currentMark > 0 and currentMark < 8
    if validName and validMark then
      playerMarks[currentName] = currentMark
    end
  end
end

-- Invoked any time a raid target mark is moved or removed; verifies all assigned marks are still
-- assigned to their respective players.
local function validateAndReclaimMarks()
  consoleOut( "Validating Sticky Marks...", "sys" )
  for player, markIndex in pairs( playerMarks ) do
    if GetRaidTargetIndex( player ) ~= markIndex then
      SetRaidTarget( player, markIndex )
    end
  end
end

-- /stick with no target sends a report of stuck marks to officer chat
local function stickReport()
  local report = ""
  for playerName, markIndex in pairs( playerMarks ) do
    -- Get the token/name of the mark and wrap it in braces so it displays graphically in game
    local markToken = "{" .. markNames[markIndex] .. "}"
    local msg = playerName .. " = " .. markToken
    -- Append each msg to report, separating with commas after the first
    report = report .. (report == "" and "" or ", ") .. msg
  end
  -- If report is not an empty string, send it to officer chat
  if report ~= "" then
    report = "Sticky marks: " .. report
    SendChatMessage( report, "OFFICER" )
  end
end

-- Handle /stick commands with an optional mark parameter
local function handleStickCommand( mark )
  local target = nameIfValidTarget()
  -- If target is valid and no mark parameter was given, see if the target has a mark
  if target and (not mark or mark == "") then
    consoleOut( "Checking current mark on: " .. target )
    mark = GetRaidTargetIndex( "target" )
  end
  local markIndex = indexIfValidMark( mark )
  if not target then
    stickReport()
  elseif markIndex then
    stickMark( markIndex, target )
  end
end

-- On RAID_TARGET_UPDATE, validate and reclaim any moved or reassigned marks
-- [ TODO ] Other events may require similar validation such as logout, leave raid, etc.;
-- for now
local function _RAID_TARGET_UPDATE()
  validateAndReclaimMarks()
end

-- #region: Export to Brutilities Namespace; Command & Event Registration

Brutilities.slashCommands["STICK"] = {
  cmd = {"/stick"},
  func = function ( mark )
    handleStickCommand( mark )
  end
}

Brutilities.slashCommands["STICK_REPORT"] = {
  cmd = {"/stickrep"},
  func = function ()
    stickReport()
  end
}

Brutilities.eventHandlers["RAID_TARGET_UPDATE"] = _RAID_TARGET_UPDATE

Brutilities.stickAllCurrentMarks = stickAllCurrentMarks

-- #endregion
