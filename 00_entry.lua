-- #region: Import from Brutilities Namespace
_, Brutilities             = ...

-- Reference to Chunklib shared library
Chunklib                   = Chunklib or {}

Brutilities.slashCommands  = {}
Brutilities.eventHandlers  = {}
-- #endregion

Brutilities.fr             = Brutilities.fr or CreateFrame( "Frame" )

-- Table to accumulate event->handler pairs so they can be registered by wwra_reg.lua
Brutilities.eventHandlers  = {}

-- Table to accumulate slash command->function pairs so they can be registered by wwra_reg.lua
Brutilities.slashCommands  = {}

Brutilities.currentRaiders = {}
