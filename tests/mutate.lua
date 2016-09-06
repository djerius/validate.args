local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts
local validate_tbl = va.validate_tbl

setup = require 'setup'

describe( "mutate", function ()


    before_each( setup )

    it( "table mutation noargs", function ( )

        local template =  {
	   vtable = {
	      arg1 = { enum = { 'a', 'b' } },
	      arg2 = { type = 'number' },
	   }
	}


	local ok, rv = validate( { function () return true, template end },
				{
				   arg1 = 'a',
				   arg2 = 3
				}
			     )

	assert.is_true( ok )
	assert.are.equal( 'a', rv.arg1 )
	assert.are.equal( 3, rv.arg2 )

     end)

    it( "positional mutation false", function ( )

        local ok, rv = validate(
				{ function ()
				     return false, "no template"
				  end
			       },
				1
			     )

	assert.is_false( ok )
	assert.matches( rv, "no template" )

     end)

    it( "table mutation false", function ()

        local ok, rv = validate_tbl(
				    {
				       a = function ()
					      return false, "no template"
					   end
				    },
				    { a = 2 }
				 )

	assert.is_false( ok )
	assert.matches( rv, "no template" )

     end)

    it ( "table mutation args", function ()

        local spec = function ( arg )
			return true, { not_nil = true,
				       type = type(arg) == 'function'
				       and 'string' or type(arg)
				 }
		     end


	local ok, rv = validate( { spec }, 3 )
	assert.is_true( ok )
	assert.are.equal( 3, rv )

	local ok, rv = validate( { spec } )
	assert.is_false( ok )

	local ok, rv = validate( { spec }, function () end )
	assert.is_false( ok )

     end)

    it( "nested mutation", function ( )

        local template =  {
	   vtable = {
	      arg1 = { enum = { 'a', 'b' } },
	      arg2 = { type = 'number' },
	      arg3 = function( arg) return true, {} end,
	   }
	}


	local ok, rv = validate( { template } ,
				{
				   arg1 = 'a',
				   arg2 = 3,
				   arg3 = 2
				}
			     )

	assert.is_true( ok )
	assert.are.equal( 'a', rv.arg1 )
	assert.are.equal( 3, rv.arg2 )
	assert.are.equal( 2, rv.arg3 )

     end)

end)

