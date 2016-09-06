local va = require( 'validate.args' )
local validate, validate_opts = va.validate, va.validate_opts

describe( "positional", function ()

    before_each( setup )

    it( "template is a table", function ()

        local ok, err = validate( 'x', 'x' )

	assert.is_false( ok )
	assert.matches( 'expected table', err )

     end)

    it( "optional but specified", function ()

        local template = { { optional = true } }
	local ok, rv = validate( template, 'x' )

	assert.is_true( ok )
	assert.is.equal( 'x', rv )

     end)

    it( "optional not specified", function ()

        local template = { { optional = true } }
	local ok, rv = validate( template )

	assert.is_true( ok )
	assert.is.equal( nil, rv )

     end)

    it( "default not specified", function ()

        local template = { { default = 'foo' } }
	local ok, rv = validate( template )

	assert.is_true( ok )
	assert.is.equal( 'foo', rv )

     end)

    it( "optional specified as nil", function ()

        local template = { { default = 'foo' }, { default = 'bar' } }
	local ok, rv, bar = validate( template )

	assert.is_true( ok )
	assert.is.equal( 'foo', rv )
	assert.is.equal( 'bar', bar )

     end)

    describe( "required specified as nil", function ()

        local template = { { allow_nil = true }, { allow_nil = true } }

	it( "nil, nil", function ()
	    local ok, rv, bar = validate( template, nil, nil )

	    assert.is_true( ok )
	    assert.is.equal( nil, rv )
	    assert.is.equal( nil, bar )
	 end)

	it( "nil, value", function ()
  	    local ok, rv, bar = validate( template, nil, 'x' )

	    assert.is_true( ok )
	    assert.is.equal( nil, rv )
	    assert.is.equal( 'x', bar )

	 end)

     end)

    it( "multiple required not specified", function ()

        local template = { { allow_nil = true }, { allow_nil = true } }
	local ok, err = validate( template, nil )

	assert.is_false( ok )
	assert.matches( 'arg#2: missing', err )

     end)

    it( "multiple required not specified with name", function ()

        local template = { { allow_nil = true }, { name = 'arg2', allow_nil = true } }
	local ok, err = validate( template, nil )

	assert.is_false( ok )
	assert.matches( 'arg#2%(arg2%): missing', err )

     end)

    it( "required not nil specified as nil", function ()

        local template = { {
			      name = 'arg2',
			      optional = false,
			      not_nil = true,
			   }
			}
	local ok, err = validate( template, nil )

	assert.is_false( ok )
	assert.matches( 'arg#1.*not be nil', err )

     end)


    it( "too many", function ()

        local template = { { allow_nil = true }, { allow_nil = true } }
	local ok, err = validate( template, nil, nil, nil )

	assert.is_false( ok )
	assert.matches( 'too many.*argument', err )

     end)

    it( "non integer entries", function ()

        local template = { { allow_nil = true }, { allow_nil =true }, frank = 3 }
	local ok, err = validate( template, nil, nil )

	assert.is_false( ok )
	assert.matches( 'extra elements', err )

     end)

    it( "pos named not cvtd", function ()

        local template = { {
			      name = 'arg1',
			      optional = false,
			      not_nil = true,
			   },
			   {
			      type = 'string',
			   }
			}
	local ok, arg1, arg2 = validate( template, 32, 'foo' )

	assert.is_true( ok )
	assert.is.equal( 32, arg1 )
	assert.is.equal( 'foo', arg2 )


     end)

    it( "convert positional to named", function ()

        local template = { {
			      name = 'arg2',
			      optional = false,
			      not_nil = true,
			   },
			   {
			      type = 'string',
			   }
			}
	local ok, opts = validate_opts( { named = true }, template, 32, 'foo' )

	assert.is_true( ok, opts )
	assert.is.equal( 32, opts.arg2 )
	assert.is.equal( 'foo', opts[2] )


     end)

    describe( "extra positional args", function ()

        local template = { {}, {} }

	it( "allow_extra = true", function ()
            local ok, a, b, c = validate_opts( { allow_extra = true }, template,
					      1, 2, 3)

	    assert.is_true( ok, a )
	    assert.is.equal( 1, a )
	    assert.is.equal( 2, b )
	    assert.is.equal( nil, c )
	 end)

	it( "allow_extra = true, pass_through = true ", function ()
            local ok, a, b, c = validate_opts( { allow_extra = true,
						 pass_through = true,
					      }, template,
					      1, 2, 3)

	    assert.is_true( ok, a )
	    assert.is.equal( 1, a )
	    assert.is.equal( 2, b )
	    assert.is.equal( 3, c )

	 end)

     end)

 end)
