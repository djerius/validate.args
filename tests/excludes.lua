module( ..., package.seeall )

validate = require( 'validate.args' ).validate

function test_exclude_scalar( )

   local template = {
      arg1 = { optional = true, excludes = 'arg2' },
      arg2 = { optional = true },
   }

   local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )

   assert_false( ok )
   assert_match('argument.*and' , foo )

   local ok, foo = validate( template, { arg1 = 1 } )
   assert_true( ok )

   local ok, foo = validate( template, { arg2 = 1 } )
   assert_true( ok )


end

function test_exclude_list( )

   local template = {
      arg1 = { optional = true, excludes = { 'arg2'  } },
      arg2 = { optional = true },
   }

   local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )

   assert_false( ok )
   assert_match('argument.*and' , foo )

   local ok, foo = validate( template, { arg1 = 1 } )
   assert_true( ok )

   local ok, foo = validate( template, { arg2 = 1 } )
   assert_true( ok )


end


function test_exclude_both( )

   local template = {
      arg1 = { optional = true, excludes = 'arg2' },
      arg2 = { optional = true, excludes = 'arg1' },
   }

   local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )

   assert_false( ok )
   assert_match('argument.*and' , foo )

   local ok, foo = validate( template, { arg2 = 1 } )

   assert_true( ok )

   local ok, foo = validate( template, { arg1 = 1 } )

   assert_true( ok )

end

function test_exclude_multiple( )

   local template = {
      arg1 = { optional = true, excludes = { 'arg2', 'arg3' } },
      arg2 = { optional = true, },
      arg3 = { optional = true, },
   }

   local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )
   assert_false( ok )
   assert_match("arguments 'arg1' and 'arg2'" , foo )

   local ok, foo = validate( template, { arg1 = 1, arg3 = 1 } )
   assert_false( ok )
   assert_match("arguments 'arg1' and 'arg3'" , foo )

end

