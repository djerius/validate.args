
local say = require("say")
local assert = require( "luassert" )

local function matches(state, arguments )


    if #arguments ~= 2 then
      return false
    end

    expected = arguments[1]
    if type(expected) ~= 'table' then
       expected = { expected }
    end

    -- actual must be (convertible to) a string
    actual = arguments[2]
    local mt = getmetatable(actual)

    if mt and mt.__tostring then
      actual = tostring(actual)
    end

    for _, pattern in ipairs( expected ) do

       if actual:find( pattern ) ~= nil then
	  return true
       end

    end

    return false

end

say:set("assertion.matches.positive", "Expected strings to match.\nPassed in:\n%s \nExpected:\n%s")
say:set("assertion.matches.negative", "Expected strings to not match.\nPassed in:\n%s \nExpected:\n%s")
assert:register("assertion", "matches", matches,
		"assertion.matches.positive", "assertion.matches.negative")
assert:register("assertion", "matche", matches,
		"assertion.matches.positive", "assertion.matches.negative")
