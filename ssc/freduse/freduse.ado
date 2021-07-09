*! version 2.0.0  19Sep2005
program define freduse
	version 9.0

	syntax anything(name=slist id="series list" everything) ,	///
		[ File  clear ]


	mata: _fredifinparse("slist", "ifinmacro")
	

	if "`file'" != "" {
		_freduse `slist' ,`clear'
	}
	else {
		_fredweb `slist' , `clear'
	}

	sort daten

	if "`ifinmacro'" != "" {
		capture noi keep `ifinmacro'
		if _rc {
			di as err "`ifinmacro' specifies an invalid condition"
		}
	}
end
