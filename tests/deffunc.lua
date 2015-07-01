local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

local setup = require 'setup'

describe( "default function", function ()

    before_each( setup )

    it( "true", function ( )

	local template =  { { default = function() return true, 3 end,
			      optional = true
			   }
			  }

	local ok, rv = validate( template )

	assert.is_true( ok )
	assert.are.equal( 3, rv )

     end)

    it ( "false", function ()

	local template =  { { default = function() return false, 'bad dog' end,
			      optional = true
			   }
			  }


	local ok, rv = validate( template )

	assert.is_false( ok )
	assert.are.equal( 'arg#1: bad dog', rv )

     end)

 end)

