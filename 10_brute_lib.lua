-- brute_lib.lua adds "standard library" functions not natively supported in Lua 5.1
_, BH = ...

-- Remove leading & trailing whitespace from a string
local function trim( s )
  return s:match( "^%s*(.-)%s*$" )
end

-- Check for a value in a table
local function isInTable( value, tbl )
  for _, v in ipairs( tbl ) do
    if v == value then
      return true
    end
  end
  return false
end

-- Use if you don't think "next" is a good indicator when testing for emptiness
local function isEmpty( tbl )
  return next( tbl ) == nil
end
