local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

local setup = require 'setup'

describe( "special", function ()

    before_each(setup)

    it( "invalid oneplus of", function ()

        local template = { arg1 = { optional = true },
			   arg2 = { optional = true },
			   ['%oneplus_of'] = { 'arg1', 'arg2' },
			}


	local ok, rv = validate_opts( { error_on_bad_spec = false },
				      template, { arg1 = 1 } )
	assert.is_false( ok )
     end)

    it( "unknown special", function ()

        local template = { arg1 = { optional = true },
			   arg2 = { optional = true },
			   ['%say_what'] = { 'arg1', 'arg2' },
			}


	local ok, rv = validate_opts( { error_on_bad_spec = false},
				      template, { arg1 = 1 } )
	assert.is_false( ok )
     end)


    describe( "oneplus of", function ()

        local template = { arg1 = { optional = true },
			   arg2 = { optional = true },
			   ['%oneplus_of'] = { { 'arg1', 'arg2' } },
			}


	it( "arg1 only", function ()
	    local ok, rv = validate( template, { arg1 = 1 } )
	    assert.is_true( ok )
	 end)


	it( "arg2 only", function ()
	    local ok, rv = validate( template, { arg2 = 1 } )
	    assert.is_true( ok )
	 end)

	it( "no arguments", function ()
	    local ok, rv = validate( template, { } )
	    assert.is_false( ok )
	 end)

     end)

    describe( "one of", function ()

        local template = { arg1 = { optional = true },
			   arg2 = { optional = true },
			   ['%one_of'] = { { 'arg1', 'arg2' } },
			}

        it( "arg1 only", function ()
	    local ok, rv = validate( template, { arg1 = 1 } )
	    assert.is_true( ok )
	 end)

	it( "arg2 only", function ()
	    local ok, rv = validate( template, { arg2 = 1 } )
	    assert.is_true( ok )
	 end)

	it( "no arguments", function ()
	    local ok, rv = validate( template, { } )
	    assert.is_false( ok )
	 end)

	it( "both arguments", function ()
	    local ok, rv = validate( template, { arg1 = 1, arg2 = 1 } )
	    assert.is_false( ok )
	 end)

     end)

    describe( "sigma", function ()

        local template = {
	   sigma = { optional = true, excludes = { 'sigma_x', 'sigma_y' } },
	   sigma_x = { optional = true, requires = { 'sigma_y' } },
	   sigma_y = { optional = true, requires = { 'sigma_x' } },
	   ['%oneplus_of'] = { { 'sigma_x', 'sigma_y', 'sigma' } },
	}

	it( "sigma", function ()
	    local ok, rv = validate( template, { sigma = 1 } )
	    assert.is_true( ok )
	 end)


	it( "x & y", function ()
	    local ok, rv = validate( template, { sigma_x = 1, sigma_y = 1 } )
	    assert.is_true( ok )
	 end)

	it( "x & sigma", function ()
	    local ok, rv = validate( template, { sigma_x = 1, sigma = 1 } )
	    assert.is_false( ok )
	 end)

	it( "y & sigma", function ()
	    local ok, rv = validate( template, { sigma_y = 1, sigma = 1 } )
	    assert.is_false( ok )
	 end)

	it( "y", function ()
	    local ok, rv = validate( template, { sigma_y = 1 } )
	    assert.is_false( ok )
	 end)

	it( "x", function ()
	    local ok, rv = validate( template, { sigma_x = 1 } )
	    assert.is_false( ok )
	 end)

	it( "none", function ()
	    local ok, rv = validate( template, { } )
	    assert.is_false( ok )
	 end)

     end)
 end)
