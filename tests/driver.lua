require 'lunatest'

tests = { 'named',
	  'constraints',
	  'vtypes',
	  'positional',
	  'nested',
       }

for _, v in pairs(tests) do
   lunatest.suite( v )
end

lunatest.run()
