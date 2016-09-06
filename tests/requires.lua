local validate = require( 'validate.args' ).validate

setup = require 'setup'

describe( "requires", function ()

    before_each( setup )

    it( "req scalar", function ()

        local template = {
	   arg1 = { optional = true, requires = 'arg2' },
	   arg2 = { optional = true },
	}

	local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )

	assert.is_true( ok )

	local ok, foo = validate( template, { arg1 = 1 } )
	assert.is_false( ok )
	assert.matches('argument.*without' , foo )

	local ok, foo = validate( template, { arg2 = 1 } )
	assert.is_true( ok )

     end)

    it( "req list", function ()

        local template = {
	   arg1 = { optional = true, requires = { 'arg2' } },
	   arg2 = { optional = true },
	}

	local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )

	assert.is_true( ok )

	local ok, foo = validate( template, { arg1 = 1 } )
	assert.is_false( ok )
	assert.matches('argument.*without' , foo )

	local ok, foo = validate( template, { arg2 = 1 } )
	assert.is_true( ok )

     end)

    it( "req both", function ()

        local template = {
	   arg1 = { optional = true, requires = 'arg2' },
	   arg2 = { optional = true, requires = 'arg1' },
	}

	local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )

	assert.is_true( ok )

	local ok, foo = validate( template, { arg2 = 1 } )

	assert.is_false( ok )
	assert.matches('argument.*without' , foo )

	local ok, foo = validate( template, { arg1 = 1 } )

	assert.is_false( ok )
	assert.matches('argument.*without' , foo )

     end)

    it( "req multiple", function ()

        local template = {
	   arg1 = { optional = true },
	   arg2 = { optional = true, requires = { 'arg1', 'arg3' } },
	   arg3 = { optional = true }
	}

	local ok, foo = validate( template, { arg1 = 1, arg2 = 1, arg3 = 1 } )
	assert.is_true( ok )

	local ok, foo = validate( template, { arg1 = 1, arg3 = 1 } )
	assert.is_true( ok )

	local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )
	assert.is_false( ok )
	assert.matches('argument.*without' , foo )


     end)

 end)

