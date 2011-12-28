module( ..., package.seeall )

require 'string'

local va = require( 'validate.args' )
local validate = va.validate
local validate_opts = va.validate_opts


function test_callback_pre_static ()

   local value
   local name


   local template = { {
			 name = 'foo',
			 before = function( val, args )
					   value = val
					   name = tostring(args.name)
					end
		      }
		   }

   local ok, foo = validate( template, 'frank' )


   assert_true( ok, foo )
   assert_equal( 'frank', foo )
   assert_equal( 'frank', value )
   assert_equal( 'arg#1(foo)', name )

end

function test_callback_pre_mutate ()

   local template = { {
			 name = 'foo',
			 before = function( val, args )
					   return true, 'helga'
					end
		      }
		   }

   local ok, foo = validate( template, 'frank' )


   assert_true( ok, foo )
   assert_equal( 'helga', foo )

end

function test_callback_post_static ()

   local value
   local name


   local template = { {
			 name = 'foo',
			 after = function( val, args )
					    value = val
					    name = tostring(args.name)
					 end
		      }
		   }

   local ok, foo = validate( template, 'frank' )


   assert_true( ok, foo )
   assert_equal( 'frank', foo )
   assert_equal( 'frank', value )
   assert_equal( 'arg#1(foo)', name )


end


function test_global_before ()

   local inval, outval
   local name


   local template = { {
			 name = 'foo',
		      }
		   }

   local before = function( args )
		    inval = args[1]
		    args[1] = outval
		    return true
		 end

   outval = 'bert'
   local ok, foo = validate_opts ( { before = before }, template, 'frank' )

   assert_true( ok, foo )
   assert_equal( 'frank', inval )
   assert_equal( 'bert', foo )

end


function test_global_after ()

   local inval, outval
   local name


   local template = { {
			 name = 'foo',
		      }
		   }

   local after = function( args )
		    inval = args[1]
		    args[1] = outval
		    return true
		 end

   outval = 'larry'
   local ok, foo = validate_opts ( { after = after }, template, 'frank' )

   assert_true( ok, foo )
   assert_equal( 'frank', inval )
   assert_equal( 'larry', foo )

end


function test_callback_post_mutate ()

   local value
   local name


   local template = { {
			 name = 'foo',
			 enum = { 'frank' },
			 after = function( val, args )
					    assert_equal( 'frank', val)
					    return true, 'helga'
					 end
		      }
		   }

   local ok, foo = validate( template, 'frank' )
   assert_true( ok, foo )
   assert_equal( 'helga', foo )

end


