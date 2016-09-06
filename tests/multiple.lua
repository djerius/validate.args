local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

setup = require 'setup'

describe( "multiple", function ()

    before_each( setup )

    it( "scalar multiple", function ()

        local spec = { x = { multiple = false } }
	local ok, rv = validate( spec, { x = 3 } )

	assert.is_true( ok )
	assert.is.same( { x = 3 } , rv )
     end)

    it( " table multiple scalar value", function ()

        local spec = { x = { multiple = true } }

	local ok, rv = validate( spec, { x = 3 } )

	assert.is_false( ok )
	assert.matches( 'must be a table', rv )
     end)

    it( "array multiple", function ()

	local spec = { x = { type = 'posint',
			     multiple = true,
			  }
		    }
	local ok, rv = validate( spec, { x = { 1, 2, 3 } } )

	assert.is_true( ok )

	assert.is.same( { x = { 1, 2, 3 } }, rv  )

     end)

    it( "nested array multiple", function ()

	local spec = { x = { vtable = { { type = 'posint' }, { type = 'posint' } },
			     multiple = true,
			  }
		    }
	local ok, rv = validate( spec, { x = {
					     { 1, 2 },
					     { 4, 5 },
					  }
				       }
			       )

	assert.is_true( ok )

	assert.is.same( { x = { { 1, 2 }, { 4, 5 } } }, rv )

     end)

    it( "nelem bounds", function ()

	local spec = { x = { type = 'posint',
			     multiple = { min = 3, max = 5 }
			  }
		    }

	local ok, rv = validate( spec, { x = { 1, 6 }  } )
	assert.is_false( ok )
	assert.matches( 'too few.+expected 3.+got 2', rv )

	local ok, rv = validate( spec, { x = { 1, 2, 3 }  } )
	assert.is_true( ok )

	local ok, rv = validate( spec, { x = { 1, 2, 3, 4}  } )
	assert.is_true( ok )

	local ok, rv = validate( spec, { x = { 1, 2, 3, 4, 5 }  } )
	assert.is_true( ok )

	local ok, rv = validate( spec, { x = { 1, 2, 3, 4, 5, 6 }  } )

	assert.is_false( ok )
	assert.matches( 'too many.+expected 5.+got 6', rv )

     end)

    it( "exact nelem", function ()

        local spec = { x = { type = 'posint',
			     multiple = { n = 4 }
			  }
		    }

	local ok, rv = validate( spec, { x = { 1, 2 }  } )
	assert.is_false( ok )
	assert.matches( 'incorrect.+expected 4.+got 2', rv )

	local ok, rv = validate( spec, { x = { 1, 2, 3, 4 }  } )
	assert.is_true( ok )

     end)

    it( "allow scalar", function ()

        local spec = { x = { type = 'posint',
			     multiple = { n = 4 }
			  }
		    }

	local ok, rv = validate( spec, { x =  1 } )

	assert.is_false( ok )
	assert.matches( 'must be a table', rv )

	local spec = { x = { type = 'posint',
			     multiple = { allow_scalar = true, n = 4 }
			  }
		    }

	local ok, rv = validate( spec, { x = 1 } )
	assert.is_false( ok )
	assert.matches( 'incorrect.+expected 4.+got 1', rv )

	local ok, rv = validate( spec, { x = { 1, 2, 3, 4 }  } )

	assert.is_true( ok )


     end)

    it( "keys", function ()

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

	local ok, rv = validate( spec, { x = { a = 1, b = 2 }  } )

	assert.is_true( ok )

	local ok, rv = validate( spec, { x = { a1 = 1, b = 2 }  } )

	assert.is_false( ok )
	assert.matches( 'only alpha', rv )

     end)


    it( "bad spec", function ()
        local spec = { x = { type = 'posint',
			     multiple = 'snack',
			  }
		    }

	local ok, rv = pcall( validate, spec, { x = { a = 1, b = 2 }  } )

	assert.is_false( ok )

     end)

end)
