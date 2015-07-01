local va = require('validate.args')

setup = require 'setup'

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

      it( test_name, function ()

	  local template = { { type = t } }

	  local ok, rv = va.validate_opts( { error_on_bad_spec = false},
					  template, v )

	  if ( success ) then
	     assert.is_true( ok )

	     if type(v) == 'function' then
		assert.is_function( rv )
		assert.is.equal( v, rv )
	     elseif type(v) == 'table' then
		assert.is_table( rv )
		assert.is_same( v, rv )
	     else
		assert.is.equal( v, rv )
	     end
	  else
	     assert.is_false( ok )
	  end
       end)
   end

end

describe( "vtypes", function ()

    before_each( setup )

    populate( true, success )

    populate( false, failure )


    it( "add type", function ()

       va.add_type( 'mytype', function( arg ) return arg == 'success', 'ubet' end )

       local template = { { type = 'mytype' } }
       local ok, rv = va.validate( template, 'success' )

       if ( ok ) then
	  assert.is_true( ok )
	  assert.is.equal( 'ubet', rv )
       else
	  assert.is_false( ok )
       end

    end)

    it( "heterogeneous", function ()

       local template = { { type = { 'posint',
				     enum = { enum = { 'a', 'b', 'c' } }
				  },
		      } }

       local ok, rv = va.validate( template, 1 )

       assert.is_true( ok )


    end)

    it( "nested1", function ()

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

       local ok, rv = va.validate( template, 1 )
       assert.is_true( ok )
       assert.is.equal( 1, rv )

       local ok, rv = va.validate( template, { data = 3 } )
       assert.is_true( ok )
       assert.is.equal( 3, rv.data )

       local ok, rv = va.validate( template, { data = 'frank' } )
       assert.is_true( ok )
       assert.is.equal( 'frank', rv.data )


    end)


    it( "nested2", function ()

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

       local ok, rv = va.validate( template, 1 )
       assert.is_true( ok )
       assert.is.equal( 1, rv )

       local ok, rv = va.validate( template, { data = 3 } )
       assert.is_true( ok )
       assert.is.equal( 3, rv.data )

       local ok, rv = va.validate( template, { data = 'frank' } )
       assert.is_true( ok )
       assert.is.equal( 'frank', rv.data )

       local ok, rv = va.validate( template, { data = { snack = 3 } } )
       assert.is_true( ok )
       assert.is.equal( 3, rv.data.snack )


    end)

    it( "nested3", function ()

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

       local ok, rv = va.validate( template, 1 )
       assert.is_true( ok )
       assert.is.equal( 1, rv )

       local ok, rv = va.validate( template, { data = 3 } )
       assert.is_true( ok )
       assert.is.equal( 3, rv.data )

       local ok, rv = va.validate( template, { data = 'frank' } )
       assert.is_true( ok )
       assert.is.equal( 'frank', rv.data )

       local ok, rv = va.validate( template, { data = { snack = 3 } } )
       assert.is_true( ok )
       assert.is.equal( 3, rv.data.snack )

       local ok, rv = va.validate( template, { data = { snack = 'rv' } } )
       assert.is_true( ok )
       assert.is.equal( 'rv', rv.data.snack )


    end)

    it( "nested22", function ()
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

       local ok, rv = va.validate( specs,
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

       assert.is_true( ok )



    end)

    it( "nested33", function ()
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

       local ok, rv = va.validate( specs,
				    { spectrum =
					 { type = 'picket',
					   data = { 1, 2 },
					}
				   }
				 )

       assert.is_true( ok )

    end)
end)
