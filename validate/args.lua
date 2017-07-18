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

io = require 'io'
table = require 'table'
string = require 'string'
math = require 'math'
unpack = unpack or table.unpack

local _M = {}

-- iterate over non meta keys
local function next_notmeta( table, index )

   local k, v = next( table, index )

   while k do
      if not k:find( '^__' ) then
	 return k, v
      end
      k, v = next( table, k )
   end

   return k, v

end

local function nmpairs( table )
   return next_notmeta, table, nil
end


-- generic Base object

local Base = {}

function Base:_dump ( message )

   if message then
      io.stderr:write( message )
   end
   for k,v in nmpairs( self ) do
      io.stderr:write( k .. " = " .. tostring( v ) .. "\n" )
   end
end

-- create child object
---   1. make *shallow* copy of non-function data
---   2. call datum:new() if datum is a table and has a new() method
function Base:new( attr )

   local obj = {}

   -- copy data from parent.  if a datum is an object, call its constructor
   -- so far, all objects stored in children of Base are themselves children
   -- of Base, so this is safe.
   -- does a shallow copy! tables are copied by reference
   for k, v in nmpairs( self ) do
      if ( type(v) == 'table' and type(v.new) == 'function' ) then
	 obj[k] = v:new()
      elseif type(v) ~= 'function' then
	 obj[k] = v
      end
   end

   for k, v in nmpairs( attr or {} ) do
      obj[k] = v
   end

   setmetatable( obj, self )

   self.__index = self

   -- inherit __newindex by crawling up the index chain. kinda magical
   self.__newindex = self.__newindex

   return obj

end


--------------------------------------------------------------------
-- configuration options class. doesn't allow creation of new option fields
-- FIXME: option values are not validated

local Options = Base:new{
   check_spec        = false,
   error_on_bad_spec = false,
   error_on_invalid  = false,
   named             = false,
   allow_extra       = false,
   pass_through      = false,
   debug             = false,
   udata             = false,
   ordered           = false,
   before            = false,
   after             = false,
}

-- prevent creation of new fields
Options.__newindex = function( t, k, v )
			if rawget( Options, k ) == nil or k == 'new' then
			   error( 'unknown option: ' .. k, 2 )
			end
			rawset( t, k, v )
			return v
		     end

function Options:set( opts )

   for k, v in pairs( opts or {} ) do
      self[k] = v
   end

end

function Options:get( k )

   if rawget( Options, k ) ~= nil then
      return self[k]
   else
      error( 'unknown option: ' .. k, 2 )
   end

end

function Options:dump( )

   local io = require('io')

   for k in pairs( Options ) do
      if k ~= 'new' and not k:find( '^_') then
	 io.stderr:write( "option " .. k .. " = " .. tostring( self[k] ) .. "\n" )
      end
   end

end

--------------------------------------------------------------------
-- Type validator class. Just manages a list of validators.

local function posnum ( arg )
   if type(arg) == 'number' and arg > 0 then
      return true, arg
   else
      return false, "not a number"
   end
end

local function zposnum ( arg )
   if type(arg) == 'number' and arg >= 0 then
      return true, arg
   else
      return false, "not a non-negative number"
   end
end

local function posint( arg )

   if type(arg) ~= 'number' then
      return false, "not a positive integer"
   end

   local _, x = math.modf( arg )

   if x == 0 and arg > 0 then
      return true, arg
   else
      return false, "not a positive integer"
   end

end

local function zposint( arg )

   if type(arg) ~= 'number' then
      return false, "not a non-negative integer"
   end

   local _, x = math.modf( arg )

   if x == 0 and arg >= 0 then
      return true, arg
   else
      return false, "not a non-negative integer"
   end

end

local TypeCheckValidators = Base:new{

   -- various validation functions
   posnum  = posnum,
   zposnum = zposnum,
   posint  = posint,
   zposint = zposint
}

-- validators for built-in types

local builtin_types = { 'nil', 'number', 'string', 'boolean', 'table',
			'function', 'thread', 'userdata' }

for _, v in pairs(builtin_types) do
   TypeCheckValidators[v] = function (arg)
			       if type(arg) == v then
				  return true, arg
			       else
				  return false
			       end
			    end
end

--------------------------------------------------------------------
-- Type Validation class. Encapsulates the validators and provides
-- an interface to them.

local TypeCheck = Base:new{

   _validator = TypeCheckValidators:new(),

}

-- Add a validator
function TypeCheck:add( vtype, validator )

   if ( type(vtype) ~= 'string' ) then
      error( "validator type must be a string", 3 )
   end

   if ( type(validator) ~= 'function' ) then
      error( "validator must be a function", 3 )
   end


   self._validator[vtype] = validator

end

-- return a validator
function TypeCheck:validator( vtype )

   return self._validator[vtype]

end

--------------------------------------------------------------------
-- Store state in a weak key table. State for individual spec tables
-- is keyed off of the table, so weaken the references so they can get
-- gc'd

local SpecState = {

   __mode = 'k',

}

function SpecState:new(  )

   local obj = {}

   setmetatable( obj, self )
   self.__index = self
   return obj
end

--------------------------------------------------------------------
-- prototype for the validation object.  this is NOT directly exposed

local Validate = Base:new{
   state = SpecState:new(),
   opts  = Options:new(),
   types = TypeCheck:new(),
}

function Validate:setopts( ... )

   self.opts:set( ... )

   return self.opts

end

function Validate:getopt( ... )

   return self.opts:get( ... )

end

function Validate:add_type( ... )

   self.types:add( ... )

end

--------------------------------------------------------------------
-- prototype for the Name object; not exposed
-- this is a list of names and an index indicating the
-- largest valid element

local Name = {
   level = 0,
   name = {},
}

function Name:new( name )

   local obj = {}

   -- copy data from parent, including any metatable entries
   -- this allows any children of the new object to use the
   -- parent as a metatable
   for k, v in pairs( self ) do
      obj[k] = v
   end

   -- set name and level from arguments if specified
   -- for now assume that all elements in name are valid
   if name then
      obj.name = name
      obj.level = #name
   end

   setmetatable( obj, self )
   self.__index = self


   return obj

end

function Name:dup( )

   self = self:new()

   local name = {}

   for i = 1, self.level do
      name[i] = self.name[i]
   end

   self.name  = name

   return self

end

function Name:add( name )

   self = self:new()


   self.level = self.level + 1
   self.name[self.level] = tostring(name)

   return self

end

function Name:tostring()

   local str = table.concat( self.name, '.', 1, self.level )

   return ( str:gsub( '%.(%d+)', '[%1]' ) )

end

Name.__tostring = Name.tostring

function Name:msg( ... )

   local msgt = {}

   for i,v in ipairs{ ... } do
      msgt[i] = tostring(v)
   end

   return self:tostring() .. ': ' .. table.concat( msgt )

end

function Name:fmt( ... )

   return self:tostring( ) .. ': ' .. string.format( select( 1, ... ) )

end


---------------------------------------------------------
-- specials

-- must be a function
local valid_special_func = function (arg)
			      return type(arg) == 'function', 'must be a function'
			   end

-- must be a list of lists
local valid_special_lol = function (arg)
			     local ok = type(arg) == 'table'
			     for _, v in pairs( arg ) do
				ok = ok and type(v) == 'table'
			     end

			     return ok, "must be list of lists"
			  end


local valid_special = { ['%oneplus_of'] = valid_special_lol,
			['%one_of']     = valid_special_lol,
			['%default']    = valid_special_func,
			['%pos']        = valid_special_func,
			['%named']      = valid_special_func
		     }

local function check_special( special, arg )

   if valid_special[special] then

      return valid_special[special](arg )

   else
      return false, "unknown validation special"

   end

end


-- -----------------------------------------------------------------------------
-- Support for validation of input validation templates using validate.args
-- We eat our own dog food here. Sometimes.

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

   order = { optional = true,
	     type = 'number'
	  },

   ordered = { type = 'boolean',
	       default = false
	    },

   default  = { optional = true },

   default_to_nil = { optional = true },

   precall  = { type = 'function', optional = true, excludes = 'before' },
   postcall = { type = 'function', optional = true, excludes = 'after' },

   before  = { type = 'function', optional = true },
   after   = { type = 'function', optional = true },

   name    = { optional = true,
	       type = 'string' },

   named   = { optional = true,
	       type = 'boolean' },

   enum    = { optional = true,
	    },
   not_nil = { optional = true,
	       type = 'boolean',
	    },

   allow_nil = { optional = true,
	      type = 'boolean',
	   },

   requires = { optional = true,
		type = { 'table', 'string' } },
   excludes = { optional = true,
		type = { 'table', 'string' } },

   one_of = { optional = true,
	      type = 'table' },

}

-- recursive reference to validate_spec needed here, hence not
-- inlined above
validate_spec.type =
   { optional = true,

     multiple = { allow_scalar = true },

     type = {
	type= {
	   vfunc = function( val, args )
		      if not args.va.types:validator(val) then
			 return false, 'unknown type: ' .. tostring(val)
		      end
		      return true, val
		   end,
	},
	validate_spec = { vtable = validate_spec }
     },
  }


-- recursive reference to validate_spec needed here, hence not
-- inlined above
validate_spec.multiple =
   { optional = true,
     type = { 'boolean',
	      ['multiple table'] = {
		 vtable = {
		    min = { type = 'zposint', optional = true,
			    excludes = 'n'
			 },
		    max = { type = 'posint',  optional = true,
			    excludes = 'n'
			 },
		    n   = { type = 'posint',  optional = true,
			    excludes = { 'min', 'max' }
			 },
		    keys   = { vtable = validate_spec,
			       optional = true
			    },
		    allow_scalar = { type = 'boolean', default = false },
		 }
	      }
	   },
  }



-- the specification may be a function, in which case it
-- will return the real validation specification
local function resolve_spec( spec, arg )


   local ok = true

   if type(spec) == 'function' then

      ok, spec = spec( arg )

      if ok and type(spec) ~= 'table' then
	 return false,    '(validation spec function): returned type '
	               .. type(spec)
		       .. '; expected a table'
      end

   end

   return ok, spec

end

local function order_spec( spec, ordered )

   local order = {}

   if ordered then

      for k, v in pairs( spec ) do
	 table.insert( order, { k,
				(type(v) == 'table'
			          and v.order ~=nil
			          and v.order) or nil
		       } )
      end



      -- order table if requested
      table.sort( order, function(t1, t2)
			    if t1[2] == nil then return false end
			    if t2[2] == nil then return true  end

			    return t1[2] < t2[2]

			 end
	       )

   else

      for k in pairs( spec ) do
	 table.insert( order, { k } )
      end

   end

   return order

end


-- -----------------------------------------------------------------------------
-- Validate a table against a table specification
--
-- First iterate through the specification validating against the table
-- entries using check_args. note that if a table entry is itself
-- a table, check_args will call check_table recursively.
--
-- Then check the table to ensure that there are no unwanted keys

function Validate:check_table( name, tspec, arg )

   if not self.state[name] then self.state[name] = {} end

   local opts = self.opts

   -- cached copy of tspec; elements of tspec may be
   -- transformed by resolve_spec() so need to keep them
   -- around
   local ctspec = {}

   -- (possibly) transformed arguments
   local narg = {}

   -- this is used to track the args we've dealt with so we can
   -- check for unexpected arguments
   local handled = {}

   if type( arg ) ~= 'table' then
      error( name:msg( "(validation spec): expected table, got ", type(arg) ) )
   end

   local order = order_spec( tspec, self.state[name].ordered )

   -- iterate through specifications
   for _,tk in ipairs( order ) do

      local k = tk[1]
      local spec = tspec[k]

      local ok, v

      ctspec[k] = spec

      handled[k] = true;

      -- if we're checking the validation spec, must treat an actual "vtable"
      -- attribute very carefully, as it creates nested validation specifications
      if self.state.in_check_spec and k == 'vtable' then

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

		  local name = name:add(k)

		  local ok, v_s

		  if type(k) ~= 'string' and type(k) ~= 'number' then
		     return false, name:msg( 'invalid argument name' )

		     -- make sure we don't mistake a positional index for
		     -- a string
		  elseif type(k) ~= 'number' and k:sub(1,1) == '%' then

		     ok, v_s = check_special( k, spec )
		     if not ok then
			return false, name:msg( v_s )
		     end

		  elseif type(spec) == 'function' then
		     -- spec may be a function which returns a real
		     -- validation, but we can't validate that here;
		     -- wait until it's actually put in play

		     v[k] = spec

		  else

		     ok, v_s = self:check_table( name , validate_spec, spec )
		     if not ok then
			return false, v_s
		     end

		     v[k] = v_s

		  end

	       end

	    end

	 elseif arg[k] then
	    return false, name:add(k):msg( "wrong type (got " .. type(arg[k]) .. " )" )
	 end

      elseif type(k) == 'number' or k:sub(1,1) ~= '%' then
	 -- spec keys which start with % are special -- they're not argument names

	 ok, v = resolve_spec( spec, arg[k] )

	 if ok then
	    ctspec[k] = v
	    ok, v = self:check_arg( name:add(k), ctspec[k], arg[k] )
	 end

      else

	 ok = true

      end

      if ok then

	 -- see if we're to rename positional arguments.  ctspec[k] may not be
	 -- a table if we're validating specs and k is a special which takes a function

	 if type( ctspec[k] ) == 'table'
	    and ( self.opts.named or ctspec[k].named )
	    and ctspec[k].named ~= false
	    and ctspec[k].name
	 then
	    narg[ctspec[k].name] = v
	 else
	    narg[k] = v
	 end
      else
	 -- v is an error message prefixed with the variable name
	 return false, v;
      end

   end

   -- now check for keys in args that we haven't handled
   local bad_args = {}
   local has_bad = false

   for k, v in pairs( arg ) do

      if not handled[k] then

	 -- default spec for unhandled positional, named, any elements?
	 local func =
	         ctspec['%pos']   and posint(k) and ctspec['%pos']
	     or  ctspec['%named'] and not posint(k) and ctspec['%named']
	     or  ctspec['%default']

	 if func then

	    local name = name:add(k)

	    local vfargs = { name = name, va = self }

	    local ok, spec = func(k, v, vfargs)

	    if ok then
	       ctspec[k] = spec
	       ok, v = self:check_arg( name, spec, v )

	       if ok then
		  if ( self.opts.named or spec.named )
		     and spec.named ~= false
		     and spec.name
		  then
		     narg[spec.name] = v
		  else
		     narg[k] = v
		  end
	       else
		  return false, v
	       end

	       handled[k] = true

	    elseif spec ~= nil then

	       return false, name:fmt( spec )

	    end

	 end

	 if not handled[k] then

	    if opts.allow_extra then
	       if opts.pass_through then
		  narg[k] = arg[k]
	       end
	    else
	       table.insert( bad_args, name:add(k):tostring() )
	       has_bad = true
	    end

	 end

      end

   end

   if has_bad then
      return false, name:msg( "unexpected elements: ", table.concat( bad_args, ', ' ) )
   end

   -- now check for dependencies and exclusions
   for k, spec in pairs( ctspec ) do

      local name = name:add( k )

      if narg[k] ~= nil and ( type(k) == 'number' or k:sub( 1, 1 ) ~= '%' ) then

	 if spec.excludes then
	    local excludes = type(spec.excludes) == 'table' and spec.excludes or { spec.excludes }
	    for _,v in pairs(excludes) do
	       if narg[v] ~= nil then
		  return false, name:fmt( "can't have both arguments '%s' and '%s'", k, v )
	       end
	    end
	 end

	 if spec.requires then
	    local requires = type(spec.requires) == 'table' and spec.requires or { spec.requires }
	    for _,v in pairs(requires) do
	       if narg[v] == nil then
		  return false, name:fmt("can't have argument '%s' without '%s'", k, v )
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
	       return false, name:msg( "must specify exactly one of ",  table.concat( spec.one_of, ', ' ) )
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
	    return false, name:msg( "must specify at least one of ", table.concat( group, ', ' ) )
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
	    return false, name:msg( "must specify exactly one of ", table.concat( group, ', ' ) )
	 end

      end

   end

   return true, narg
end

-- -----------------------------------------------------------------------------

-- determine the default value for an unspecified arg

function Validate:defaults( name, spec )

   local vfargs = { name = name, va = self, spec = spec }

   if spec.default ~= nil then

      if type(spec.default) == 'function' then

	 local ok, v = spec.default( vfargs )

	 if ok then
	    return true, v
	 else
	    return false, name:msg( tostring(v) )
	 end

      else

	 return true, spec.default

      end

   end

   -- it's an error if no default was specified and the argument is
   -- not optional.
   if not spec.optional then

      -- note that positional arguments with a nil value and
      -- spec.allow_nil == true are acceptable
      if self.state[name] and self.state[name].positional and spec.allow_nil then
	 return true, nil
      else
	 return false, name:msg( 'required but not specified' )
      end
   end

   -- if this is a vtable, try and get defaults from nested specs
   if not spec.default_is_nil and spec.vtable then

      local ok
      local vtable = spec.vtable

      if type(vtable) == 'function' then

	 ok, vtable = vtable( nil, vfargs )
	 if not ok then
	    return false, name:msg( tostring(vtable) )
	 end

	 if type(vtable) ~= 'table' then
	    return false, name:msg( '(validation spec).vtable: expected table from vtable function, got ',
				    type(vtable) )
	 end

      end

      -- descend into the table and see what happens.
      local default = {}

      for k, spec in pairs ( vtable ) do

	 local name = name:add( k )

	 -- only look at keys which match an argument name
	 if type(k) == 'number' or k:sub(1,1) ~= '%' then

	    local ok, spec = resolve_spec( spec )

	    local key = k
	    if ( self.opts.named or spec.named )
	       and spec.named ~= false
	       and spec.name
	    then
	       key = spec.name
	    end

	    if ok then
	       self.state.in_default_scan = true
	       ok, default[key] = self:check_arg( name, spec )
	       self.state.in_default_scan = nil

	       if not ok then
		  return false, default[key]
	       end

	    end

	 end

      end

      if nil ~= next(default) then
	 return true, default
      else
	 return true, nil
      end

   end

   return true, nil


end

-- -----------------------------------------------------------------------------
-- Validate an arbirtrary argument against a validation specification.

function Validate:process_arg_spec( name, spec, arg )

   local vfargs = { name = name, va = self, spec = spec }

   if self.state[name] == nil then self.state[name] = {} end

   local ok
   local opts = self.opts


   -- no argument or a nil argument is provided. make sure that's ok
   if arg == nil then

      -- positional arguments have already been checked for existence,

      -- backwards compatibility: pay attention to spec.not_nil flag
      -- old behavior was that a nil positional parameter was allowed
      -- by default.  this is bad policy.  the reverse is now the
      -- case, nil positional values are allowed only if allow_nil
      -- is set. but, still need to handle old specs

      if self.state[name].positional and spec.not_nil then

	 return false, name:msg( 'must not be nil' )

      end

      return self:defaults( name, spec )

   end

   if spec.multiple and not self.state[name].in_multiple then

      local ok
      local espec = type(spec.multiple) == 'table' and spec.multiple or {}

      if type( arg ) ~= 'table' then
	 if espec.allow_scalar then
	    arg = { arg }
	 else
	    return false, name:msg( 'must be a table' )
	 end
      end


      local nelem = 0

      for k,v in pairs( arg ) do

	 local name = name:add(k)

	 self.state[name] = { in_multiple = true }
	 ok, v = self:check_arg( name, spec, v )
	 self.state[name].in_multiple = false

	 if not ok then
	    return false, v
	 end

	 if espec.keys then
	    ok, k = self:check_arg( name, espec.keys, k )
	    if not ok then
	       return false, k .. ': bad key'
	    end
	 end

	 arg[k] = v
	 nelem = nelem + 1
      end

      if espec.min ~= nil and nelem < espec.min then
	 return false, name:fmt( "too few elements: expected %d, got %d", espec.min, nelem )
      end

      if espec.max ~= nil and nelem > espec.max then
	 return false, name:fmt( "too many elements: expected %d, got %d", espec.max, nelem )
      end

      if espec.n ~= nil and nelem ~= espec.n then
	 return false, name:fmt( "incorrect number of elements: expected %d, got %d", espec.n, nelem )
      end
      return true, arg

   end


   -- the specification specifies a type for the argument; check it
   if spec.type ~= nil then

      local errors = {}
      local ok, narg

      -- if spec.type may be a table or a scalar
      local utype = type(spec.type ) == 'table' and spec.type or { spec.type }

      for k, v in pairs( utype ) do

	 local typename

	 if posint(k) then

	    typename = v

	    local chk = self.types:validator(v)
	    if chk == nil then
	       return false, name:msg( '(validation spec).type: unknown type: ', tostring(v) )
	    end

	    ok, narg = chk(arg)

	 elseif type(v) == 'table' then

	    typename = k
	    ok, narg = self:check_arg( name, v, arg )

	 else

	    return false, name:msg( '(validation spec).type.' .. tostring(k) .. ': unknown type: ', tostring(v)) 

	 end

	 -- as we may be testing against more than one acceptable
	 -- type, we can't just return a single error store the error
	 -- messages returned (if any) and output them only if there
	 -- were no matches
	 if ok then
	    arg = narg
	    break
	 else
	    errors[#errors+1] = string.format( "%s (%s)", typename, narg ~= nil and narg or '' )
	 end

      end

      if not ok then
	 return false, name:fmt( "did not match types: %s", table.concat( errors, ', ' ) )
      end

   end


   if spec.vfunc then

      local ok

      -- a functional validation.  note that arg may be
      -- transformed

      ok, arg = spec.vfunc( arg, vfargs )

      if not ok then
	 return false, name:msg( arg )
      end

   end

   -- was there special validation required?
   if spec.vtable ~= nil then

      local ok

      -- the argument to be checked must also be a table

      if type(arg) ~= 'table' then
	 return false, name:msg( 'incorrect type; must be a table' )
      end

      -- spec.vtable may be a function which returns an actual table
      local vtable = spec.vtable

      if type(vtable) == 'function' then

	 ok, vtable = vtable(arg, vfargs)
	 if not ok then
	    return false, name:msg( vtable )
	 end

	 if type(vtable) ~= 'table' then
	    return false, name:msg( '(validation spec).vtable: expected table from vtable function, got ', type(vtable) )
	 end

      end

      -- record if this vtable should be ordered
      self.state[name].ordered = spec.ordered

      -- descend into the table and see what happens. note that
      -- arg may be transformed
      ok, arg = self:check_table( name, vtable, arg )

      if not ok then
	 return false, arg
      end

   end

   -- must the value be from a set list?
   if spec.enum ~= nil then

      local ok
      local enum = type(spec.enum) == 'table' and spec.enum or { spec.enum }

      for _, v in pairs( enum ) do

	 if v == arg then
	    ok = true
	    break
	 end
      end

      if not ok then
	 return false, name:fmt(': value (%s) is not in approved list', tostring( arg ) )
      end

   end

   return true, arg

end


-- -----------------------------------------------------------------------------
-- Validate an arbirtrary argument against a validation specification.

function Validate:check_arg( name, spec, arg )

   local vfargs = { name = name, va = self, spec = spec }

   if not self.state[name] then self.state[name] = {} end

   local ok
   local opts = self.opts

   -- validate the spec if requested
   if  opts.check_spec
      and not self.state.in_check_spec
      and not self.state.in_default_scan
      and not self.state[name].check_spec_complete
   then

      self.state.in_check_spec = true
      local ok, err = self:check_table( name, validate_spec, spec );
      self.state.in_check_spec = false

      if not ok then
	 if opts.error_on_bad_spec then
	    error( 'validation spec error: ' .. err )
	 else
	    return false, '(validation spec)' .. err
	 end
      end

      self.state[name].check_spec_complete = true
   end

   local callback = spec.precall or spec.before

   if callback then

      local ok, v = callback( arg, vfargs )
      if ok then arg = v end
   end


   ok, arg = self:process_arg_spec( name, spec, arg )

   if not ok then
      return false, arg
   end

   local callback = spec.postcall or spec.after
   if callback then

      local ok, v = callback( arg, vfargs )
      if ok then arg = v end
   end


   return true, arg

end

function Validate:g_rfunc(  )

   if self.opts.error_on_invalid then
      return function( ... )
		if ( select( 1, ... ) ) then
		   return ...
		else
		   error( select( 2, ... ), 4 )
		end
	     end
   elseif self.opts.debug then
      return function( ... )
		if ( select( 1, ... ) ) then
		   return ...
		else
		   io.stderr:write( "ERROR: " .. select( 2, ... ) .. "\n" )
		   return ...
		end
	     end
   else
      return function( ... )  return ... end
   end

end

function Validate:validate_tbl( tpl, arg )

   local name = Name:new( )

   local rfunc = self:g_rfunc()

   return rfunc( self:check_arg( name,
				 {  vtable = tpl,
				    ordered = self:getopt( 'ordered' ),
				 },
				 arg
			      )
	      )

end

function Validate:validate( tpl, ... )

   local ok

   local opts = self.opts

   local rfunc = self:g_rfunc()

   -- do our own simple validation
   if type(tpl) == 'nil' or type(tpl) ~= 'table' then
      return rfunc( false, "argument #2 (tpl): expected table, got " .. type(tpl) )
   end

   -- number of arguments
   local npos = select('#', ... )

   -- original arguments
   local oargs = { ... }
   if opts.before then
      local ok, errmsg = opts.before( oargs )
      if not ok then
	 return rfunc( false, errmsg )
      end
   end

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

      local name = Name:new( { string.format( "arg#%d", i ) } )

      -- the specification may be a function, in which case it
      -- will return the real validation specification.  have to handle
      -- it early for positional arguments as we need to know if a name
      -- was assigned to the argument.

      local ok, spec = resolve_spec( spec, oargs[i] )

      if not ok then

	 return rfunc( false, spec )

      end

      nargs = nargs + 1
      if spec.named and not opts.named then
	 return rfunc( false,
		       name:msg( '(validation spec): top level positional parameters may not set "named" attribute if opts.named is not set' ) )
      end

      local keyname = nargs
      if ( opts.named or spec.named  )
	 and spec.named ~= false
	 and spec.name
      then
	 keyname = spec.name
      end

      local argname = ''
      if spec.name then
	 name = Name:new( { string.format( 'arg#%d(%s)', i, spec.name ) } )
      else
	 name = Name:new( { string.format( 'arg#%d', i ) } )
      end

      handled_pos[i] = true;

      -- distinguish between a nil value and a non-existent positional arg
      if i > npos and not ( spec.optional or spec.default ~= nil ) then
	 return rfunc( false, name:msg( 'missing' ) )
      end

      self.state[name] = { positional = true }
      ok, args[keyname] = self:check_arg( name, spec, oargs[i] )

      if not ok then
	 return rfunc( false, args[keyname] )
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

      local arg = oargs[1] or {}

      -- manufacture a vtable specification
      local spec = { vtable = tpl,
		     ordered = self:getopt( 'ordered' ),
		  }
      local name = Name:new()
      self.state[name] = { positional = false }

      if type(arg) ~= 'table'  then
	 return rfunc( false, "arg#2: expected table , got " .. type(arg) )
      end

     return rfunc( self:check_arg( name, spec , arg ) )

   else

      -- There's an error in the template if idx > 1 and there are
      -- elements in the template that we haven't handled

      local badkeys = {}
      for k in pairs (tpl) do
	 if not handled_pos[k] then
	    table.insert( badkeys, k )
	 end

      end

      if nil ~= next(badkeys) then
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

   if opts.after then
      local ok, errmsg = opts.after( args )
      if not ok then
	 return rfunc( false, errmsg )
      end
   end

   if opts.named then
      return rfunc( true, args )
   else
      return rfunc( true, unpack(args, 1, nargs ) )
   end
end

-------------------------------------------------------------------------------

-- forward declaration of default object to ensure that it's seen by
-- the class constructor; it's properly defined after the definition
-- of the constructor

local defobj = {}


--------------------------------------------------------------------
-- public Class constructor

-- takes these named options.
--  use_current_options: if true, uses current (rather than default) options
--  use_current_types:   if true, uses current (rather than default) types
--  use_current:         if true, uses current options and types

function _M:new( args )

   local ok, args = Validate:validate( { use_current_options = { type = 'boolean', optional = true },
					 use_current_types   = { type = 'boolean', optional = true },
					 use_current         = { type = 'boolean', optional = true ,
								 excludes = { 'use_current_options',
									      'use_current_types' },
							      },
				      },  args )

   if not ok then
      error( _NAME .. ":new(): " .. args, 2 )
   end

   if args.use_current then
      args.use_current_options = true
      args.use_current_types = true
   end

   local obj = Validate:new()

   obj.opts  = args.use_current_options and defobj.opts:new()  or obj.opts
   obj.types = args.use_current_types   and defobj.types:new() or obj.types

   return obj

end

-- set up for the procedural interface using a default object

defobj = Validate:new()

function _M.reset( )
   defobj = Validate:new()
end

function _M.add_type( ... )
   return defobj:add_type( ... )
end

function _M.validate( ... )
   return defobj:validate( ... )
end

-- these wrappers set options; make sure they don't leak into
-- the default object by cloning the default object.
function _M.validate_tbl( ... )

   -- backwards compatibility
   if select('#', ...) == 3 then

      local opts, tpl, arg = ...

      local obj = defobj:new()
      obj:setopts( opts )

      return obj:validate_tbl( tpl, arg )

   else

      return defobj:validate_tbl( ... )

   end

end

function _M.validate_opts( opts, ... )
   local obj = defobj:new();
   obj:setopts( opts )
   return obj:validate( ... )
end

function _M.opts( ... )
   return defobj:setopts( ... )
end

_M.Name = Name
_M.zposnum = zposnum
_M.posnum = posnum
_M.posint = posint
_M.zposint = zposint

return _M
