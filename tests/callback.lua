local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

local setup = require 'setup'

describe( "callbacks:", function ()

    before_each( setup )

    describe( "pre:", function ()

	it( "static", function ()

	    local value
	    local name

	    local template = { {
				  name = 'foo',
				  before = function( val, args )
					      value = val
					      name = tostring(args.name)
					   end
			       }
			    }

	    local ok, rv = validate( template, 'frank' )

	    assert.is_true( ok )
	    assert.are.equal( 'frank', rv )
	    assert.are.equal( 'frank', value )
	    assert.are.equal( 'arg#1(foo)', name )

	 end)

	it( "mutate", function ()

	    local template = { {
				  name = 'foo',
				  before = function( val, args )
					      return true, 'helga'
					   end
			       }
			    }


	    local ok, rv = validate( template, 'frank' )

	    assert.is_true( ok )
	    assert.are.equal( 'helga', rv )

	 end)

     end)

    describe( "post:", function ()

        it( "static", function ()

	    local value
	    local name

	    local template = { {
				  name = 'foo',
				  after = function( val, args )
					      value = val
					      name = tostring(args.name)
					  end
			       }
			    }

	    local ok, rv = validate( template, 'frank' )

	    assert.is_true( ok )
	    assert.are.equal( 'frank', rv )
	    assert.are.equal( 'frank', value )
	    assert.are.equal( 'arg#1(foo)', name )


	 end)


	it( "mutate", function ()

	    local value
	    local name

	    local template = { {
				  name = 'foo',
				  enum = { 'frank' },
				  after = function( val, args )
					      assert.are.equal( 'frank', val)
					      return true, 'helga'
					  end
			       }
			    }

	    local ok, rv = validate( template, 'frank' )
	    assert.is_true( ok )
	    assert.are.equal( 'helga', rv )


	 end)

     end)

 end)

describe( "global:", function ()

    before_each( setup )

    it( "before", function ()

	local inval, outval
	local name

	local template = { {
			      name = 'foo',
			   }
			}

	local before = function( args )
			 inval = args[1]
			 args[1] = outval
			 return true
		      end

	outval = 'bert'

	local ok, rv = validate_opts ( { before = before }, template, 'frank' )

	assert.is_true( ok )
	assert.are.equal( 'frank', inval )
	assert.are.equal( 'bert', rv )

     end)


    it( "after", function ()

	local inval, outval
	local name

	local template = { {
			      name = 'foo',
			   }
			}

	local after = function( args )
			 inval = args[1]
			 args[1] = outval
			 return true
		      end

	outval = 'larry'

	local ok, rv = validate_opts ( { after = after }, template, 'frank' )

	assert.is_true( ok )
	assert.are.equal( 'frank', inval )
	assert.are.equal( 'larry', rv )

     end)

 end)




