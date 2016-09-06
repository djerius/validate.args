local validate = require('validate.args')
local inplace = require( 'validate.inplace' )

setup = require 'setup'

describe( "simple", function ()

    before_each( setup )

    local spec = {
       foo = { type = 'posint' },
    }

    local va = validate:new()
    local obj = inplace:new( 'test', spec, va )
    local test = obj:proxy()

    test.foo = 3

    assert.is.equal( 3, test.foo )

    copy = obj:copy()

    -- make sure this is a clean table
    assert.is.equal( nil, getmetatable( copy ))
    assert.is.equal( 3, rawget( copy, 'foo') )

    -- try to do something wrong
    local ok, error = pcall( function () test.foo = -3 end )

    assert.is_false( ok, "bad type" )
    assert.matches( 'test.foo:.*posint', error )

 end)

describe( "vtable", function ()

    before_each( setup )

    local spec = {
       foo = { type = 'posint', default = 9 },
       goo = { vtable = {  a = { type = 'posint', default = 33 },
			   b = { type = 'posint', default = 44 }
			},
	    },
    }

    local va = validate:new()

    local obj = inplace:new( 'test', spec, va )

    local test = obj:proxy()

    it( "default values", function ()
	assert.is.equal( 9,  test.foo )
	assert.is.equal( 33, test.goo.a )
	assert.is.equal( 44, test.goo.b )
     end)


    it( "assign values", function ()
	test.foo = 3
	assert.is.equal( 3, test.foo )

	test.goo.a = 4
	assert.is.equal( 4, test.goo.a )

	test.goo.b = 8
	assert.is.equal( 8, test.goo.b )
     end)

    -- try assigning a table
    -- this should reset things to default
    it ( "reset table", function ()
	 test.goo = { }

	 assert.is.equal( 33, test.goo.a )
	 assert.is.equal( 44, test.goo.b )
      end)

    -- set a ; b should get reset to default
    it ( "reset table with values", function ()
	 test.goo = {  a = 88 }
	 assert.is.equal( 88, test.goo.a )
	 assert.is.equal( 44, test.goo.b )
      end)

    -- try to do things wrong
    it( "fail: negative int", function ()
	local ok, error = pcall( function () test.goo.b = -3 end )
	assert.is_false( ok )
	assert.matches( 'test.goo.b:.*posint', error )
     end)


    it( "fail: unknown attribute", function ()
	local ok, error = pcall( function () test.goo.c = -3 end )
	assert.is_false( ok )
	assert.matches( 'test.goo.c:.*unknown', error )
     end)

    it( "fail: wring type", function ()
	local ok, error = pcall( function () test.goo = -3 end )
	assert.is_false( ok )
	assert.matches( 'test.goo:.*incorrect type', error )
     end)


 end)


describe( "copy", function ()

    before_each( setup )

    local spec = {
       foo = { type = 'posint', default = 9 },
       goo = { vtable = {  a = { type = 'posint', default = 33 },
			   b = { type = 'posint', default = 44 }
			},
	    },
    }

    local va = validate:new()

    local obj = inplace:new( 'test', spec, va )

    local copy = obj:copy()

    it( "assure no metatables", function ()
        assert.is.equal( nil, getmetatable(copy) )
	assert.is.equal( nil, getmetatable(copy.goo) )
     end)

    it( "defaults", function ()
        assert.is.equal( 9, copy.foo )
	assert.is.equal( 33, copy.goo.a )
	assert.is.equal( 44, copy.goo.b )
     end)


    it( "copy is independent of proxy", function ()
	local test = obj:proxy()
	test.goo.b = 99
	assert.is.equal( 99, test.goo.b )
	assert.is.equal( 44, copy.goo.b )

	copy = obj:copy()
	assert.is.equal( 99, copy.goo.b )
     end)


 end)

