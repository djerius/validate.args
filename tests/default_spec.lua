module( ..., package.seeall )

va = require( 'validate.args' )
validate = va.validate
validate_opts = va.validate_opts

setup = _G.setup

function test_pos_named( )

   local template = {
			['%named'] = function( k, v, vfargs )
					return true, { optional = true, 
						       vtable = { a = { type = 'posint', default = 3 },
								  b = { type = 'posint', default = 4  },
							       },
						    }
				     end,
			['%pos'] = function( k, v, vfargs )
				    return true, { name = 'frank', type = 'string' }
				 end,
		  }

   local ok, foo = validate_opts( { named = true}, template, { 'sue', gary = {} } )

   assert_true( ok, foo )

   assert_equal( 'sue', foo.frank )
   assert_equal( 3, foo.gary.a )
   assert_equal( 4, foo.gary.b )

end

function test_pos_acceptable( )

   local template = {

      ['%pos'] = function( k, v, vfargs )
		    if k == 1 then
		       return true, { name = 'first', type = 'string' }
		    elseif k == 2 then
		       return false
		    end
		       return false, "funky"
		 end
   }

   local ok, args = validate_opts( { named = true }, template,
				{ 'a' } )
   assert_true( ok, args )
   assert_equal( 'a', args.first )

   local ok, args = validate_opts( { named = true }, template,
				{ 'a', 'b' } )
   assert_false( ok, args )
   assert_match( "unexpected element", args )

   local ok, args = validate_opts( { named = true }, template,
				   { 'a', [3] = 'b' } )
   assert_false( ok, args )
   assert_match( "funky", args )

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
