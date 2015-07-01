local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

local setup = require 'setup'

describe( "ordered", function ()

    before_each( setup )

    it( "none", function ()

        local list = {}

	function push( arg ) table.insert( list, arg ) end

	local ok, args = validate_opts( { ordered = true },
				       {
					  a = { order = 1, postcall = push },
					  b = { order = nil, postcall = push },
					  c = { order = 3, postcall = push },
					  d = { order = 2, postcall = push },
				       },
				       { a = 'a', b = 'b', c = 'c', d = 'd' }
				    )

	assert.is_true( ok )
	assert.is.same( { a = 'a', b = 'b', c = 'c', d = 'd' }, args )
	assert.is.same( { 'a', 'd', 'c', 'b' }, list )

     end)

    it( "mutate", function ()

        local list = {}

	function push( arg ) table.insert( list, arg ) end

	local ok, args = validate_opts( { ordered = true },
				       {
					  a = { order = 1, postcall = push },
					  b = { order = 4, postcall = push },
					  c = { order = 3, postcall = push },
					  d = function ()
						 return true, { order = 2,
								postcall = push }
					      end
				       },
				       { a = 'a', b = 'b', c = 'c', d = 'd' }
				    )

	assert.is_true( ok, args )

	assert.is.same( { a = 'a', b = 'b', c = 'c', d = 'd' }, args )
	assert.is.same( { 'a', 'c', 'b', 'd' }, list )

     end)

end)

