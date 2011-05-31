module( ..., package.seeall )

va = require( 'validate.args' )
validate = va.validate
validate_opts = va.validate_opts

setup = _G.setup

function test_invalid_oneplus_of( )

   local template = { arg1 = { optional = true },
		      arg2 = { optional = true },
		      ['%oneplus_of'] = { 'arg1', 'arg2' },
		   }


   local ok, foo = validate_opts( { error_on_bad_spec = false },
				 template, { arg1 = 1 } )
   assert_false( ok, 'bad spec' )
end

function test_unknown_special( )

   local template = { arg1 = { optional = true },
		      arg2 = { optional = true },
		      ['%say_what'] = { 'arg1', 'arg2' },
		   }


   local ok, foo = validate_opts( { error_on_bad_spec = false},
				 template, { arg1 = 1 } )
   assert_false( ok, 'bad spec' )
end


function test_oneplus_of( )

   local template = { arg1 = { optional = true },
		      arg2 = { optional = true },
		      ['%oneplus_of'] = { { 'arg1', 'arg2' } },
		   }


   local ok, foo = validate( template, { arg1 = 1 } )
   assert_true( ok, 'arg1 only' )


   local ok, foo = validate( template, { arg2 = 1 } )
   assert_true( ok, 'arg2 only'  )

   local ok, foo = validate( template, { } )
   assert_false( ok, 'no arguments' )

end

function test_one_of( )

   local template = { arg1 = { optional = true },
		      arg2 = { optional = true },
		      ['%one_of'] = { { 'arg1', 'arg2' } },
		   }


   local ok, foo = validate( template, { arg1 = 1 } )
   assert_true( ok, 'arg1 only' )


   local ok, foo = validate( template, { arg2 = 1 } )
   assert_true( ok, 'arg2 only'  )

   local ok, foo = validate( template, { } )
   assert_false( ok, 'no arguments' )

   local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )
   assert_false( ok, 'both arguments' )

end

function test_sigma( )

   local template = { 
      sigma = { optional = true, excludes = { 'sigma_x', 'sigma_y' } },
      sigma_x = { optional = true, requires = { 'sigma_y' } },
      sigma_y = { optional = true, requires = { 'sigma_x' } },
      ['%oneplus_of'] = { { 'sigma_x', 'sigma_y', 'sigma' } },
   }

   local ok, foo = validate( template, { sigma = 1 } )
   assert_true( ok, 'sigma' )

   local ok, foo = validate( template, { sigma_x = 1, sigma_y = 1 } )
   assert_true( ok, 'x & y' )

   local ok, foo = validate( template, { sigma_x = 1, sigma = 1 } )
   assert_false( ok, 'x & sigma' )

   local ok, foo = validate( template, { sigma_y = 1, sigma = 1 } )
   assert_false( ok, 'y & sigma' )

   local ok, foo = validate( template, { sigma_y = 1 } )
   assert_false( ok, 'y' )

   local ok, foo = validate( template, { sigma_x = 1 } )
   assert_false( ok, 'x' )

   local ok, foo = validate( template, { } )
   assert_false( ok, 'none' )

end
