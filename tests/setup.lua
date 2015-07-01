local va = require( 'validate.args' )

return function ()
	      va.reset()
	      va.opts{ check_spec = true,
		       error_on_bad_spec = true,
		    }
	   end

