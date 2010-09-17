module( ..., package.seeall )

validate = require( 'validate.args' ).validate

function test_req_scalar( )

   local template = {
      arg1 = { optional = true, requires = 'arg2' },
      arg2 = { optional = true },
   }

   local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )

   assert_true( ok )

   local ok, foo = validate( template, { arg1 = 1 } )
   assert_false( ok )
   assert_match('argument.*without' , foo )

   local ok, foo = validate( template, { arg2 = 1 } )
   assert_true( ok )

end

function test_req_list( )

   local template = {
      arg1 = { optional = true, requires = { 'arg2' } },
      arg2 = { optional = true },
   }

   local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )

   assert_true( ok )

   local ok, foo = validate( template, { arg1 = 1 } )
   assert_false( ok )
   assert_match('argument.*without' , foo )

   local ok, foo = validate( template, { arg2 = 1 } )
   assert_true( ok )

end

function test_req_both( )

   local template = {
      arg1 = { optional = true, requires = 'arg2' },
      arg2 = { optional = true, requires = 'arg1' },
   }

   local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )

   assert_true( ok )

   local ok, foo = validate( template, { arg2 = 1 } )

   assert_false( ok )
   assert_match('argument.*without' , foo )

   local ok, foo = validate( template, { arg1 = 1 } )

   assert_false( ok )
   assert_match('argument.*without' , foo )

end

function test_req_multiple( )

   local template = {
      arg1 = { optional = true },
      arg2 = { optional = true, requires = { 'arg1', 'arg3' } },
      arg3 = { optional = true }
   }

   local ok, foo = validate( template, { arg1 = 1, arg2 = 1, arg3 = 1 } )
   assert_true( ok )

   local ok, foo = validate( template, { arg1 = 1, arg3 = 1 } )
   assert_true( ok )

   local ok, foo = validate( template, { arg1 = 1, arg2 = 1 } )
   assert_false( ok )
   assert_match('argument.*without' , foo )


end

