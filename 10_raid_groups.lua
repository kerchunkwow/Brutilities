-- #region: Import from Brutilities Namespace
_, Brutilities      = ...

local consoleOut    = Chunklib.consoleOut

local fr            = Brutilities.fr

local eventHandlers = Brutilities.eventHandlers
local slashCommands = Brutilities.slashCommands

-- #endregion

-- raid_groups.lua is a simple module designed to assist with inviting players to a raid based on
-- their status in the guild (and whether or not they are already in the raid).

-- A queue of names to issue raid invites to
local invitesSent   = 0
local inviteQueue   = {}

-- True when there are invites remaining in the queue to be processed
local function invitesPending()
  return #inviteQueue > 0
end

-- Check if a player is already waiting in the invite queue
local function inQueue( name )
  for _, queuedName in ipairs( inviteQueue ) do
    if queuedName == name then
      return true
    end
  end
  return false
end

-- Queue the named player for an invite
local function queueForInvite( name )
  table.insert( inviteQueue, name )
end

-- "Pop" the next player off of the queue and issue them an invite
local function sendNextInvite()
  local name = table.remove( inviteQueue, 1 ) -- Removes and returns the first element
  if name then
    C_PartyInfo.InviteUnit( name )
    invitesSent = invitesSent + 1
  end
end

-- This function should be called every 250ms while players remain queued; this function effectively
-- caps invites at one party prior to the raid conversion in order to avoid spamming the user with
-- party full errors; prior to raid formation this will effectively become a wait loop.
local function processInviteQueue()
  -- Cap total invites at 4 before raid conversion
  local maxInvites = IsInRaid() and 40 or 4

  -- Do nothing when no invites are pending
  if not invitesPending() then return end
  -- Send invites as long as we're not capped
  if invitesSent < maxInvites then
    sendNextInvite()
    C_Timer.After( 0.25, processInviteQueue )
  else
    -- While we're capped with invites pending, just wait and try again
    C_Timer.After( 0.25, processInviteQueue )
  end
end

-- Handle the first GROUP_FORMED event fired after the /rinvite command
local function _GROUP_FORMED()
  -- Convert the party to a raid and unregister from this event
  C_PartyInfo.ConvertToRaid()
  fr:UnregisterEvent( "GROUP_FORMED" )
  eventHandlers["GROUP_FORMED"] = nil
end

local function sendRaidInvites()
  -- Otherwise eligible members who should be excluded from raid invites
  local excluded = {
    ["Cowcowcowcow"] = true,
    ["Tridwr"]       = true,
    ["Ystwyth"]      = true,
    ["Frostycakes"]  = true,
  }

  -- If we're not currently in a raid, register for the first GROUP_FORMED event to trigger conversion;
  -- skip this if we're here again before the conversion event for some reason.
  if not IsInRaid() and not eventHandlers["GROUP_FORMED"] then
    eventHandlers["GROUP_FORMED"] = _GROUP_FORMED
    fr:RegisterEvent( "GROUP_FORMED" )
  end
  -- Ranks start at GM = 0 and count up; ranks less or equal to 6 are eligible to raid
  local raidRank = 6

  -- Check the roster for anyone who needs to be queued for an invite
  local totalMembers = GetNumGuildMembers()
  for i = 1, totalMembers do
    local name, _, rank, lvl, _, _, _, _, online, _, _, _, _, _, _, _, _ = GetGuildRosterInfo( i )

    -- Remove '-Hyjal' from names as invites work differently for players on our home server
    name = string.gsub( name, "-Hyjal", "" )

    local needsInvite = (rank <= raidRank) and (lvl == 80) and online and not excluded[name] and
        not UnitInRaid( name ) and not inQueue( name )

    if needsInvite then
      queueForInvite( name )
    end
  end
  -- Process queued invites (if any)
  processInviteQueue()
end

-- /rgroups to announce even/odd group assignments to the raid
local function announceGroups()
  -- Table to hold everyone's name by raid-half
  local half = {
    odds  = {players = {}, tank = ""},
    evens = {players = {}, tank = ""}
  }

  -- Use the group index returned from GetRaidRosterInfo to report on everyone's position
  for i = 1, 40 do
    local name, _, group, _, _, _, _, online, _, role, _ = GetRaidRosterInfo( i )

    -- Organize the names of players based on their current group and role assignments
    if name and online then
      -- If your group divided by 2 has a remainder, you're odd
      local halfString = (group % 2 == 1) and "odds" or "evens"
      if role == "MAINTANK" then
        -- It's important that tanks know how important they are or they tend to get cranky
        half[halfString].tank = name
      else
        -- The rest of the filthy casuals can be lumped together
        table.insert( half[halfString].players, name )
      end
    end
  end
  -- Once we have lists of raider names by group/half membership, we can report
  for subgroup, group in pairs( half ) do
    -- Assumes {moon} and {square} are standard marks for the odd/even tank respectively
    local mark = subgroup == "odds" and "{moon}" or "{square}"
    -- Each announcement string starts with the half's tank then a comma-separated list of players
    local groupAnnounce = string.format( "%s: %s %s, %s",
      string.upper( subgroup ),
      mark,
      group.tank,
      table.concat( group.players, ", " ) )
    -- Announce each halves roster via /rw
    SendChatMessage( groupAnnounce, "RAID_WARNING" )

    -- -- This was supposed to whisper everyone about their group membership but Blizzard got mad
    -- -- at me so I'll have to figure something else out.
    -- local whisperMsg = string.format( "You are with the %s group. Your tank is %s %s.",
    --   string.upper( subgroup ),
    --   mark,
    --   group.tank )

    -- for _, player in ipairs( group.players ) do
    --   SendChatMessage( whisperMsg, "WHISPER", nil, player )
    --   -- e.g., "You are with the ODDS group. Your tank is {moon}Alkaeis."
  end
end

-- /rsummons will request a summons in RAID for anyone in raid but not currently in the same zone
-- ! IDEA ! A smarter implementation would figure out which raid zone people are in or near
-- and compare against that so the command could be issued from anywhere (and for self summons);
-- [ TODO ] Currently assumes we are in the raid with a Warlock; will need to be adjusted to support
-- summoning stones which are in a different zone than their associated raid
local function requestSummons()
  local ourZone       = GetRealZoneText()
  local summonsNeeded = false
  local needsSummon   = {}

  -- Make a list of everyone in a different zone than us
  for i = 1, 40 do
    local unit = "raid" .. i
    local name, _, _, _, class, _, theirZone, online, _, _, _, _, _, _, _ = GetRaidRosterInfo( i )
    local inZone = (theirZone == ourZone)
    local pendingSummon = C_IncomingSummon.HasIncomingSummon( unit )
    if name and online and not inZone then
      if pendingSummon then
        -- Attach a tag to anyone who has a pending summon; we still want to announce their name
        -- if they haven't accepted.
        name = name .. "|r (pending)"
      end
      summonsNeeded = true
      needsSummon[name] = class
    end
  end
  if summonsNeeded then
    local names = {}
    for name, _ in pairs( needsSummon ) do
      table.insert( names, name )
    end
    local summonRequest = table.concat( names, ", " )
    -- If request isn't an empty string, send it to RAID chat
    if summonRequest ~= "" then
      summonRequest = "Summons needed: " .. summonRequest
      SendChatMessage( summonRequest, "RAID_WARNING" )
    end
  end
end

-- #region: Namespace Export, Command & Event Registration

slashCommands["RAID_SUMMONS"]        = {cmd = {"/rsummons"}, func = requestSummons}
slashCommands["ANNOUNCE_RAIDGROUPS"] = {cmd = {"/rgroups"}, func = announceGroups}
slashCommands["RAID_INVITE"]         = {cmd = {"/rinvite"}, func = sendRaidInvites}

-- #endregion
