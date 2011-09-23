-- --8<--8<--8<--8<--
--
-- Copyright (C) 2011 Smithsonian Astrophysical Observatory
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
--- validate.inplace: Validate assignments as they are made

local assert = assert
local error = error
local pairs = pairs
local rawget = rawget
local select = select
local setmetatable = setmetatable
local type =type
local va = require('validate.args')

local print = print

module( ... )

local mt = {}
setmetatable( mt, { _mode = 'k' } )

-- stash an assigned value into a proxied table.  since stash is keyed
-- off of proxied (sub)tables need to descend value and assign the
-- data to the correct stashed table
local function _stash( st, value )

   for k,v in pairs( st.spec ) do

      local val = value[k]

      if val ~= nil then
	 if st.elem[k] then
	    _stash( st.elem[k], val )
	 else
	    st.data[k] = val
	 end
      end

   end
end

local function _proxy__index (proxy, k )
   local st = mt[proxy]

   if not st.spec[k] then
      error( st.name:add(k):msg( "unknown element"), 2 )
   end

   -- see if the requested element is a proxied table; if so
   -- return the proxy
   if st.elem[k] then
      return st.elem[k].proxy
   end

   -- not proxied; return the assigned value or default if none
   if  st.data[k] ~= nil then
      return st.data[k]
   else
      local ok, v = st.self.vobj:defaults( st.name:add(k), st.spec[k] );
      if not ok then
	 error( v )
      else
	 return v
      end
   end
end


local function _proxy__newindex ( proxy, k, v )
   local st = mt[proxy]

   if not st.spec[k] then
      error( st.name:add(k):msg( "unknown element"), 2 )
   end

   local ok, v = st.self.vobj:check_arg( st.name:add(k), st.spec[k], v )
   if not ok then
      error( v, 2 )
   end

   -- carefully stash new data. if proxy[k] is itself a proxied table, need to
   -- traverse the sub-table(s)
   if st.elem[k] then
      _stash( st.elem[k], v )
   else
      st.data[k] = v
   end

end


function _M:_populate( name, specs )

   local elem = {}

   for k, spec in pairs( specs ) do

      if type( spec ) == 'function' then
	 error( name:add(k):msg( "cannot process a mutable specification" ) )
      end

      -- if the spec is a vtable, this is a table
      if spec.vtable ~= nil then

	 if type(spec.vtable) == 'function' then
	    error( name:add(k):msg( "cannot process a function vtable" ) )
	 end

	 elem[k] = self:_populate( name:add( k ), spec.vtable )

      end

   end

   local proxy = {}

   mt[proxy] = {
      name = name:dup(),
      spec = specs,
      self = self,
      data = {},
      elem = elem,
      proxy = proxy,
      __index    = _proxy__index,
      __newindex = _proxy__newindex
   }

   setmetatable( proxy, mt[proxy] )

   return mt[proxy]

end

function _copy( st, specs )

   local copy = {}

   if st == nil then
      error( "internal error" )
   end

   for k, spec in pairs( specs ) do

      -- if there's a proxy object, descend into it
      if st.elem[k]  then
	 copy[k] = _copy( st.elem[k], spec.vtable )

      else
	 -- not proxied; return the assigned value or default if none
	 -- this is more or less duplicated from _proxy__index
	 -- it shouldn't be
	 if  st.data[k] ~= nil then
	    copy[k] = st.data[k]
	 else
	    local ok, v = st.self.vobj:defaults( st.name, st.spec[k] );
	    if not ok then
	       error( v )
	    else
	       copy[k] = v
	    end

	 end

      end

   end

   return copy

end

function _M:copy( )

   return _copy( self.top, self.spec )

end

 __index = _M

function _M:new( ... )

   local ok, name, spec, vobj = va.validate( { { name = 'name',
						 type = 'string' },
					       { name = 'spec',
						 type = 'table' },
					       { name = 'vobj',
						 type = 'table' },
					    },
					     ...
					  )
   assert( ok, name )

   local self = { vobj = vobj, spec = spec }

   setmetatable( self, _M )


   name = va.Name:new( { name } );

   self.top = self:_populate( name, spec )

   return self

end

function _M:proxy( )

   return self.top.proxy

end
