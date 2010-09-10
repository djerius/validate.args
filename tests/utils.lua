require 'json'

function dump( pfx, x ) print( pfx .. ': ' .. json.encode( x ) ) end
function dump_keys( pfx, x )

   local keys = {}
   for k in pairs( x ) do
      table.insert( keys, k )
   end

   print( pfx .. table.concat( keys, ', ' ) )

end
