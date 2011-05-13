module( ..., package.seeall )

va = require( 'validate.args' )
validate = va.validate
validate_opts = va.validate_opts

function test_default_function_true( )

   local template =  { { default = function() return true, 3 end,
			 optional = true
		      }
                     }


   local ok, foo = validate( template )

   assert_true( ok )
   assert_equal( 3, foo )

end

function test_default_function_false( )

   local template =  { { default = function() return false, 'bad dog' end,
			 optional = true
		      }
                     }


   local ok, foo = validate( template )

   assert_false( ok )
   assert_match( 'bad dog', foo )

end

