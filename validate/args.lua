-- --8<--8<--8<--8<--
--
-- Copyright (C) 2010 Smithsonian Astrophysical Observatory
--
-- This file is part of validate.args
--
-- Validate-Args is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or (at
-- your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- -->8-->8-->8-->8--

-----
--- validate.args: Validate function arguments

module( ..., package.seeall )

require 'table'
require 'string'
require 'math'

-- -----------------------------------------------------------------------------
-- Support for validation of input validation templates using validate.args
-- We eat our own dog food here. Sometimes.

type_check = {}

function add_type( utype, func )

   if ( type(utype) ~= 'string' ) then
      error( "type must be a string" )
   end

   type_check[utype] = func

end


builtin_types = { 'nil', 'number', 'string', 'boolean', 'table',
		  'function', 'thread', 'userdata' }

for _, v in pairs(builtin_types) do
   add_type(
	    v,
	    function (arg) return type(arg) == v, arg end
	 )
end


other_types = {

   posnum = function( arg )
	       return type(arg) == 'number' and arg > 0, arg
	    end,

   zposnum = function( arg )
	       return type(arg) == 'number' and arg >= 0, arg
	     end,

   posint = function( arg )
	       if type(arg) ~= 'number' then
		  return false
	       end

	       local _, x = math.modf( arg )
	       return x == 0 and arg > 0, arg

	    end,

   zposint = function( arg )
	       if type(arg) ~= 'number' then
		  return false
	       end
		local _, x = math.modf( arg )

	       return x == 0 and arg >= 0, arg

	     end,
}

for k, v in pairs(other_types) do
   add_type( k, v )
end


valid_special = { ['%oneplus_of'] = true,
		  ['%one_of'] = true }

function check_special( special, arg )

   if valid_special[special] then

      local ok = true

      -- must be a list of lists
      ok = type(arg) == 'table'

      for _, v in pairs( arg ) do

	 ok = ok and type(v) == 'table'
      end

      return ok, ": must be list of lists"

   else
      return false, ": unknown validation special"

   end

end


local validate_spec = {
   optional = { optional = true,
		type = 'boolean'
	     },
   vfunc = { optional = true,
	     type = 'function'
	  },
   vtable = { optional = true,
	      type = { 'table', 'function' },
	   },
   default  = { optional = true },
   type     = { optional = true,
		vfunc = function( val )
			   local val = type(val) == 'table' and val or { val }
			   for _, v in pairs( val ) do
			      if not type_check[v] then
				 return false, 'unkown type: ' .. tostring(v)
			      end
			   end

			   return true, val
			end
	     },
   name    = { optional = true,
	       type = 'string' },
   enum    = { optional = true,
	    },
   not_nil = { optional = true,
	       type = 'boolean',
	    },
   requires = { optional = true,
		type = { 'table', 'string' } },
   excludes = { optional = true,
		type = { 'table', 'string' } },

   one_of = { optional = true,
	      type = 'table' },

}


-- the specification may be a function, in which case it
-- will return the real validation specification
function resolve_spec( spec, arg )


   local ok = true

   if type(spec) == 'function' then

      ok, spec = spec( arg )

      if ok and type(spec) ~= 'table' then
	 ok = false
	 spec = '(validation spec function): returned type ' .. type(spec) .. '; expected a table'
      end

   end

   return ok, spec

end


-- -----------------------------------------------------------------------------
-- Internal routine to validate a table against a table specification
--
-- First iterate through the specification validating against the table
-- entries using check_args. note that if a table entry is itself
-- a table, check_args will call check_table recursively.
--
-- Then check the table to ensure that there are no unwanted keys

function check_table( tspec, arg, opts )

   -- cached copy of tspec; elements of tspec may be
   -- transformed by resolve_spec() so need to keep them
   -- around
   local ctspec = {}

   -- (possibly) transformed arguments
   local narg = {}

   -- this is used to track the args we've dealt with so we can
   -- check for unexpected arguments
   local handled = {}

   -- iterate through specifications
   for k, spec in pairs( tspec ) do

      local ok, v

      ctspec[k] = spec

      handled[k] = true;

      -- if we're checking the validation spec, must treat an actual "vtable"
      -- attribute very carefully, as it creates nested validation specifications
      if opts.in_check_spec and k == 'vtable' then

	 ok = true
	 v = arg[k]

	 if type(arg[k]) == 'table' or type(arg[k]) == 'function' then

	    -- spec may be a function which returns an actual table
	    -- but we can't check it as it requires access to the actual
	    -- data being validated. which isn't available, but should be
	    if type(arg[k]) == 'table' then

	       v = {}

	       -- we descend into it carefully... as we don't want to parse the
	       -- keys in the table as they are argument names
	       for k, spec in pairs( arg[k] ) do

		  local ok, v_s

		  if type(k) ~= 'string' and type(k) ~= 'number' then
		     ok = false
		     v_s = ': invalid argument name'

		  -- make sure we don't mistake a positional index for
		  -- a string
		  elseif type(k) ~= 'number' and k:sub(1,1) == '%' then

		     ok, v_s = check_special( k, spec )

		  elseif type(spec) == 'function' then
		     -- spec may be a function which returns a real
		     -- validation, but we can't validate that here;
		     -- wait until it's actually put in play

		     ok = true
		     v_s = spec

		  else

		     ok, v_s = check_table( validate_spec, spec, opts )
		  end

		  if ok then
		     v[k] = v_s
		  else
		     return false, string.format( ".vtable.%s%s", tostring(k), v_s );
		  end

	       end

	    end

	 elseif arg[k] then
	    return false, "vtable : wrong type (got " .. type(arg[k]) .. " )"

	 end

      elseif type(k) == 'number' or k:sub(1,1) ~= '%' then
	 -- spec keys which start with % are special -- they're not argument names

	 ok, v = resolve_spec( spec, arg[k] )

	 if ok then
	    ctspec[k] = v
	    ok, v = check_arg( ctspec[k], arg[k], opts )
	 end

      else

	 ok = true

      end

      if ok then
	 narg[k] = v
      else
	 return false, string.format( ".%s%s", tostring(k), tostring(v) );
      end

   end


   -- now check for keys in args that we haven't
   -- handled
   local bad_args = {}
   local has_bad = false

   for k in pairs( arg ) do

      if not handled[k] then

	 if opts.allow_extra then
	    if opts.pass_through then
	       narg[k] = arg[k]
	    end
	 else
	    table.insert( bad_args, k )
	    has_bad = true
	 end

      end

   end

   if has_bad then

      return false, '.' .. table.concat( bad_args, ', ' ) .. ": unexpected named argument(s)"
   end

   -- now check for dependencies and exclusions
   for k, spec in pairs( ctspec ) do

      if narg[k] ~= nil and ( type(k) == 'number' or k.sub( 1, 1 ) ~= '%' ) then

	 if spec.excludes then
	    local excludes = type(spec.excludes) == 'table' and spec.excludes or { spec.excludes }
	    for _,v in pairs(excludes) do
	       if narg[v] ~= nil then
		  return false,
		  string.format(": can't have both arguments '%s' and '%s'",
				k, v )
	       end
	    end
	 end

	 if spec.requires then
	    local requires = type(spec.requires) == 'table' and spec.requires or { spec.requires }
	    for _,v in pairs(requires) do
	       if narg[v] == nil then
		  return false,
		  string.format(": can't have argument '%s' without '%s'",
				k, v )
	       end
	    end
	 end

	 if spec.one_of then

	    local count = 0

	    for _,v in pairs(spec.one_of) do

	       if narg[v] ~= nil then
		  count = count + 1
	       end
	    end

	    if count ~= 1 then
	       return false, ": must specify exactly one of " .. table.concat( spec.one_of, ', ' )
	    end

	 end

      end

   end

   -- check for 'any of' requirements
   if tspec['%oneplus_of'] then

      -- iterate over each group
      for _,group in pairs( tspec['%oneplus_of'] ) do

	 local ok = false

	 for _,v in pairs( group ) do

	    if narg[v] ~= nil then
	       ok = true
	       break
	    end
	 end

	 if not ok then
	    return false, ": must specify at least one of " .. table.concat( group, ', ' )
	 end

      end

   end

   -- check for 'one of' requirements
   if tspec['%one_of'] then

      -- iterate over each group
      for _,group in pairs( tspec['%one_of'] ) do

	 local count = 0

	 for _,v in pairs( group ) do

	    if narg[v] ~= nil then
	       count = count + 1
	    end
	 end

	 if count ~= 1 then
	    return false, ": must specify exactly one of " .. table.concat( group, ', ' )
	 end

      end

   end

   return true, narg
end


-- -----------------------------------------------------------------------------

-- Internal routine to validate an arbirtrary argument against a
-- validation specification.  if opts.check_spec is true, the validation
-- specification is first validated.

function check_arg( spec, arg, opts )

   local ok

   -- keep track if this is a positional argument; remove
   -- from options to avoid polluting nested tables
   local positional = opts.positional
   opts.positional = nil


   -- validate the spec
   if  opts.check_spec  and not opts.in_check_spec then
      opts.in_check_spec = true
      local ok, err = check_table( validate_spec, spec, opts );
      opts.in_check_spec = false
      if not ok then
	 if opts.error_on_bad_spec then
	    error( 'validation spec error: ' .. err )
	 else
	    return false, '(validation spec)' .. err
	 end
      end
   end

   -- no argument or a nil argument is provided. make sure that's ok
   if arg == nil then

      -- positional arguments have already been checked for existence,
      -- so if it's a nil value it has been deliberately set
      if positional and spec.not_nil then

	 return false, ': must not be nil'

      end

      if spec.optional or spec.default ~= nil or positional then

	 if type(spec.default) == 'function' then

	    local ok, v = spec.default()

	    -- need to put a spacer in front of the possible error
	    -- message.  v may be legitimately be nil so can't use
	    -- short cut operators
	    if ok then
	       return ok, v
	    else
	       return ok, ': ' .. v
	    end

	 else

	    return true, spec.default

	 end

      end

      return false, ': required but not specified'

   end

   -- the specification specifies a type for the argument; check it
   if spec.type ~= nil then

      local ok, narg

      -- if spec.type may be a table or a scalar
      local utype = type(spec.type ) == 'table' and spec.type or { spec.type }

      for _, v in pairs( utype ) do

	 local chk = type_check[v]
	 if chk == nil then
	    return false, '(template).type: unknown type: ' .. tostring(v)
	 end

	 ok, narg = chk(arg)

	 if ok then
	    arg = narg
	    break
	 end

      end

      if not ok then
	 return false, string.format( ": value (%s) is not of required type", tostring( arg ) )
      end

   end


   if spec.vfunc then

      local ok

      -- a functional validation.  note that arg may be
      -- transformed

      ok, arg = spec.vfunc( arg )

      if not ok then
	 return false, ': ' .. arg
      end

   end

   -- was there special validation required?
   if spec.vtable ~= nil then

      local ok

      -- the argument to be checked must also be a table

      if type(arg) ~= 'table' then
	 return false, ': incorrect type; must be a table'
      end

      -- spec.vtable may be a function which returns an actual table
      local vtable = spec.vtable

      if type(vtable) == 'function' then

	 ok, vtable = vtable(arg)
	 if not ok then
	    return ok, vtable
	 end

	 if type(vtable) ~= 'table' then
	    return false, '(validation spec).vtable: expected table from vtable function, got ' .. type(vtable)
	 end

      end

      -- descend into the table and see what happens. note that
      -- arg may be transformed
      ok, arg = check_table( vtable, arg, opts )

      if not ok then
	 return false, arg
      end

   end

   -- must the value be from a set list?
   if spec.enum ~= nil then

      local ok
      local enum = type(spec.enum) == 'table'
                            and spec.enum or { spec.enum }

      for _, v in pairs( enum ) do

	 if v == arg then
	    ok = true
	    break
	 end
      end

      if not ok then
	 return false, string.format(': value (%s) is not in approved list',
				     tostring( arg ) )
      end


   end

   return true, arg

end


-- -----------------------------------------------------------------------------
-- module scoped validation options.


-- The underlying option setter.  This uses a base options table
-- unless the options table to be changed is the same as the base
-- options table
function _setopts( opts, base, new )

   opts = opts or {}

   if  opts ~= base then
      for k, v in pairs( base ) do
	 opts[k] = v
      end
   end

   new = new or {}

   for k, v in pairs( new ) do

      if DefaultOptions[k] == nil then
	 error( "illegal option: " .. k )
      end

      opts[k] = v

   end

   return opts

end

-- Public interface to set options seen by validate()
function opts( ... )

   _setopts( Options, Options, ... )

end


-- These are the immutable default.  This also serves as check against
-- illegal options
DefaultOptions = {
   check_spec        = false,
   error_on_bad_spec = false,
   error_on_invalid  = false,
   named             = false,
   allow_extra       = false,
   pass_through      = false,
   debug             = false,

   -- used only by validate functions which pass options, to indicate
   -- their options are based on Options, not DefaultOptions.  This
   -- is a placeholder so it's not flagged as an illegal option
   baseOptions       = false,
}

-- These are the options seen by validate().  They are mutable by opts().
Options = _setopts( nil, DefaultOptions )


function g_rfunc( opts )

   if opts.error_on_invalid then
      return function( ... )
		 if ( select( 1, ... ) ) then
		    return ...
		 else
		    error( select( 2, ... ), 4 )
		 end
	      end
   elseif opts.debug then
      return function( ... )
		if ( select( 1, ... ) ) then
		   return ...
		else
		   print( "ERROR: " .. select( 2, ... ) )
		   return ...
		end
	     end
   else
      return function( ... )  return ... end
   end

end

-- validate arguments using the default options

function validate ( ... )

  return validate_opts( Options, ... )

end

function validate_tbl( opts, tpl, arg )

   opts = _setopts( nil, (opts and opts.baseOptions and Options) or DefaultOptions, opts )

   local rfunc = g_rfunc( opts )

   return rfunc( check_arg( { type = 'table',
				vtable = tpl }, arg, opts ) )

end

-- validate arguments using specific options
function validate_opts( opts, tpl, ... )

   local ok

   opts = _setopts( nil, (opts and opts.baseOptions and Options) or DefaultOptions, opts )

   local rfunc = g_rfunc( opts )

  -- do our own simple validation
  if type(tpl) == 'nil' or type(tpl) ~= 'table' then
     return rfunc( false, "argument #2 (tpl): expected table, got " .. type(tpl) )
  end

  -- number of arguments
  local npos = select('#', ... )

  -- original arguments
  local oargs = { ... }

  -- output (possibly transformed) arguments
  local args = {}
  local nargs = 0

  -- All args are essentially positional arguments.  This routine
  -- expects the {tpl} argument to be an array of specification
  -- tables, one per argument.

  -- If there are only named arguments, the only argument is a table.
  -- In that case the input template is simplified; it is a
  -- specification table rather than an array of tables.

  -- iterate over positional arguments
  local handled_pos = {}
  local idx = 1
  for i, spec in ipairs( tpl ) do

     -- the specification may be a function, in which case it
     -- will return the real validation specification.  have to handle
     -- it early for positional arguments as we need to know if a name
     -- was assigned to the argument.

     local ok, spec = resolve_spec( spec, oargs[i] )

     if not ok then

	local errstr = string.format( 'arg#%d(validation spec): %s',
				     i, spec )
	return rfunc( false, errstr )

     elseif type(spec) ~= 'table' then

	return rfunc( false,
		     "arg#2(validation spec): expected table or function, got "
			.. type(arg) )
     end


     nargs = nargs + 1
     local name = spec.name or nargs

     local argname = ''
     if spec.name then
	argname = string.format( 'arg#%d(%s)', i, spec.name )
     else
	argname = string.format( 'arg#%d', i )
     end


     handled_pos[i] = true;

     -- distinguish between a nil value and a non-existent positional arg
     if i > npos and not ( spec.optional or spec.default ) then
	local errstr = string.format( '%s: missing', argname )
	return rfunc( false, errstr )
     end

     opts.positional = true
     local ok, v = check_arg( spec, oargs[i], opts )
     -- can't use table.insert here. if v is nil
     -- table.insert(args, v) is a NOOP, the number of slots in args
     -- isn't increased
     if ok then
	args[name] = v
     else
	local errstr = string.format( '%s%s', argname, v )
	return rfunc( false, errstr )
     end

     idx = i + 1
  end


  -- We've reached the end of the positional arguments.  If there
  -- were none ( idx == 1 ) then there are only named arguments
  -- e.g. func{ args} and {tpl} is the specification table for them.

  if idx == 1 then

     if npos > 1 then
	return rfunc( false, "too many positional arguments" )
     end

     local arg = oargs[1]

     if type(arg) == 'nil' or (type(arg) ~= 'table' and type(arg) ~= 'function')  then
	return rfunc( false, "arg#2: expected table or function, got "
		     .. type(arg) )
     end

     return rfunc( check_arg( { type = 'table',
				vtable = tpl }, arg, opts ) )

  else

     -- There's an error in the template if idx > 1 and there are
     -- elements in the template that we haven't handled

     local badkeys = {}
     local has_bad = false
     for k in pairs (tpl) do
	if not handled_pos[k] then
	   table.insert( badkeys, k )
	   has_bad = true
	end

     end

     if has_bad then
	return rfunc( false, "extra elements in validation spec: " .. table.concat( badkeys, ', ' ) )
     end


     -- extra arguments
     if npos >= idx then

	if not opts.allow_extra then

	   -- don't want them
	   return rfunc( false, "too many positional arguments" )


	elseif opts.pass_through then

	   -- want them
	   for i = idx, npos, 1 do
	      args[i] = oargs[i]
	   end

	   nargs = npos

	end


     end

  end

  if opts.named then
     return rfunc( true, args )
  else
     return rfunc( true, unpack(args, 1, nargs ) )
  end
end

-------------------------------------------------------------------------------
