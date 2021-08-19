*! version 1.0.0  04apr2021
program try
	version 15
	_on_colon_parse `0'
	local 0 `"`s(before)'"'
	local after `"`s(after)'"'

	// setup
	local maxt = 900		        // cutoff for total sleep time in seconds
	local a 500			            // a for runiformint(a,b)
	local b 1000			        // b for runiformint(a,b)
	local e = 0.5*(`a'+`b') 	    // expected value of runiform(a,b)
	local maxn = `maxt'/(`e'/1000)	// cutoff for # of tries if specified as .

	syntax [anything(name=n)] [,	///
		Tmax(integer `maxt') 	    ///
		Verbose 		            ///
		noDOTS			            ///
		Noisily			            /// not documented
		]

	if `"`n'"' == "" local n 30
	if `"`n'"' == "." local n `maxn'
	capture confirm integer number `n'
	if _rc {
		di as err "number of tries must be an integer"
		exit 198
	}
	if `n' < 1 | `n' > `maxn' {
		di as err "number of tries must be between 1 and `maxn'"
		exit 198
	}
	local tmax = `tmax'*1000 // milliseconds
	if `tmax' < 2000 | `tmax' > `maxt'*1000 {
		di as err "tmax() must be between 2 and `maxt'"
		exit 198
	}

	local dd = "`dots'" == ""
	if "`noisily'" != "" local dd 0
	local cc `c(linesize)'
	local tt 0
	local ix 0
	capture `noisily' `after'
	if _rc {
		while `ix' < `n' {
			local t = runiformint(`a',`b')
			if `tt' + `t' > `tmax' {
				continue, break
			}
			local tt = `tt' + `t'
			local ++ix
			sleep `t'
			capture `noisily' `after'
			if `dd' di as txt "." _c
			if !mod(`ix',`cc') di
			if !_rc {
				continue, break
			}
		}
		if `dd' di
	}

	if "`verbose'" != "" {
		local tt = `tt' / 1000
		local tt : display %21.3f `tt'
		local tt = trim("`tt'")
		di as txt "(tried `ix' times, slept for `tt' seconds)"
	}

	if _rc {
		local after = trim(itrim(`"`after'"'))
		local cc = word(`"`after'"',1) + " " + word(`"`after'"',2)
		local cc `cc'
		local eq : list cc == after
		if `eq' == 0 local dots " ..."
		di as err `"{bf:`cc'}`dots' failed"'
		di as err "{p 0 0}run the command without the {bf:try} prefix" ///
			" to examine the underlying problem{p_end}"
		exit 198
	}
end
exit

