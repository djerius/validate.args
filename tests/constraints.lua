module( ..., package.seeall )

require 'string'

local validate = require( 'validate.args' ).validate


function test_validate_function ()

   local template = { { 
			 validate = function( val )
				       if val then
					  return val, val
				       else
					  return val, 'bad value'
				       end
				    end
		   }}

   local ok, foo = validate( template, true )


   assert_true( ok )
   assert_equal( true, foo )

   local ok, foo = validate( template, false )

   assert_false( ok )
   assert_match( 'bad value', foo );

end


local enum = { 'a', 3, 'c', 'd' }

function test_enum ()

   local template = { {
			 enum = enum
		   } }

   for _, v in pairs( enum ) do

      local ok, foo = validate( template, v  )

      assert_true( ok )
      assert_equal( v, foo, v )

   end

   local ok, foo = validate( template, 19 )
   assert_false( ok, 19 )

end
