module( ..., package.seeall )

va = require( 'validate.args' )
validate = va.validate
validate_opts = va.validate_opts

setup = _G.setup

function test_pos_named( )

   local template = {
			['%named'] = function( k, vfargs )
					return true, { optional = true, 
						       vtable = { a = { type = 'posint', default = 3 },
								  b = { type = 'posint', default = 4  },
							       },
						    }
				     end,
			['%pos'] = function( k, vfargs )
				    return true, { name = 'frank', type = 'string' }
				 end,
		  }

   local ok, foo = validate_opts( { named = true}, template, { 'sue', gary = {} } )

   assert_true( ok, foo )

   assert_equal( 'sue', foo.frank )
   assert_equal( 3, foo.gary.a )
   assert_equal( 4, foo.gary.b )

end

function test_default( )

   local template = {
			['%default'] = function( k, v, vfargs )
					  if type(v) == 'table' then
					     return true, { optional = true, 
							    vtable = { a = { type = 'posint', default = 3 },
								       b = { type = 'posint', default = 4  },
								    },
							 }
					  else
					     return true, { name = 'frank', type = 'string' }
					  end
				       end,
		  }

   local ok, foo = validate_opts( { named = true}, template, { 'sue', gary = {} } )

   assert_true( ok, foo )

   assert_equal( 'sue', foo.frank )
   assert_equal( 3, foo.gary.a )
   assert_equal( 4, foo.gary.b )

end

function test_not_match( )

   local template = {
			['%default'] = function( k, v, vfargs )
					  if k == 'harry' then
					     return false
					  else
					     return true, { type = 'posint' }
					  end
				       end,
		  }

   local ok, foo = validate( template, { harry = 3, gary = 2 } )

   assert_false( ok, foo )
   assert_match( 'unexpected element', foo )

end
