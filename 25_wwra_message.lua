-- #region: Import from WWRA Namespace
-- WWRA is the local namespace shared by all Lua files in the WWRA AddOn
_, WWRA = ...

local consoleOut = WWRA.consoleOut
-- wwra_message.lua implements a message queueing system for cases where multiple messages
-- may need to be sent in quick succession and we want to avoid tripping Blizzard's spam prevention.

-- For this module, a message takes the form {msg, channel, recipient}:
-- msg: string; text to send
-- channel: string; chat channel to use; one of validChannel
-- recipient: string; name of player to send the message to; exclusively for WHISPERs

-- Table to hold the message queue and track its status
local messageQueue = {
  processing = false, -- Whether we're currently processing messages
  rate       = 0.25,  -- Time in seconds between successive sends
  queue      = {}     -- Queue of messages each in the form {msg, channel, recipient}
}

local validChannel = {
  ["RAID"]         = true,
  ["RAID_WARNING"] = true,
  ["PARTY"]        = true,
  ["GUILD"]        = true,
  ["OFFICER"]      = true,
  ["WHISPER"]      = true
}

-- A valid message is one in which validChannel[channel] is true, msg is a string not nil or empty,
-- and if channel is WHISPER, recipient is a string not nil or empty
local function validMessage( msg, channel, recipient )
  return validChannel[channel] and msg and msg ~= "" and (channel ~= "WHISPER" or (recipient and recipient ~= ""))
end

local function queueMessage( msg, channel, recipient )
  if not validMessage( msg, channel, recipient ) then
    consoleOut( "Invalid message in queueMessage: " .. msg, "err" )
    return
  end
end
