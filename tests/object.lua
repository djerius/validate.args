local va = require( 'validate.args' )

setup = require 'setup'

describe( "object", function ()

    before_each( setup )

    -- simple test of OO interface; most of the testing is done
    -- via the procedural interface as that came first.

    it( "multiple required not specified", function ()

       local template = { { allow_nil = true }, { optional = false } }
       local ok, err = va:new():validate( template, nil )

       assert.is_false( ok )
       assert.matches( 'arg#2: missing', err )

    end)

    it( "multiple required not specified with name", function ()

        local template = { { allow_nil = true }, { name = 'arg2',
						   optional = false } }
	local ok, err = va:new():validate( template, nil )

	assert.is_false( ok )
	assert.matches( 'arg#2%(arg2%): missing', err )

     end)


    -- test options

    it( "options don't exist", function ()

        local obj = va:new()

	assert.error_matches( function ()
			     obj.opts.DOES_NOT_EXIST = true
			  end,
			 "unknown option" )

	assert.error_matches( function ()
			     obj:setopts{ DOES_NOT_EXIST = true }
			  end,
			 "unknown option" )

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
	local obj = va:new()
	obj.opts.named = true

	local ok, opts = obj:validate( template, 32, 'foo' )

	assert.is_true( ok )
	assert.is.equal( 32, opts.arg2 )
	assert.is.equal( 'foo', opts[2] )

     end)

    describe( "extra positional args", function ()

        local template = { {}, {} }
	local obj = va:new()
	obj:setopts{ allow_extra = true }

	it( "allow_extra = true", function ()
	    local ok, a, b, c = obj:validate( template, 1, 2, 3)

	    assert.is_true( ok )
	    assert.is.equal( 1, a )
	    assert.is.equal( 2, b )
	    assert.is.equal( nil, c )

	 end)


	it( "allow_extra = true, pass_through = true ", function ()
	    obj:setopts{ allow_extra = true,
			 pass_through = true,
		      }

	    local ok, a, b, c = obj:validate( template, 1, 2, 3)

	    assert.is_true( ok )
	    assert.is.equal( 1, a )
	    assert.is.equal( 2, b )
	    assert.is.equal( 3, c )
	 end)

     end)


    it( "constructor", function ()

        va.opts{ allow_extra = true };
	va.add_type( 'test', function () end )

	local obj = va:new{ use_current_options = true };
	assert.is_true( obj.opts.allow_extra, 'current options' )

	local obj = va:new{ use_current_types = true };
	assert.is_function( obj.types:validator('test'), 'current types' )

     end)

    -- test inheritance

    describe( "level 0", function ()

        local vobj

        -- first make sure we know what the base value for our test
        -- option is. currently there's no way to get this directly, so
        -- create a new object and use it to find out what it is

        vobj = va:new()

	local base_val = vobj.opts.check_spec

	-- now change the default (not base) and make sure our object
	-- doesn't track it.
	it( "child doesn't track default", function ()
	    va.opts{ check_spec = not base_val }
	    assert.is.equal( base_val, vobj.opts.check_spec )
	 end)

	local clone

	-- now clone an object
	it( "clone, unchanged", function ()
	    clone = vobj:new()
	    assert.is.equal( vobj.opts.check_spec, clone.opts.check_spec )
	 end)

	-- change in value in original object should not affect the clone
	it( "clone doesn't track parent", function ()
	    vobj.opts.check_spec = not base_val
	    assert.is_not.equal( clone.opts.check_spec, vobj.opts.check_spec )
	    vobj.opts.check_spec = base_val
	 end)

	-- change in value in clone should not affect the parent
	it( "parent doesn't track clone", function ()
	    clone.opts.check_spec = not base_val
	    assert.is.equal( vobj.opts.check_spec, base_val)
	 end)

     end)


    it( "options udata", function ()

        local vobj = va:new()
	local udata = {}

	vobj:setopts{ udata = udata }

	local ok, val = vobj:validate( { { postcall = function( arg, vfarg )
							 vfarg.va:getopt('udata').called = true
						      end
					}
				      }, 1 )

	assert.is_true( ok, val )
	assert.is.equal( val, 1 )
	assert.is_true( udata.called )

     end)

 end)
