module( ..., package.seeall )

require('deepcompare')

va = require('validate.args')

setup = _G.setup

require 'string'
require 'table'

local success = {
   ['number']   = 33.2,
   ['string']   = 'string',
   ['boolean']  = false,
   ['table']    = {},
   ['posint']   = 1,
   ['zposint']  = 0,
   ['posnum' ]  = 1.2,
   ['zposnum' ] = 0,
   ['function'] = function() end,
   [{ 'number', 'string'} ] = 'string',
   [{ 'number', 'string'} ] = 99,
   [{ 'number', 'boolean'} ] = 22,
   [{ 'number', 'boolean'} ] = false,
   [{ 'number', 'boolean', 'string'} ] = 'green',
   [{ 'number', 'boolean', 'string', 'table'} ] = { 88, 22, 'frank' },
   [{ 'number', 'boolean', 'string', 'table', 'function'} ] = function() end,
}

local failure = {
   ['number']   = success['string'],
   ['string']   = success['function'],
   ['boolean']  = success['table'],
   ['table' ]   = success['number'],
   ['function'] = success['boolean'],
   ['posnum']   = 'a',
   ['zposnum']  = 'a',
   ['posnum']   = 0,
   ['zposnum']  = -1,
   ['posint']   = 0,
   ['zposint']  = -1,
   ['posint']   = 'b',
   ['zposint']  = 'b',
   [{ 'number', 'boolean', 'string'} ] = function() end,
   ['badtype'] = 8,
}


function populate( success, inputs )


   for t, v in pairs( inputs ) do

      local test_name = t
      if type(t) == 'table' then
	 test_name = table.concat( t, '_' )
      end

      if  success then
	 test_name = 'test_success_' .. test_name
      else
	 test_name = 'test_failure_' .. test_name
      end

      _M[test_name] =
	 function( )
	    local template = { { type = t } }

	    local ok, foo = va.validate_opts( { error_on_bad_spec = false},
					      template, v )

	    if ( success ) then
	       assert_true( ok, foo )

	       if type(v) == 'function' then
		  assert_function( foo )
		  assert_true( foo == v )
	       elseif type(v) == 'table' then
		  assert_table( foo )
		  assert_true( deepcompare( v, foo ) )
	       else
		  assert_equal( v, foo, foo )
	       end
	    else
	       assert_false( ok, test_name )
	    end
	 end
   end

end

populate( true, success )
populate( false, failure )


function test_add_type()

   va.add_type( 'mytype', function( arg ) return arg == 'success', 'ubet' end )

   local template = { { type = 'mytype' } }
   local ok, foo = va.validate( template, 'success' )

   if ( ok ) then
      assert_true( ok, 'validate' )
      assert_equal( 'ubet', foo )
   else
      assert_false( ok, 'validate' )
   end

end

function test_heterogeneous()

   local template = { { type = { 'posint',
				 enum = { enum = { 'a', 'b', 'c' } }
			      },
		  } }

   local ok, foo = va.validate( template, 1 )

   assert_true( ok, foo )


end

function test_nested1()

   local template = { { type = { 'posint',
				 validate = {
				    vtable = {
				       data = {
					  type = { 'string', 'posint' },
				       },
				    },
				 },
			      },
		  } }

   local ok, foo = va.validate( template, 1 )
   assert_true( ok, foo )
   assert_equal( 1, foo )

   local ok, foo = va.validate( template, { data = 3 } )
   assert_true( ok, foo )
   assert_equal( 3, foo.data )

   local ok, foo = va.validate( template, { data = 'frank' } )
   assert_true( ok, foo )
   assert_equal( 'frank', foo.data )


end


function test_nested2()

   local template = { { type = { 'posint',
				 validate = {
				    vtable = {
				       data = {
					  type = {
					     'string',
					     'posint',
					     table = {
						vtable = {
						   snack = {
						      type = 'posint'
						   }
						}
					     }
					  },
				       },
				    },
				 },
			      },
		  } }

   local ok, foo = va.validate( template, 1 )
   assert_true( ok, foo )
   assert_equal( 1, foo )

   local ok, foo = va.validate( template, { data = 3 } )
   assert_true( ok, foo )
   assert_equal( 3, foo.data )

   local ok, foo = va.validate( template, { data = 'frank' } )
   assert_true( ok, foo )
   assert_equal( 'frank', foo.data )

   local ok, foo = va.validate( template, { data = { snack = 3 } } )
   assert_true( ok, foo )
   assert_equal( 3, foo.data.snack )


end

function test_nested3()

   local template = { { type = { 'posint',
				 validate = {
				    vtable = {
				       data = {
					  type = {
					     'string',
					     'posint',
					     table = {
						vtable = {
						   snack = {
						      type = { 'posint',
							       'string'
							    },
						   }
						}
					     }
					  },
				       },
				    },
				 },
			      },
		  } }

   local ok, foo = va.validate( template, 1 )
   assert_true( ok, foo )
   assert_equal( 1, foo )

   local ok, foo = va.validate( template, { data = 3 } )
   assert_true( ok, foo )
   assert_equal( 3, foo.data )

   local ok, foo = va.validate( template, { data = 'frank' } )
   assert_true( ok, foo )
   assert_equal( 'frank', foo.data )

   local ok, foo = va.validate( template, { data = { snack = 3 } } )
   assert_true( ok, foo )
   assert_equal( 3, foo.data.snack )

   local ok, foo = va.validate( template, { data = { snack = 'foo' } } )
   assert_true( ok, foo )
   assert_equal( 'foo', foo.data.snack )


end

function test_nested22()
   local specs = {

      spectrum = {

	 multiple = true,

	 type = {

	    picket = {
	       vtable = {
		  type = { enum = { 'picket' } },
		  data = {
		     multiple = true,
		     type = {
			'posint',
			energy_flux = { 
			   vtable = { { type = 'posnum' },
				      { type = 'zposnum' },
				   },
			}
		     } 
		  },
	       },
	    },
	 },
      },

   }

   local ok, foo = va.validate( specs, 
				{ spectrum = {
				     { type = 'picket',
				       data = { 3,
						{ 1, 2 },
						{ 3, 4 },
					     },
				    }
				  },
			       }
			     )

   assert_true( ok, foo )



end

function test_nested33()
   local specs = {

      spectrum = {

	 type = {

	    picket = {
	       vtable = {
		  type = { enum = { 'picket' } },
		  data = {
		     type = {
			'posint',
			energy_flux = { 
			   vtable = { { type = 'posnum' },
				      { type = 'zposnum' },
				   },
			}
		     } 
		  },
	       },
	    },
	 },
      },

   }

   local ok, foo = va.validate( specs, 
				{ spectrum = 
				     { type = 'picket',
				       data = { 1, 2 },
				    }
			       }
			     )

   assert_true( ok, foo )



end
