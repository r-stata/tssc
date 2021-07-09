*! version 1.0.0, Ben Jann, 09apr2007
prog labelsof, rclass
	version 8
	syntax name [, Label ]
	if "`label'"=="" {
		local labdef: value label `namelist'
		if `"`labdef'"'=="" {
			exit
		}
	}
	else local labdef "`namelist'"
	tempfile fn
	qui label save `labdef' using `"`fn'"'
	tempname fh
	file open `fh' using `"`fn'"', read
	file read `fh' line
	local values
	local labels
	local space
	if "`label'"=="" di as txt _n "`namelist' ({res}`labdef'{txt}):" _n
	else di as txt _n "`labdef':"
	while r(eof)==0 { // label define <labeldef> <value> `"label'", modify
		gettoken value line : line
		gettoken value line : line
		gettoken value line : line
		gettoken value line : line
		gettoken label line : line, parse(", ") match(paren)
		local values "`values'`space'`value'"
		local labels `"`labels'`space'`"`label'"'"'
		di as res %12s "`value'" " " `"`label'"'
		file read `fh' line
		local space " "
	}
	file close `fh'
	ret local labels `"`labels'"'
	ret local values "`values'"
	ret local name "`labdef'"
end
