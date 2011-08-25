module( ..., package.seeall )

local va = require( 'validate.args' )

setup = _G.setup

-- simple test of OO interface; most of the testing is done
-- via the procedural interface as that came first.

function test_multiple__required__not_specified ()

   local template = { { allow_nil = true }, { optional = false } }
   local ok, err = va:new():validate( template, nil )

   assert_false( ok )
   assert_match( 'arg#2: missing', err )

end

function test_multiple__required__not_specified__with_name ()

   local template = { { allow_nil = true }, { name = 'arg2',
					      optional = false } }
   local ok, err = va:new():validate( template, nil )

   assert_false( ok )
   assert_match( 'arg#2%(arg2%): missing', err )

end


-- test options

function test_bad_options ()

   local obj = va:new()

   assert_error( function ()
		    obj.opts.DOES_NOT_EXIST = true
		 end,
		 "bad option assign" )

   assert_error( function ()
		    obj:setopts{ DOES_NOT_EXIST = true }
		 end,
		 "bad option set" )

end


function test_cvs_pos_to_named ()

   local template = { {
			 name = 'arg2',
			 optional = false,
			 not_nil = true,
		      },
		      {
			 type = 'string',
		      }
		   }
   local obj = va:new()
   obj.opts.named = true

   local ok, opts = obj:validate( template, 32, 'foo' )

   assert_true( ok )
   assert_equal( 32, opts.arg2 )
   assert_equal( 'foo', opts[2] )


end

function test_extra_pos_args ()

   local template = { {}, {} }
   local obj = va:new()
   obj:setopts{ allow_extra = true }

   local ok, a, b, c = obj:validate( template, 1, 2, 3)

   assert_true( ok )
   assert_equal( 1, a )
   assert_equal( 2, b )
   assert_equal( nil, c )

   obj:setopts{ allow_extra = true,
		pass_through = true,
	     }

   local ok, a, b, c = obj:validate( template, 1, 2, 3)

   assert_true( ok )
   assert_equal( 1, a )
   assert_equal( 2, b )
   assert_equal( 3, c )

end


function test_constructor()

   va.opts{ allow_extra = true };
   va.add_type( 'test', function () end )
   local obj = va:new{ use_current_options = true };

   assert_true( obj.opts.allow_extra, 'current options' )

   local obj = va:new{ use_current_types = true };

   assert_function( obj.types:validator('test'), 'current types' )

end

-- test inheritance

function test_level_0 ()

   local vobj

   -- first make sure we know what the base value for our test
   -- option is. currently there's no way to get this directly, so
   -- create a new object and use it to find out what it is
   vobj = va:new()

   local base_val = vobj.opts.check_spec

   -- now change the default (not base) and make sure our object
   -- doesn't track it.
   va.opts{ check_spec = not base_val }
   assert_equal( base_val, vobj.opts.check_spec, "child doesn't track default" )

   -- now clone an object
   local clone = vobj:new()
   assert_equal( vobj.opts.check_spec, clone.opts.check_spec, 'clone, unchanged' )

   -- change in value in original object should not affect the clone
   vobj.opts.check_spec = not base_val
   assert_not_equal( clone.opts.check_spec, vobj.opts.check_spec, "clone doesn't track parent" )
   vobj.opts.check_spec = base_val

   -- change in value in clone should not affect the parent
   clone.opts.check_spec = not base_val
   assert_equal( vobj.opts.check_spec, base_val, "parent doesn't track clone" )

end


function test_options_udata( )

   local vobj = va:new()
   local udata = {}

   vobj:setopts{ udata = udata }

   local ok, val = vobj:validate( { { postcall = function( arg, vfarg )
						  vfarg.va:getopt('udata').called = true
					       end
				 }
			       }, 1 )

   assert_true( ok, val )
   assert_equal( val, 1 )
   assert_true( udata.called )

end
