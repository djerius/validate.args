module( ..., package.seeall )

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
	       assert_equal( v, foo, foo )
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

