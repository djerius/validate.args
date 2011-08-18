module( ..., package.seeall )

local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

require 'table'

function test_none ()

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

   assert_true( ok, args )

   assert_equal( 'a', args.a )
   assert_equal( 'b', args.b )
   assert_equal( 'c', args.c )
   assert_equal( 'd', args.d )

   assert_equal( 'a', list[1] )
   assert_equal( 'd', list[2] )
   assert_equal( 'c', list[3] )
   assert_equal( 'b', list[4] )

end

