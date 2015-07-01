local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

describe( "Name", function ()

    it( "basic", function ()

        local name = va.Name:new{ 'a', 'b', 'c' }

	assert.are.same( { 'a', 'b', 'c' },  name.name )
	assert.is.equal( 'a.b.c', name:tostring() )

     end)

    it( "positional", function ()

        local name = va.Name:new{ 'a', '1', 'c' }

	assert.are.same( { 'a', '1', 'c' },  name.name )
	assert.is.equal( 'a[1].c', name:tostring() )

     end)

 end)
