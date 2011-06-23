module( ..., package.seeall )

require 'string'

local validate = require( 'validate.args' ).validate


function test_callback_pre_static ()

   local value
   local name


   local template = { {
			 name = 'foo',
			 precall = function( val, args )
					   value = val
					   name = tostring(args.name)
					end
		      }
		   }

   local ok, foo = validate( template, 'frank' )


   assert_true( ok, foo )
   assert_equal( 'frank', foo )
   assert_equal( 'frank', value )
   assert_equal( 'arg#1(foo)', name )

end

function test_callback_pre_mutate ()

   local template = { {
			 name = 'foo',
			 precall = function( val, args )
					   return true, 'helga'
					end
		      }
		   }

   local ok, foo = validate( template, 'frank' )


   assert_true( ok, foo )
   assert_equal( 'helga', foo )

end

function test_callback_post_static ()

   local value
   local name


   local template = { {
			 name = 'foo',
			 postcall = function( val, args )
					    value = val
					    name = tostring(args.name)
					 end
		      }
		   }

   local ok, foo = validate( template, 'frank' )


   assert_true( ok, foo )
   assert_equal( 'frank', foo )
   assert_equal( 'frank', value )
   assert_equal( 'arg#1(foo)', name )


end


function test_callback_post_mutate ()

   local value
   local name


   local template = { {
			 name = 'foo',
			 enum = { 'frank' },
			 postcall = function( val, args )
					    assert_equal( 'frank', val)
					    return true, 'helga'
					 end
		      }
		   }

   local ok, foo = validate( template, 'frank' )
   assert_true( ok, foo )
   assert_equal( 'helga', foo )

end


