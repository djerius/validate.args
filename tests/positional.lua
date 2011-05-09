module( ..., package.seeall )

local va = require( 'validate.args' )
local validate, validate_opts = va.validate, va.validate_opts

function test_template_is_a_table ()

   local ok, err = validate( 'x', 'x' )

   assert_false( ok )
   assert_match( 'expected table', err )

end

function test_optional__but_specified ()

   local template = { { optional = true } }
   local ok, foo = validate( template, 'x' )

   assert_true( ok )
   assert_equal( 'x', foo )

end

function test_optional__not_specified ()

   local template = { { optional = true } }
   local ok, foo = validate( template )

   assert_true( ok )
   assert_equal( nil, foo )

end


function test_default__not_specified ()

   local template = { { default = 'foo' } }
   local ok, foo = validate( template )

   assert_true( ok )
   assert_equal( 'foo', foo )

end

function test_optional__specified_as_nil ()

   local template = { { default = 'foo' }, { default = 'bar' } }
   local ok, foo, bar = validate( template )

   assert_true( ok )
   assert_equal( 'foo', foo, ': foo' )
   assert_equal( 'bar', bar, ': bar' )

end

function test_required__specified_as_nil ()

   local template = { { optional = false }, { optional = false } }
   local ok, foo, bar = validate( template, nil, nil )

   assert_true( ok )
   assert_equal( nil, foo, ': foo' )
   assert_equal( nil, bar, ': bar' )


   ok, foo, bar = validate( template, nil, 'x' )

   assert_true( ok )
   assert_equal( nil, foo, ': foo 2' )
   assert_equal( 'x', bar, ': bar 2' )

end

function test_multiple__required__not_specified ()

   local template = { { optional = false }, { optional = false } }
   local ok, err = validate( template, nil )

   assert_false( ok )
   assert_match( 'arg#2: missing', err )

end

function test_multiple__required__not_specified__with_name ()

   local template = { { optional = false }, { name = 'arg2', optional = false } }
   local ok, err = validate( template, nil )

   assert_false( ok )
   assert_match( 'arg#2%(arg2%): missing', err )

end



function test_required__not_nil__specified_as_nil ()

   local template = { {
			 name = 'arg2',
			 optional = false,
			 not_nil = true,
		      }
		   }
   local ok, err = validate( template, nil )

   assert_false( ok )
   assert_match( 'arg#1.*not be nil', err )

end


function test_too_many ()

   local template = { { }, { } }
   local ok, err = validate( template, nil, nil, nil )

   assert_false( ok )
   assert_match( 'too many.*argument', err )

end

function test_non_integer_entries ()

   local template = { { }, { }, frank = 3 }
   local ok, err = validate( template, nil, nil )

   assert_false( ok )
   assert_match( 'extra elements', err )

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
   local ok, opts = validate_opts( { baseOptions = true,
				     named = true }, template, 32, 'foo' )

   assert_true( ok )
   assert_equal( 32, opts.arg2 )
   assert_equal( 'foo', opts[2] )


end

function test_extra_pos_args ()

   local template = { {}, {} }

   local ok, a, b, c = validate_opts( { baseOptions = true,
					allow_extra = true }, template,
				  1, 2, 3)

   assert_true( ok )
   assert_equal( 1, a )
   assert_equal( 2, b )
   assert_equal( nil, c )

   local ok, a, b, c = validate_opts( { baseOptions = true,
					allow_extra = true,
					pass_through = true,
				     }, template,
				  1, 2, 3)

   assert_true( ok )
   assert_equal( 1, a )
   assert_equal( 2, b )
   assert_equal( 3, c )

end
