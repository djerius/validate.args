require 'lunatest'
local va = require( 'validate.args' )

va.opts{ check_spec = true,
	 error_on_bad_spec = true,
	 -- debug = true
      }

tests = { 'named',
	  'constraints',
	  'vtypes',
	  'positional',
	  'nested',
	  'requires',
	  'excludes',
	  'special'
       }

for _, v in pairs(tests) do
   lunatest.suite( v )
end

lunatest.run()
