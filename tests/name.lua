module( ..., package.seeall )

local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts

require 'string'

function test_basic ()

   local name = va.Name:new{ 'a', 'b', 'c' }

   assert_equal( 'a', name.name[1] )
   assert_equal( 'b', name.name[2] )
   assert_equal( 'c', name.name[3] )

   assert_equal( 'a.b.c', name:tostring() )

end

function test_positional ()

   local name = va.Name:new{ 'a', '1', 'c' }

   assert_equal( 'a', name.name[1] )
   assert_equal( '1', name.name[2] )
   assert_equal( 'c', name.name[3] )

   assert_equal( 'a[1].c', name:tostring() )

end
