BH = {}

local function printTable( tbl, indent )
  indent = indent or 0
  local spacing = string.rep( "  ", indent ) -- Create a string of 2 spaces per indent level

  -- Check if the input is indeed a table
  if type( tbl ) ~= "table" then
    print( spacing .. tostring( tbl ) )
    return
  end
  print( spacing .. "{" )

  for k, v in pairs( tbl ) do
    -- Format the key
    local formattedKey
    if type( k ) == "string" then
      formattedKey = '["' .. k .. '"]'
    else
      formattedKey = "[" .. tostring( k ) .. "]"
    end
    -- Format the value
    if type( v ) == "table" then
      print( spacing .. "  " .. formattedKey .. " = " )
      printTable( v, indent + 1 ) -- Recursively print nested tables
    else
      local formattedValue
      if type( v ) == "string" then
        formattedValue = '"' .. tostring( v ) .. '"'
      else
        formattedValue = tostring( v )
      end
      print( spacing .. "  " .. formattedKey .. " = " .. formattedValue .. "," )
    end
  end
  print( spacing .. "}" )
end
