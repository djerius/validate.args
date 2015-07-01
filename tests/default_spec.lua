local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

local setup = require 'setup'

describe( "%pos", function ()

    before_each( setup )

    it( "%named", function ()

	local template = {
			     ['%named'] = function( k, v, vfargs )
					     return true, { optional = true,
							    vtable = { a = { type = 'posint', default = 3 },
								       b = { type = 'posint', default = 4  },
								    },
							 }
					  end,
			     ['%pos'] = function( k, v, vfargs )
					 return true, { name = 'frank', type = 'string' }
				      end,
		       }

	local ok, rv = validate_opts( { named = true}, template, { 'sue', gary = {} } )

	assert.is_true( ok )
	assert.are.same( { frank = 'sue', gary = { a = 3, b = 4 } }, rv )

     end)

    describe( "error returns", function ( )

	local template = {

	   ['%pos'] = function( k, v, vfargs )
			 if k == 1 then
			    return true, { name = 'first', type = 'string' }
			 elseif k == 2 then
			    return false
			 end
			    return false, "funky"
		      end
	}

	it ( "no error", function ()

	    local ok, args = validate_opts( { named = true }, template,
					 { 'a' } )
	    assert.is_true( ok )
	    assert.are.equal( 'a', args.first )
	 end)

	it ( "error, default message", function ()
	    local ok, args = validate_opts( { named = true }, template,
					 { 'a', 'b' } )
	    assert.is_false( ok )
	    assert.are.equal( ": unexpected elements: 2", args )
	 end)

	it ( "error, message", function ()
	    local ok, args = validate_opts( { named = true }, template,
					    { 'a', [3] = 'b' } )
	    assert.is_false( ok )
	    assert.are.equal( "3: funky", args )
	 end)

     end)

 end)

describe( "%default", function ( )

    before_each( setup )

    it( "match", function ()
	local template = {
			    ['%default'] = function( k, v, vfargs )
					      if type(v) == 'table' then
						 return true, { optional = true, 
								vtable = { a = { type = 'posint', default = 3 },
									   b = { type = 'posint', default = 4  },
									},
							     }
					      else
						 return true, { name = 'frank', type = 'string' }
					      end
					   end,
		      }

       local ok, rv = validate_opts( { named = true}, template, { 'sue', gary = {} } )

       assert.is_true( ok )
       assert.are.same( { frank = 'sue', gary = { a = 3, b = 4 } }, rv )

    end)

    it( "doesn't match", function()

	local template = {
			     ['%default'] = function( k, v, vfargs )
					       if k == 'harry' then
						  return false
					       else
						  return true, { type = 'posint' }
					       end
					    end,
		       }

	local ok, rv = validate( template, { harry = 3, gary = 2 } )

	assert.is_false( ok )
	assert.is.equal( ': unexpected elements: harry', rv )

     end)
 end)
