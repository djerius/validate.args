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

local type_check = {

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

local builtin_types = { 'nil', 'number', 'string', 'boolean', 'table',
			'function', 'thread', 'userdata' }

for _, v in pairs(builtin_types) do
   type_check[v] = function (arg)
		      return type(arg) == v, arg
		   end
end

function add_type( utype, func )

   if ( type(utype) ~= 'string' ) then
      error( "type must be a string" )
   end

   type_check[utype] = func

end


function check_type( etype, arg )

   local chk = type_check[etype]
   if chk == nil then
      return false, 'validation template error: unknown type: ' .. etype
   end

   return chk(arg)

end


local validate_spec = {
   optional = { optional = true,
		type = 'boolean'
	     },
   validate = { optional = true,
		type = { 'function', 'table' },
	     },
   default  = { optional = true },
   type     = { optional = true,
		validate = function( val )
			      if 'table' == type(val) then
				 for _, v in pairs( val ) do
				    if not type_check[v] then
				       return false, 'invalid type: ' .. tostring(v)
				    end
				 end
			      elseif not type_check[val] then
				 return false, 'invalid type: ' .. tostring(val)
			      end

			      return true, val
			   end
	     },
   enum    = { optional = true,
	       type = 'table',
	    },
   not_nil = { optional = true,
	       type = 'boolean',
	    },
}


-- -----------------------------------------------------------------------------
-- Internal routine to validate a table against a table specification
--
-- First iterate through the specification validating against the table
-- entries using check_args. note that if a table entry is itself
-- a table, check_args will call check_table recursively.
--
-- Then check the table to ensure that there are no unwanted keys

function check_table( tspec, arg, opts )

   -- (possibly) transformed arguments
   local narg = {}

   -- this is used to cache the args we've dealt with so we can
   -- check for unexpected arguments
   local handled = {}

   -- iterate through template
   for k, spec in pairs( tspec ) do

      handled[k] = true;

      local ok, v = check_arg( spec, arg[k], opts )

      if ( ok ) then
	 narg[k] = v
      else
	 return false, string.format( "error: argument %s: %s", k, v );
      end

   end

   -- now check for keys in args that we haven't
   -- handled
   local bad_args = {}
   local has_bad = false

   for k in pairs( arg ) do

      if not handled[k] then
	 table.insert( bad_args, k )
	 has_bad = true
      end

   end

   if has_bad then
      return false, "unexpected named argument(s): "
	              .. table.concat( bad_args, ', ' )
   end

   return true, narg
end

-- -----------------------------------------------------------------------------

-- Internal routine to validate an arbirtrary argument against a
-- validation specification.  if opts.check_spec is true, the validation
-- specification is first validated.

function check_arg( spec, arg, opts )

   -- validate the spec
   if  opts.check_spec  and not opts.in_check_spec then
      opts.in_check_spec = true
      local ok, err = check_table( validate_spec, spec, opts );
      opts.in_check_spec = false
      if not ok then
	 return false, 'template error: ' .. err
      end
   end

   -- no argument or a nil argument is provided. make sure that's ok
   if arg == nil then

      if spec.optional or spec.default ~= nil then

	 return true, spec.default

      elseif spec.not_nil then

	 return false, 'value must not be nil'

      end

   end

   -- the specification specifies a type for the argument; check it
   if spec.type ~= nil then

      -- if spec.type is a table, it's a list of enumerated, acceptable types
      if  'table' == type( spec.type ) then

	 for _, v in pairs( spec.type ) do

	    ok, narg = check_type(v, arg)
	    if ok then
	       arg = narg
	       break
	    end

	 end

      else

	 -- just a single type
	 ok, arg = check_type( spec.type, arg )

      end

      if not ok then
	 return false, "incorrect type"
      end

   end


   -- was there special validation required?
   if spec.validate ~= nil then

      local ok = false

      if type(spec.validate) == 'table' then

	 -- if spec.validate is a table, the argument to be checked must
	 -- also be a table

	 if type(arg) ~= 'table' then
	    return false, 'validate constraint is a table but argument is not'
	 end

	 -- descend into the table and see what happens. note that
	 -- arg may be transformed
	 ok, arg = check_table( spec.validate, arg, opts )

	 if not ok then
	    return false, arg
	 end

      elseif type(spec.validate) == 'function' then

	 -- a functional validation.  not that arg may be
	 -- transformed

	 ok, arg = spec.validate( arg )

	 if not ok then
	    return false, arg
	 end

      else
	 return false, "template validate argument is not a function"
      end

   end

   -- must the value be from a set list?
   if spec.enum ~= nil then

      local ok

      for _, v in pairs( spec.enum ) do

	 if v == arg then
	    ok = true
	    break
	 end
      end

      if not ok then
	 return false, 'not one of the enumerated values'
      end


   end

   return true, arg

end


-- -----------------------------------------------------------------------------

CHECK_SPEC = false

-- validate arguments using the default options

function validate ( ... )

  local opts = { check_spec = CHECK_SPEC }

  return validate_opts( opts, ... )

end


-- validate arguments using specific options
function validate_opts( opts, tpl, ... )

  -- do our own simple validation
  if type(tpl) == 'nil' or type(tpl) ~= 'table' then
     return false, "validate_opts: argument #2 (tpl): expected table, got " .. type(tpl)
  end

  -- number of arguments
  local npos = select('#', ... )

  -- output (possibly transformed) arguments
  local oargs = { ... }

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

     handled_pos[i] = true;

     -- distinguish between a nil value and a non-existent positional arg
     if i > npos and not ( spec.optional or spec.default ) then
	local error = string.format( 'missing argument #%d%s', i,
				     spec.name ~= nil and ' (' .. spec.name .. ')' or ''
				  )
	return false, error
     end

     local ok, v = check_arg( spec, oargs[i], opts )

     -- can't use table.insert here. if v is nil
     -- table.insert(args, v) is a NOOP, the number of slots in args
     -- isn't increased
     if ok then
	nargs = nargs + 1
	args[nargs] = v
     else
	local error = string.format( 'argument #%d%s: %s', i,
				     spec.name ~= nil and ' (' .. spec.name .. ')' or '',
				     tostring(v)
				  )
	return false, error
     end

     idx = i + 1
  end


  -- We've reached the end of the positional arguments.  If there
  -- were none ( idx == 1 ) then there are only named arguments
  -- e.g. func{ args} and {tpl} is the specification table for them.

  if idx == 1 then

     if npos > 1 then
	return false, "too many positional arguments"
     end

     local arg = oargs[1]

     if type(arg) == 'nil' or type(arg) ~= 'table' then
	return false, "validate: argument #2: expected table, got " .. type(arg)
     end

     return check_arg( { type = 'table',
			 validate = tpl }, arg, opts )

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
	return false, "extra elements in template: " .. table.concat( badkeys, ', ' )
     end

     if npos >= idx then
	return false, "too many positional arguments"
     end

  end

  return true, unpack(args, 1, nargs )

end

-------------------------------------------------------------------------------
