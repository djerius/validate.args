local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

setup = require 'setup'

describe( "named", function ()

    before_each( setup )

    it( "optional but specified", function ()

        local template = { x = { optional = true }}
	local ok, rv = validate( template, { x = 3 } )

	assert.is_true( ok )
	assert.is.same( { x = 3 }, rv )
     end)


    it( "optional not specified", function ()

        local template = { x = { optional = true }}
	local ok, rv = validate( template, {} )

	assert.is_true( ok )
	assert.is.same( { x = nil } , rv )
     end)

    it( "required specified", function ()

        local template = { x = { }}
	local ok, rv = validate( template, { x = 3 } )

	assert.is_true( ok )
	assert.is.same( { x = 3 }, rv )
     end)


    it( "required not specified", function ()

        local template = { x = { }}
	local ok, rv = validate( template, {} )

	assert.is_false( ok )
	assert.matches( 'required but not specified', rv )
     end)

    it( "default but specified", function ()

        local template = { x = { default = 2 } }
	local ok, rv = validate( template, { x = 3 } )

	assert.is_true( ok )
	assert.is.same( { x = 3 }, rv )
     end)

    it( "default not specified", function ()

        local template = { x = { default = 2 } }
	local ok, rv = validate( template, {} )

	assert.is_true( ok )
	assert.is.same( { x = 2 }, rv )
     end)

    it( "named", function ()

        local template = { x = { default = 2 } }
	local ok, rv = validate_opts( { named = true }, template, {} )

	assert.is_true( ok )
	assert.is.same( { x = 2 }, rv )
     end)


    it( "extra named args", function ()

        local template = { a = {}, b = {} }

	local ok, opts = validate_opts( { allow_extra = true }, template,
				       { a = 1, b = 2, c = 3 })

	assert.is_true( ok )
	assert.is.same( { a = 1, b = 2, c = nil } , opts )

	local ok, opts = validate_opts( { allow_extra = true,
					  pass_through = true
				       }, template,
				       { a = 1, b = 2, c = 3 })

	assert.is_true( ok )
	assert.is.same( { a = 1, b = 2, c = 3 } , opts )

     end)

    it( "one_of", function ( )

        local template = {
	   arg1 = { optional = true, one_of = { 'arg2', 'arg3'  } },
	   arg2 = { optional = true },
	   arg3 = { optional = true },
	}

	local ok, rv = validate( template, { arg1 = 1, arg2 = 1 } )
	assert.is_true( ok )

	local ok, rv = validate( template, { arg1 = 1, arg3 = 1 } )
	assert.is_true( ok )

	local ok, rv = validate( template, { arg1 = 1, arg2 = 1, arg3 = 1 } )
	assert.is_false( ok )
	assert.matches( 'exactly one of', rv )

     end)

    it( "bad argname", function ()

        rv = function () return end
	local template = {  [rv] = { default = 3 } }

	local ok, rv = validate_opts( { error_on_bad_spec = false },
				     template, { } )
	assert.is_false( ok )
	assert.matches( "invalid argument name", rv )

     end)

    it( "nested data", function ()

        local template = {
	   { name = 'f1', default = 1, type = 'posint' },
	   {
	      name = 'f2',
	      optional = true,
	      vtable = {
		 { name = 'f3', default = 2 },
		 { name = 'f4', default = 3 }
	      },
	   },
	}

	local ok, data = validate_opts( { named = true }, template,
				       2, { 3, 4 }
				    )
	assert.is_true( ok )
	assert.are.same( { f1 = 2, f2 = { f3 = 3, f4 = 4 } }, data )

     end)

    it( "nested defaults", function ()

        local template = {
	   { name = 'f1', default = 1 },
	   {
	      name = 'f2',
	      optional = true,
	      vtable = {
		 { name = 'f3', default = 2 },
		 { name = 'f4', default = 3 }
	      },
	   },
	}

	local ok, data = validate_opts( { named = true }, template )
	assert.is_true( ok )
	assert.are.same( { f1 = 1, f2 = { f3 = 2, f4 = 3 } }, data )

     end)

    it( "named local data", function ()

        local template = {
	   { name = 'f1', default = 1, named = true },
	   {
	      name = 'f2',
	      optional = true,
	      vtable = {
		 { name = 'f3', default = 2, named = true},
		 { name = 'f4', default = 3 }
	      },
	   },
	}

	local ok, d1, d2 = validate_opts( { check_spec = true,
					    named = false },
					 template,
					 2, { 3, 4 }
				      )
	assert.is_false( ok )
	assert.matches( "may not set", d1 )

	template[1].named = false
	local ok, d1, d2 = validate_opts( { check_spec = true,
					    named = false },
					 template,
					 2, { 3, 4 }
				      )
	assert.is_true( ok )
	assert.is.equal( 2, d1 )
	assert.is.same( { f3 = 3, [2] = 4 }, d2)

     end)

    it( "named local defaults", function ()

        local template = {
	   { name = 'f1', default = 1, named = true },
	   {
	      name = 'f2',
	      optional = true,
	      vtable = {
		 { name = 'f3', default = 2, named = true},
		 { name = 'f4', default = 3 }
	      },
	   },
	}

	local ok, d1, d2 = validate_opts( { check_spec = true,
					    named = false },
					 template )
	assert.is_false( ok )
	assert.matches( "may not set", d1 )

	template[1].named = false
	local ok, d1, d2 = validate_opts( { check_spec = true,
					    named = false },
					 template )
	assert.is_true( ok )
	assert.is.equal( 1, d1 )
	assert.is.same( { f3 = 2, [2] = 3 }, d2)

     end)


 end)
