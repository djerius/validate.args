module( ..., package.seeall )

local validate = require( 'validate.args' ).validate

function test_not_table( )

   local template = { { 
			 validate = {
			    arg1 = { enum = { 'a', 'b' } },
			    arg2 = { type = 'number' },
			 }
		   } }

   local ok, foo = validate( template, 3 )

   assert_false( ok )
   assert_match('validate constraint is a table but argument is not' , foo )

end

function test_one_level( )

   local template = { { 
			 validate = {
			    arg1 = { enum = { 'a', 'b' } },
			    arg2 = { type = 'number' },
			 }
		   } }

   local ok, foo = validate( template, {
				arg1 = 'a',
				arg2 = 3
			     }
			  )

   assert_true( ok )
   assert_equal( 'a', foo.arg1 )
   assert_equal( 3, foo.arg2 )

end

function test_two_levels( )

   local template = { { 
			 validate = {
			    arg1 = { enum = { 'a', 'b' } },
			    arg2 = { type = 'number' },
			    arg3 = { type = 'table',
				     validate = {
					arg31 = { type = 'string' },
					arg32 = { type = 'function' },
					arg33 = { type = 'number',
						  default = 99 }
				     }
				  }
			 }
		   } }

   local ok, foo = validate( template, {
				arg1 = 'a',
				arg2 = 3,
				arg3 = { arg31 = 'foo',
					 arg32 = function() return 88.3 end,
				      }
			     }
			  )

   assert_true( ok )
   assert_equal( 'a', foo.arg1 )
   assert_equal( 3, foo.arg2 )
   assert_equal( 'foo', foo.arg3.arg31 )
   assert_function( foo.arg3.arg32)
   assert_equal( 88.3, foo.arg3.arg32() )
   assert_equal( 99, foo.arg3.arg33 )

end
