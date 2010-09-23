module( ..., package.seeall )

local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

require 'string'

function test_optional__but_specified ()

   local template = { x = { optional = true }}
   local ok, foo = validate( template, { x = 3 } )

   assert_true( ok )
   assert_equal( 3, foo.x )
end


function test_optional__not_specified ()

   local template = { x = { optional = true }}
   local ok, foo = validate( template, {} )

   assert_true( ok )
   assert_equal( nil, foo.x )
end

function test_required__specified ()

   local template = { x = { }}
   local ok, foo = validate( template, { x = 3 } )

   assert_true( ok )
   assert_equal( 3, foo.x )
end


function test_required__not_specified ()

   local template = { x = { }}
   local ok, foo = validate( template, {} )

   assert_false( ok )
   assert_match( 'required but not specified', foo )
end

function test_default__but_specified ()


   local template = { x = { default = 2 } }
   local ok, foo = validate( template, { x = 3 } )

   assert_true( ok )
   assert_equal( 3, foo.x )
end

function test_default__not_specified ()


   local template = { x = { default = 2 } }
   local ok, foo = validate( template, {} )

   assert_true( ok )
   assert_equal( 2, foo.x )
end

function test_named ()


   local template = { x = { default = 2 } }
   local ok, foo = validate_opts( { baseOptions = true,
				    named = true }, template, {} )

   assert_true( ok )
   assert_equal( 2, foo.x )
end


function test_extra_named_args ()

   local template = { a = {}, b = {} }

   local ok, opts = validate_opts( { baseOptions = true,
				     allow_extra = true }, template,
				     { a = 1, b = 2, c = 3 })

   assert_true( ok )
   assert_equal( 1, opts.a )
   assert_equal( 2, opts.b )
   assert_equal( nil, opts.c )

   local ok, opts = validate_opts( { baseOptions = true,
				     allow_extra = true,
				     pass_through = true
				  }, template,
				  { a = 1, b = 2, c = 3 })

   assert_true( ok )
   assert_equal( 1, opts.a )
   assert_equal( 2, opts.b )
   assert_equal( 3, opts.c )


end

function test_one_of( )

   local template = {
      arg1 = { optional = true, one_of = { 'arg2', 'arg3'  } },
      arg2 = { optional = true },
      arg3 = { optional = true },
   }

   local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )
   assert_true( ok )

   local ok, foo = validate( template, { arg1 = 1, arg3 = 1 } )
   assert_true( ok )

   local ok, foo = validate( template, { arg1 = 1, arg2 = 1, arg3 = 1 } )
   assert_false( ok )
   assert_match( 'exactly one of', foo )

end

function test_bad_argname()

   foo = function () return end
   local template = {  [foo] = { default = 3 } }

   local ok, foo = validate_opts( { baseOptions = true,
				    error_on_bad_spec = false },
				    template, { } )
   assert_false( ok )
   assert_match( "invalid argument name", foo )

end
