local validate = require( 'validate.args' ).validate

local setup = require 'setup'

describe( "scalar", function ()

    before_each( setup )

    local template = {
      arg1 = { optional = true, excludes = 'arg2' },
      arg2 = { optional = true },
   }

    it( "arg1 and arg2: fail", function ()
        local ok, rv = validate( template, { arg1 = 1, arg2 = 1 } )

	assert.is_false( ok )
	assert.matches( "arg[12]: can't have both arguments 'arg[12]' and 'arg[12]'", rv )
     end)

    it( "arg1: pass", function ()
        local ok, rv = validate( template, { arg1 = 1 } )
	assert.is_true( ok )
	assert.is.same( { arg1 = 1 }, rv )
     end)

    it( "arg2: pass", function ()
        local ok, rv = validate( template, { arg2 = 1 } )
	assert.is_true( ok )
	assert.is.same( { arg2 = 1 }, rv )
     end)


 end)

describe( "list", function ()

    before_each( setup )

    local template = {
       arg1 = { optional = true, excludes = { 'arg2'  } },
       arg2 = { optional = true },
    }

    it( "arg1 and arg2: fail", function ()
        local ok, rv = validate( template, { arg1 = 1, arg2 = 1 } )

	assert.is_false( ok )
	assert.matches( "arg[12]: can't have both arguments 'arg[12]' and 'arg[12]'", rv )
     end)

    it( "arg1: pass", function ()
        local ok, rv = validate( template, { arg1 = 1 } )
	assert.is_true( ok )
	assert.is.same( { arg1 = 1 }, rv )
     end)

    it( "arg2: pass", function ()
        local ok, rv = validate( template, { arg2 = 1 } )
        assert.is_true( ok )
	assert.is.same( { arg2 = 1 }, rv )
    end)


 end)


describe( "both", function ()

    before_each( setup )

    local template = {
       arg1 = { optional = true, excludes = 'arg2' },
       arg2 = { optional = true, excludes = 'arg1' },
    }

    it( "arg1 and arg2: fail", function ()
        local ok, rv = validate( template, { arg1 = 1, arg2 = 1 } )

	assert.is_false( ok )
	assert.matches( "arg[12]: can't have both arguments 'arg[12]' and 'arg[12]'" , rv )
     end)

    it( "arg1: pass", function ()
        local ok, rv = validate( template, { arg1 = 1 } )
	assert.is_true( ok )
	assert.is.same( { arg1 = 1 }, rv )
     end)

    it( "arg2: pass", function ()
        local ok, rv = validate( template, { arg2 = 1 } )
        assert.is_true( ok )
	assert.is.same( { arg2 = 1 }, rv )
    end)


 end)

describe( "multiple", function ( )

    before_each( setup )

    local template = {
       arg1 = { optional = true, excludes = { 'arg2', 'arg3' } },
       arg2 = { optional = true, },
       arg3 = { optional = true, },
    }

    it ( "arg1 && arg3: pass", function ()
	local ok, rv = validate( template, { arg2 = 1, arg3 = 1 } )
	assert.is_true( ok )
	assert.is.same( { arg2 = 1, arg3 = 1 }, rv )
     end)


    it ( "arg1 && arg2: fail", function ()
	local ok, rv = validate( template, { arg1 = 1, arg2 = 1 } )
	assert.is_false( ok )
	assert.matches( "arg[12]: can't have both arguments 'arg[12]' and 'arg[12]'", rv )
     end)

    it( "arg1 && arg3: fail", function ()
	local ok, rv = validate( template, { arg1 = 1, arg3 = 1 } )
	assert.is_false( ok )
	assert.matches( "arg[13]: can't have both arguments 'arg[13]' and 'arg[13]'" , rv )
     end)
end)

