local validate = require( 'validate.args' ).validate

local setup = require 'setup'

describe( "validate function", function ()

    before_each( setup )

    local template = { {
			 name = 'foo',
			 vfunc = function( val, args )
				    if val then
				       return true, val
				    else
				       return false, args.name
				    end
				 end
		   }}

    it( "true", function ()
	local ok, rv = validate( template, true )

	assert.is_true( ok )
	assert.are.equal( true, rv )

     end)

    it( "false", function ()
        local ok, rv = validate( template, false )

	assert.is_false( ok )
	assert.are.equal( 'arg#1(foo): arg#1(foo)', rv );

     end)

 end)


describe( "enum", function ()

    before_each( setup )

    describe( "list", function ()

	local template = { {
			      enum = { 'a', 3, 'c', 'd' }
			} }

	for _, v in pairs( template[1].enum ) do

	    it( "exists: " .. v, function ()
                local ok, rv = validate( template, v  )
		assert.is_true( ok )
		assert.are.equal( v, rv)
	     end)

	 end

        it( "doesn't exist", function ()
            local ok, rv = validate( template, 19 )
	    assert.is_false( ok )
	 end)

     end)

    describe( "scalar", function ()

        it( "exists", function ()
            local ok, rv = validate( { { enum = 19 } } , 19 )

	    assert.is_true( ok )
	    assert.is_equal( 19, rv )
	 end)

	it( "doesn't exist", function ()
            local ok, rv = validate( { enum = 19 } , 18 )
	    assert.is_false( ok )
	 end)

     end)

 end)
