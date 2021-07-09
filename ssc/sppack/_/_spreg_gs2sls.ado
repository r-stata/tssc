*! version 1.0.1  03jun2010
program define _spreg_gs2sls, eclass

	version 11.1

	syntax varlist(default=none min=2 numeric)  	///
		[if] [in]  			,	///
		*
	
	spivreg `varlist' `if' `in', spreg `options'

end
