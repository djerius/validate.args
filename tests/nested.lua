local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

setup = require 'setup'

describe( "nested", function ()

    before_each( setup )

it( "not table", function ()

   local template = { {
			 vtable = {
			    arg1 = { enum = { 'a', 'b' } },
			    arg2 = { type = 'number' },
			 }
		   } }

   local ok, rv = validate( template, 3 )

   assert.is_false( ok )
   assert.matches('incorrect type' , rv )

end)

it( "one level", function ()

   local template = { {
			 vtable = {
			    arg1 = { enum = { 'a', 'b' } },
			    arg2 = { type = 'number' },
			 }
		   } }

   local ok, rv = validate( template, {
				arg1 = 'a',
				arg2 = 3
			     }
			  )

   assert.is_true( ok )
   assert.is.equal( 'a', rv.arg1 )
   assert.is.equal( 3, rv.arg2 )

end)

it( "two levels", function ()

   local template = { {
			 vtable = {
			    arg1 = { enum = { 'a', 'b' } },
			    arg2 = { type = 'number' },
			    arg3 = { type = 'table',
				     vtable = {
					arg31 = { type = 'string' },
					arg32 = { type = 'function' },
					arg33 = { type = 'number',
						  default = 99 }
				     }
				  }
			 }
		   } }

   local ok, rv = validate( template, {
				arg1 = 'a',
				arg2 = 3,
				arg3 = { arg31 = 'foo',
					 arg32 = function() return 88.3 end,
				      }
			     }
			  )

   assert.is_true( ok )
   assert.is.equal( 'a', rv.arg1 )
   assert.is.equal( 3, rv.arg2 )
   assert.is.equal( 'foo', rv.arg3.arg31 )
   assert.is_function( rv.arg3.arg32)
   assert.is.equal( 88.3, rv.arg3.arg32() )
   assert.is.equal( 99, rv.arg3.arg33 )

end)

it( "two levels defaults", function ()

   local template = { { vtable = {
			   arg3 = { type = 'table',
				    vtable = {
				       arg33 = { type = 'number',
						 default = 99 }
				    }
				 }
			}
		  } }

   local ok, rv = validate( template, { arg3 = {} }  )

   assert.is_true( ok )
   assert.is.equal( 99, rv.arg3.arg33 )

end)

it( "invalid spec", function ()

   local template = { { vtable = {
			   arg3 = { type = 'table',
				    vtable = {
				       arg33 = { snarf = 3,
						 default = 99 }
				    }
				 }
			}
		  } }

   local ok, rv = validate_opts( {
				    error_on_bad_spec = false
				 },
				 template, { arg3 = {} }  )

   assert.is_false( ok )

   assert.matches( 'snarf', rv )

end)


it( "vtable func", function ()

   local template = { { vtable = function (arg)
				    if arg.a then
				       return true, { a = { },
						b = { },
					     }
				    else
				       return true, { c = { },
						b = { },
					     }
				    end
				 end


		  } }


   local ok, rv = validate( template, { a = 1, b = 2 } )
   assert.is_true( ok )

   local ok, rv = validate( template, { c = 1, b = 2 } )
   assert.is_true( ok )

   local ok, rv = validate( template, { a = 1, b = 2, c = 3 } )
   assert.is_false( ok )

   local ok, rv = validate( template, { d = 1, b = 2, c = 3 } )
   assert.is_false( ok )

end)

it( "vtable func example", function ()

   local specs = { gaussian = { {}, sigma = { type = 'number' } },
		   uniform  = { {},  },
		   powerlaw = { {}, alpha = { type = 'number' } },
		 }

   local template =
      { idist = {
	   vtable = function (arg)
		       local vtable = specs[arg[1]]
		       if vtable then
			  return true, vtable
		       else
			  return false, "unknown idist: " .. tostring(arg)
		       end
		    end
	}
     }


   local ok, rv = validate( template, { idist = { 'gaussian', sigma = 3 } } )
   assert.is_true( ok )

   local ok, rv = validate( template, { idist = { 'gaussian', sigmax = 3 } } )
   assert.is_false( ok )

   local ok, rv = validate( template, { idist = { 'uniform' } } )
   assert.is_true( ok )

   local ok, rv = validate( template, { idist = { 'powerlaw', alpha = 4 } } )
   assert.is_true( ok )

   local ok, rv = validate( template, { idist = { 'snackbar' } } )
   assert.is_false( ok )


end)


it( "bad vtable func", function ()

   local template = { { vtable = function (arg)
				    if arg.a then
				       return true, { a = { spanky = true },
						      b = { },
					     }
				    else
				       return true, { c = { },
						b = { },
					     }
				    end
				 end


		  } }


   local ok, rv = validate_opts( {
				    error_on_bad_spec = false
				 },
				 template, { a = 1, b = 2 } )
   assert.is_false( ok )

   local ok, rv = validate( template, { c = 1, b = 2 } )
   assert.is_true( ok )

end)

end)
