module( ..., package.seeall )

va = require( 'validate.args' )
validate = va.validate
validate_opts = va.validate_opts

setup = _G.setup

function test_not_table( )

   local template = { {
			 vtable = {
			    arg1 = { enum = { 'a', 'b' } },
			    arg2 = { type = 'number' },
			 }
		   } }

   local ok, foo = validate( template, 3 )

   assert_false( ok, 'validate' )
   assert_match('incorrect type' , foo )

end

function test_one_level( )

   local template = { {
			 vtable = {
			    arg1 = { enum = { 'a', 'b' } },
			    arg2 = { type = 'number' },
			 }
		   } }

   local ok, foo = validate( template, {
				arg1 = 'a',
				arg2 = 3
			     }
			  )

   assert_true( ok, 'validate' )
   assert_equal( 'a', foo.arg1 )
   assert_equal( 3, foo.arg2 )

end

function test_two_levels( )

   local template = { {
			 vtable = {
			    arg1 = { enum = { 'a', 'b' } },
			    arg2 = { type = 'number' },
			    arg3 = { type = 'table',
				     vtable = {
					arg31 = { type = 'string' },
					arg32 = { type = 'function' },
					arg33 = { type = 'number',
						  default = 99 }
				     }
				  }
			 }
		   } }

   local ok, foo = validate( template, {
				arg1 = 'a',
				arg2 = 3,
				arg3 = { arg31 = 'foo',
					 arg32 = function() return 88.3 end,
				      }
			     }
			  )

   assert_true( ok, 'validate' )
   assert_equal( 'a', foo.arg1 )
   assert_equal( 3, foo.arg2 )
   assert_equal( 'foo', foo.arg3.arg31 )
   assert_function( foo.arg3.arg32)
   assert_equal( 88.3, foo.arg3.arg32() )
   assert_equal( 99, foo.arg3.arg33 )

end

function test_two_levels_defaults ()

   local template = { { vtable = {
			   arg3 = { type = 'table',
				    vtable = {
				       arg33 = { type = 'number',
						 default = 99 }
				    }
				 }
			}
		  } }

   local ok, foo = validate( template, { arg3 = {} }  )

   assert_true( ok, 'validate' )
   assert_equal( 99, foo.arg3.arg33 )

end

function test_invalid_spec ()

   local template = { { vtable = {
			   arg3 = { type = 'table',
				    vtable = {
				       arg33 = { snarf = 3,
						 default = 99 }
				    }
				 }
			}
		  } }

   local ok, foo = validate_opts( {
				    error_on_bad_spec = false
				 },
				 template, { arg3 = {} }  )

   assert_false( ok, 'validate' )

   assert_match( 'snarf', foo )

end


function test_vtable_func ()

   local template = { { vtable = function (arg)
				    if arg.a then
				       return true, { a = { },
						b = { },
					     }
				    else
				       return true, { c = { },
						b = { },
					     }
				    end
				 end


		  } }


   local ok, foo = validate( template, { a = 1, b = 2 } )
   assert_true( ok, 'a,b' )

   local ok, foo = validate( template, { c = 1, b = 2 } )
   assert_true( ok, 'c,b' )

   local ok, foo = validate( template, { a = 1, b = 2, c = 3 } )
   assert_false( ok, 'a,b,c' )

   local ok, foo = validate( template, { d = 1, b = 2, c = 3 } )
   assert_false( ok, 'd,b,c' )

end

function test_vtable_func_example ()

   local specs = { gaussian = { {}, sigma = { type = 'number' } },
		   uniform  = { {},  },
		   powerlaw = { {}, alpha = { type = 'number' } },
		 }

   local template =
      { idist = {
	   vtable = function (arg)
		       local vtable = specs[arg[1]]
		       if vtable then
			  return true, vtable
		       else
			  return false, "unknown idist: " .. tostring(arg)
		       end
		    end
	}
     }


   local ok, foo = validate( template, { idist = { 'gaussian', sigma = 3 } } )
   assert_true( ok, 'gaussian' )

   local ok, foo = validate( template, { idist = { 'gaussian', sigmax = 3 } } )
   assert_false( ok, 'bad gaussian' )

   local ok, foo = validate( template, { idist = { 'uniform' } } )
   assert_true( ok, 'uniform' )

   local ok, foo = validate( template, { idist = { 'powerlaw', alpha = 4 } } )
   assert_true( ok, 'powerlaw' )

   local ok, foo = validate( template, { idist = { 'snackbar' } } )
   assert_false( ok, 'snackbar' )


end


function test_bad_vtable_func ()

   local template = { { vtable = function (arg)
				    if arg.a then
				       return true, { a = { spanky = true },
						      b = { },
					     }
				    else
				       return true, { c = { },
						b = { },
					     }
				    end
				 end


		  } }


   local ok, foo = validate_opts( {
				    error_on_bad_spec = false
				 },
				 template, { a = 1, b = 2 } )
   assert_false( ok, 'a,b' )

   local ok, foo = validate( template, { c = 1, b = 2 } )
   assert_true( ok, 'c,b' )

end
