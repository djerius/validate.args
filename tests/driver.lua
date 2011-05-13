require 'lunatest'
require 'strict'
local va = require( 'validate.args' )

va.opts{ check_spec = true,
	 error_on_bad_spec = true,
	 -- debug = true
      }

tests = { 'named',
	  'constraints',
	  'deffunc',
	  'vtypes',
	  'positional',
	  'nested',
	  'requires',
	  'excludes',
	  'special',
	  'mutate'
       }

for _, v in pairs(tests) do
   lunatest.suite( v )
end

lunatest.run()
