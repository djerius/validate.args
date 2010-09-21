module( ..., package.seeall )

va = require( 'validate.args' )
validate = va.validate
validate_opts = va.validate_opts

function test_table_mutation( )

   local template =  {
			 vtable = {
			    arg1 = { enum = { 'a', 'b' } },
			    arg2 = { type = 'number' },
			 }
		   }


   local ok, foo = validate( { function () return true, template end },
			    {
			       arg1 = 'a',
			       arg2 = 3
			    }
			  )

   assert_true( ok )
   assert_equal( 'a', foo.arg1 )
   assert_equal( 3, foo.arg2 )

end

function test_table_mutation_args( )

   local spec = function ( arg )
		   return true, { not_nil = true,
				  type = type(arg) == 'function'
				               and 'string' or type(arg)
			       }
		end


   local ok, foo = validate( { spec }, 3 )
   assert_true( ok )
   assert_equal( 3, foo )

   local ok, foo = validate( { spec } )
   assert_false( ok )

   local ok, foo = validate( { spec }, function () end )
   assert_false( ok )

end

function test_nested_mutation( )

   local template =  {
			 vtable = {
			    arg1 = { enum = { 'a', 'b' } },
			    arg2 = { type = 'number' },
			    arg3 = function( arg) return true, {} end,
			 }
		   }


   local ok, foo = validate( { template } ,
			    {
			       arg1 = 'a',
			       arg2 = 3,
			       arg3 = 2
			    }
			  )

   assert_true( ok )
   assert_equal( 'a', foo.arg1 )
   assert_equal( 3, foo.arg2 )
   assert_equal( 2, foo.arg3 )

end

