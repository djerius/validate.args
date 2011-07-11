module( ..., package.seeall )

local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

require 'string'

setup = _G.setup

function test_scalar_multiple ()

   local spec = { x = { multiple = false } }
   local ok, foo = validate( spec, { x = 3 } )

   assert_true( ok, foo )
   assert_equal( 3, foo.x )
end

function test_table_multiple_scalar_value ()

   local spec = { x = { multiple = true } }

   local ok, foo = validate( spec, { x = 3 } )

   assert_false( ok )
   assert_match( 'must be a table', foo )
end

function test_array_multiple ()

   local spec = { x = { type = 'posint',
			multiple = true,
		     }
	       }
   local ok, foo = validate( spec, { x = { 1, 2, 3 } } )

   assert_true( ok, foo )

   assert_equal( 3, foo.x[3] )

end

function test_nested_array_multiple ()

   local spec = { x = { vtable = { { type = 'posint' }, { type = 'posint' } },
			multiple = true,
		     }
	       }
   local ok, foo = validate( spec, { x = {
					{ 1, 2 },
					{ 4, 5 },
				     }
				  }
			  )

   assert_true( ok, foo )

   assert_equal( 2, foo.x[1][2] )
   assert_equal( 5, foo.x[2][2] )

end

function test_nelem_bounds ()

   local spec = { x = { type = 'posint',
			multiple = { min = 3, max = 5 }
		     }
	       }

   local ok, foo = validate( spec, { x = { 1, 6 }  } )

   assert_false( ok, foo )
   assert_match( 'too few', foo )

   local ok, foo = validate( spec, { x = { 1, 2, 3 }  } )
   assert_true( ok, foo )

   local ok, foo = validate( spec, { x = { 1, 2, 3, 4}  } )
   assert_true( ok, foo )

   local ok, foo = validate( spec, { x = { 1, 2, 3, 4, 5 }  } )
   assert_true( ok, foo )

   local ok, foo = validate( spec, { x = { 1, 2, 3, 4, 5, 6 }  } )

   assert_false( ok, foo )
   assert_match( 'too many', foo )

end

function test_exact_nelem ()

   local spec = { x = { type = 'posint',
			multiple = { n = 4 }
		     }
	       }

   local ok, foo = validate( spec, { x = { 1, 2 }  } )

   assert_false( ok, foo )
   assert_match( 'incorrect number', foo )

   local ok, foo = validate( spec, { x = { 1, 2, 3, 4 }  } )

   assert_true( ok, foo )

end

function test_allow_scalar ()

   local spec = { x = { type = 'posint',
			multiple = { n = 4 }
		     }
	       }

   local ok, foo = validate( spec, { x =  1 } )

   assert_false( ok, foo )
   assert_match( 'must be a table', foo )

   local spec = { x = { type = 'posint',
			multiple = { allow_scalar = true, n = 4 }
		     }
	       }

   local ok, foo = validate( spec, { x = 1 } )
   assert_false( ok, foo )
   assert_match( 'incorrect number', foo )

   local ok, foo = validate( spec, { x = { 1, 2, 3, 4 }  } )

   assert_true( ok, foo )


end

function test_keys ()

   local spec = { x = { type = 'posint',
			multiple = {
			   keys = { vfunc = function( val )
					       if type(val) == 'string' and val:match( '^%a+$' ) then
						  return true, val
					       else
						  return false, "only alpha characters allowed"
					       end
					    end,
				 }
			},
		     }
	       }

   local ok, foo = validate( spec, { x = { a = 1, b = 2 }  } )

   assert_true( ok, foo )

   local ok, foo = validate( spec, { x = { a1 = 1, b = 2 }  } )

   assert_false( ok, foo )
   assert_match( 'only alpha', foo )

end

function test_bad_spec()
   local spec = { x = { type = 'posint',
			multiple = 'snack',
		     }
	       }

   local ok, foo = pcall( validate, spec, { x = { a = 1, b = 2 }  } )

   assert_false( ok, foo )

end
