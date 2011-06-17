module( ..., package.seeall )

require 'string'

local validate = require( 'validate.args' ).validate


function test_validate_function ()

   local template = { {
			 name = 'foo',
			 vfunc = function( val, args )

				    if val then
				       return true, val
				    else
				       return false, args.name
				    end
				 end
		   }}

   local ok, foo = validate( template, true )


   assert_true( ok )
   assert_equal( true, foo )

   local ok, foo = validate( template, false )

   assert_false( ok )
   assert_match( 'arg#1%(foo%): arg#1%(foo%)', foo );

end


function test_enum_list ()

   local template = { {
			 enum = { 'a', 3, 'c', 'd' }
		   } }

   for _, v in pairs( template[1].enum ) do

      local ok, foo = validate( template, v  )

      assert_true( ok )
      assert_equal( v, foo, v )

   end

   local ok, foo = validate( template, 19 )
   assert_false( ok )

end

function test_enum_scalar ()

   local ok, foo = validate( { { enum = 19 } } , 19 )

   assert_true( ok )
   assert_equal( 19, foo )

   local ok, foo = validate( { enum = 19 } , 18 )

   assert_false( ok )

end
