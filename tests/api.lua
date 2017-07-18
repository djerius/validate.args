local va = require( 'validate.args' )

describe( "procedural api",  function ()

             local functions = { 'validate',
                'validate_opts',
                'validate_tbl',
                'add_type',
                'opts',
                'posnum',
                'zposnum',
                'posint',
                'zposint' }
                                 

             for _, func in pairs( functions ) do

                it( func, function ()
                       assert.is_function( va[func] )
                end)
             end


end)
