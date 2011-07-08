require 'lunatest'
require 'strict'
local va = require( 'validate.args' )

function setup() 

   va.reset()
   va.opts{ check_spec = true,
	    error_on_bad_spec = true,
	 }
end

tests = {
   'named',
   'constraints',
   'deffunc',
   'vtypes',
   'positional',
   'nested',
   'requires',
   'excludes',
   'special',
   'mutate',
   'object',
   'defaults',
   'callback',
   'inplace',
}

for _, v in pairs(tests) do
   lunatest.suite( v )
end

lunatest.run()
