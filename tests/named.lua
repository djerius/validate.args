module( ..., package.seeall )

local validate = require( 'validate.args' ).validate

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




lunatest.run()
