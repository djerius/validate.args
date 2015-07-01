local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

local setup = require 'setup'

describe( "types", function ()

    before_each( setup )

    it( "scalar", function ( )

	local template = { { default = 3 } }

	local ok, rv = validate( template )

	assert.is_true( ok )
	assert.are.equal( 3, rv )
     end)

    describe( "boolean", function ( )

        it( "true", function ()
	    local template = { { type = 'boolean', default = true } }
	    local ok, rv = validate( template )

	    assert.is_true( ok )
	    assert.are.equal( true, rv )
	 end)

	it( "false", function ()

	    local template = { { type = 'boolean', default = false } }
	    local ok, rv = validate( template )

	    assert.is_true( ok )
	    assert.are.equal( false, rv )
	 end)

     end)

    it( "function", function( )

        local template = { { default = function() return true, 5;  end } }
	local ok, rv = validate( template )

	assert.is_true( ok )
	assert.are.equal( 5, rv )

     end)

 end)

describe( "interface", function ()

   before_each( setup )

   it( "positional", function ()

       local template = { { default = 2 },
			  { default = 3 },
		       }

       local ok, rv1, rv2 = validate( template )
       assert.is_true( ok )
       assert.are.equal( 2, rv1 )
       assert.are.equal( 3, rv2 )

    end)


    describe( "vtable", function ()

	describe( "table", function ( )

	    local template = { { optional = true,
				vtable = {
				   arg1 = { default = 1 },
				   arg2 = { default = 2 },
				}
			  } }

	    -- make sure that an empty table works
	    it( "empty", function ()
		local ok, rv = validate( template, {} )

		assert.is_true( ok )
		assert.are.same( { arg1 = 1, arg2 = 2 }, rv )
	     end)

	   -- and an actual nil table too.
	    it( "nil", function ()
		local ok, rv = validate( template )

		assert.is_true( ok )
		assert.are.same( { arg1 = 1, arg2 = 2 }, rv )

	     end)
	 end)


	describe( "function", function ()

	    local expect_nil = false
	    local template = { { optional = true,
				 vtable = function ( arg )
					     assert.is_true( expect_nil and arg == nil  or true)
						return true, {
						   arg1 = { default = 1 },
						   arg2 = { default = 2 },
						}
					     end
			   } }

	    -- make sure that an empty table works
	    it( "empty", function ()
		local ok, rv = validate( template, {} )

		assert.is_true( ok )
		assert.are.same( { arg1 = 1, arg2 = 2 }, rv )
	     end)

	    -- and an actual nil table too.
	    it( "nil", function ()
		expect_nil = true
		local ok, rv = validate( template )

		assert.is_true( ok )
		assert.are.same( { arg1 = 1, arg2 = 2 }, rv )
	     end)

	 end)

	it( "nested vtable", function ()

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

	    local ok, rv = validate( template )

	    assert.is_true( ok )
	    assert.are.same( { arg1 = 1,
			       arg2 = 2,
			       arg3 = { arg1 = 3.1,
					arg2 = 3.2 }
			    }, rv )

	 end)

	it( "nested overrides", function ()

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

	    local ok, rv = validate( template )

	    assert.is_true( ok )
	    assert.are.same( { arg1 = 1,
			       arg2 = 2,
			       arg3 = { arg1 = 3.3,
					arg2 = 3.4 }
			    }, rv )
	 end)
     end)

 end)






