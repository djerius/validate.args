module( ..., package.seeall )

require 'string'

local validate = require('validate.args')
local inplace = require( 'validate.inplace' )

function test_simple ()

   local spec = {
      foo = { type = 'posint' },
   }

   local va = validate:new()

   local obj = inplace:new( 'test', spec, va )

   local test = obj:proxy()

   test.foo = 3

   assert_equal( 3, test.foo, "assign" )

   copy = obj:copy()

   -- make sure this is a clean table
   assert_nil( getmetatable( copy ))
   assert_equal( 3, rawget( copy, 'foo'), "copy" )

   -- try to do something wrong
   local ok, error = pcall( function () test.foo = -3 end )

   assert_false( ok, "bad type" )
   assert_match( 'test.foo:.*posint', error, error )


end

function test_vtable ()

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

   assert_equal( 9,  test.foo, "default" )
   assert_equal( 33, test.goo.a, "default" )
   assert_equal( 44, test.goo.b, "default" )


   test.foo = 3
   assert_equal( 3, test.foo, "assign" )

   test.goo.a = 4
   assert_equal( 4, test.goo.a, "assign" )

   test.goo.b = 8
   assert_equal( 8, test.goo.b, "assign" )


   -- try assigning a table
   -- this should reset things to default
   test.goo = { }

   assert_equal( 33, test.goo.a, 'table reset' )
   assert_equal( 44, test.goo.b, 'table reset' )

   -- set a ; b should get reset to default
   test.goo = {  a = 88 }

   assert_equal( 88, test.goo.a, 'table reset' )
   assert_equal( 44, test.goo.b, 'table reset' )

   -- try to do things wrong
   local ok, error = pcall( function () test.goo.b = -3 end )

   assert_false( ok, "bad type" )
   assert_match( 'test.goo.b:.*posint', error, error )


   local ok, error = pcall( function () test.goo.c = -3 end )
   assert_false( ok, "unknown element" )
   assert_match( 'test.goo.c:.*unknown', error, error )

   local ok, error = pcall( function () test.goo = -3 end )
   assert_false( ok, "bad table" )
   assert_match( 'test.goo:.*incorrect type', error, error )



end


function test_copy ()


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

   assert_nil( getmetatable(copy), "no test metatable" )
   assert_nil( getmetatable(copy.goo), "no test.goo metatable" )

   assert_equal( 9, copy.foo, "copy.foo" )
   assert_equal( 33, copy.goo.a, "copy.goo.a" )
   assert_equal( 44, copy.goo.b, "copy.goo.b" )

   local test = obj:proxy()
   test.goo.b = 99
   assert_equal( 99, test.goo.b )
   assert_equal( 44, copy.goo.b, "copy.goo.b" )

   copy = obj:copy()
   assert_equal( 99, copy.goo.b )

end
