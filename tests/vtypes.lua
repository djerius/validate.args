module( ..., package.seeall )

validate = require('validate.args').validate

require 'string'
require 'table'

local success = { 
   ['number']   = 33.2,
   ['string']   = 'string',
   ['boolean']  = false,
   ['table' ]   = {},
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
   [{ 'number', 'boolean', 'string'} ] = function() end,
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
	    local ok, foo = validate( template, v )

	    if ( success ) then
	       assert_true( ok )
	       assert_equal( v, foo )
	    else
	       assert_false( ok )
	    end
	 end 
      
   end

end

populate( true, success )
populate( false, failure )
