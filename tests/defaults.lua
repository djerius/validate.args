module( ..., package.seeall )

va = require( 'validate.args' )
validate = va.validate
validate_opts = va.validate_opts

setup = _G.setup

function test_scalar( )

   local template = { { default = 3 } }

   local ok, foo = validate( template )

   assert_true( ok, foo )
   assert_equal( 3, foo )

end

function test_function( )

   local template = { { default = function() return true, 5;  end } }

   local ok, foo = validate( template )

   assert_true( ok, foo )
   assert_equal( 5, foo )

end


function test_vtable( )

   local template = { { optional = true,
			vtable = {
			   arg1 = { default = 1 },
			   arg2 = { default = 2 },
			}
		  } }

   -- make sure that an empty table works
   local ok, foo = validate( template, {} )

   assert_true( ok, foo )
   assert_equal( 1, foo.arg1 )
   assert_equal( 2, foo.arg2 )

   -- and an actual nil table too.
   local ok, foo = validate( template )

   assert_true( ok, foo )
   assert_equal( 1, foo.arg1 )
   assert_equal( 2, foo.arg2 )


end

function test_nested_vtable( )

   local template = { { optional = true,
			vtable = {
			   arg1 = { default = 1 },
			   arg2 = { default = 2 },
			   arg3 = {
			      optional = true,
			      vtable = {
				       arg1 = { default = 3.1 },
				       arg2 = { default = 3.2 },
				    },
				 }
			}
		  } }

   local ok, foo = validate( template )

   assert_true( ok, foo )
   assert_equal( 1, foo.arg1 )
   assert_equal( 2, foo.arg2 )
   assert_equal( 3.1, foo.arg3.arg1 )
   assert_equal( 3.2, foo.arg3.arg2 )

end

function test_nested_overrides( )

   local template = { { optional = true,
			vtable = {
			   arg1 = { default = 1 },
			   arg2 = { default = 2 },
			   arg3 = { vtable = { 
				       arg1 = { default = 3.1 },
				       arg2 = { default = 3.2 },
				    },
				    default = { arg1 = 3.3,
						arg2 = 3.4 },
				 }
			}
		  } }

   local ok, foo = validate( template )

   assert_true( ok, foo )
   assert_equal( 1, foo.arg1 )
   assert_equal( 2, foo.arg2 )
   assert_equal( 3.3, foo.arg3.arg1 )
   assert_equal( 3.4, foo.arg3.arg2 )

end
