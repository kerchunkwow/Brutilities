-- #region: Import from Brute Helper Namespace (BH)
-- BH is the local namespace shared by all Lua files in the Brute Helper addon.
_, BH               = ...

local fr            = BH.fr
local eventHandlers = BH.eventHandlers

-- #endregion

-- Fires any time a target marker icon is changed and when players join/leave a group; not triggered
-- on death
-- https://warcraft.wiki.gg/wiki/RAID_TARGET_UPDATE
local function _RAID_TARGET_UPDATE()
end
eventHandlers["RAID_TARGET_UPDATE"] = _RAID_TARGET_UPDATE

-- Fires frequently for all events related to player Auras: buffs, debuffs, permanent affects, item
-- procs, etc. Data payload can include multiple events of type add, remove, or update (e.g., stacks)
-- https://warcraft.wiki.gg/wiki/UNIT_AURA
local function _UNIT_AURA( unit, auraData )
end
eventHandlers["UNIT_AURA"] = _UNIT_AURA

-- Fires when any AddOn finishes loading; useful for performing init/config functions that depend
-- upon a fully-loaded state (e.g., ensures all GUI objects are available)
-- https://warcraft.wiki.gg/wiki/ADDON_LOADED
local function _ADDON_LOADED( name, containsBindings )
end
eventHandlers["ADDON_LOADED"] = _ADDON_LOADED

-- Fired at the start of an instanced encounter; may be useful for loading certain encounter-specific
-- configurations
-- https://warcraft.wiki.gg/wiki/ENCOUNTER_START
local function _ENCOUNTER_START( encounterID, encounterName, difficultyID, groupSize )
end

-- Fires at the end of an instanced encounter
-- https://warcraft.wiki.gg/wiki/ENCOUNTER_END
local function _ENCOUNTER_END( encounterID, encounterName, difficultyID, groupSize, success )
end

-- Fires when a group or raid is formed or when any player joins or leaves a group or raid
-- https://warcraft.wiki.gg/wiki/GROUP_ROSTER_UPDATE
local function _GROUP_ROSTER_UPDATE()
end

-- Register all of the events in the eventHandlers table
for e in pairs( eventHandlers ) do
  fr:RegisterEvent( e )
end
-- On event, invoke handler
fr:SetScript( "OnEvent", function ( self, event, ... )
  eventHandlers[event]( ... )
end )
