*! version 1.1.1, Brent McSharry, 15may2018
* Risk adjusted sequential probability ratio chart
program define rasprt, sortpreserve
version 10.1
syntax varlist(min=2 max=2 numeric) [if] [in] , Predicted(varname numeric) [OR(real 2) AThreshold(real 0.01) BThreshold(real 0.01) AWarn(real 0.05) BWarn(real 0.05) HEADstart(real 0) /*
		*/noSPRT noCUSUM noRESET  XLABEL(passthru) NOTE(passthru) TITLE(passthru) SUBtitle(passthru) XTitle(passthru) XAXis(passthru)] 
	marksample touse
	qui {
		count if `touse'
		local count `r(N)'
		if (`count'<2) {
			di as error "at least 2 obs required"
			return 2000
		}
		if ("`sprt'"!="" & "`cusum'"!="") {
			di as error "only one of noraspt or nocusum can be specified (otherwise chart is empty)"
			return 198
		}
		
		if `headstart' <0 | `headstart'>1 {
			di as error "headstart represents a multiplier to the threshold for where to begin after reset and must be between 0 and 1"
			return 198
		}
		
				// local lnor = ln(`or')
		local warn_upper = ln((1-`bwarn')/`awarn') //`lnor'
		local warn_lower = ln(`bwarn'/(1-`awarn')) //`lnor'
		local threshold_upper = ln((1-`bthreshold')/`athreshold') //`lnor'
		local threshold_lower = ln(`bthreshold'/(1-`athreshold')) //`lnor'
		foreach v in warn_upper warn_lower threshold_upper threshold_lower {
			local `v':di %3.1f ``v' '
		}
		
		tempvar si Tisprt resetvar1 resetvar2 Tihalf signal sprtcumulative cusumcumulative
		tokenize `varlist'
		local observed `1'
		gsort  -`touse' `2'
		tempvar sequenceVar
		gen `sequenceVar' = _n in 1/`count'
		set obs `=_N+1'
		label variable `sequenceVar' "Case No."
		replace `sequenceVar' = 0 in l
		replace `touse' = 1 in l
		gsort  -`touse' `sequenceVar'
		local ++count

		gen `si' = ln(cond(`observed',`or',1)/(`or' * `predicted' + 1 - `predicted')) in 2/`count'
		local resetto = `headstart'*`threshold_upper'
		gen byte `signal'=.
		
		if "`sprt'" == "" {
			gen float `Tisprt' = 0 in 1
			if "`reset'" == "" {
				replace `Tisprt' = `si' + cond(`Tisprt'[_n-1] < `threshold_upper' & `Tisprt'[_n-1] > `threshold_lower',`Tisprt'[_n-1],`resetto') in 2/`count'
				replace `signal' = `Tisprt'>`threshold_upper' | `Tisprt' < `threshold_lower' in 1/`count'
				gen int `sprtcumulative' = sum(`signal'[_n-1]) in 2/`count'
				sum `signal', meanonly
				if r(sum) > 15 {
					di as error "crosses threshold `r(sum)' times & suggests prediction model calibration/fit is unacceptable"
					error 198
				}
				forvalues i=0/`r(sum)' {
					tempvar s`i'
					gen float `s`i'' = `Tisprt' if `sprtcumulative'==`i'
					replace `s`i'' = `resetto' if missing(`s`i'') & !missing(`s`i''[_n+1])
					if `i' >=15 {
						local sprtgraph `sprtgraph' `s`i''
					}
					else {
						local pstyle1 `pstyle1' p1
					}
					local sprtgraph `sprtgraph' `s`i''
				}
				local sprtgraph line `sprtgraph' `sequenceVar' , pstyle(`pstyle1')
			}
			else {
				replace `Tisprt' = `Tisprt'[_n-1] + `si' in 2/`count'
				local sprtgraph line `Tisprt' `sequenceVar' if `touse'
			}
			
		}
		
		if "`cusum'" == "" {
			gen float `Tihalf' = 0 in 1
			if  "`reset'"==""{
				replace `Tihalf' = max(`si' + cond(`Tihalf'[_n-1] < `threshold_upper',`Tihalf'[_n-1],`resetto'),0) in 2/`count'
				replace `signal' = `Tihalf'>`threshold_upper' in 1/`count'
				gen int `cusumcumulative' = sum(`signal'[_n-1]) in 2/`count'
				sum `signal', meanonly
				forvalues i=0/`r(sum)' {
					tempvar c`i'
					gen float `c`i'' = `Tihalf' if `cusumcumulative'==`i'
					replace `c`i'' = `resetto' if missing(`c`i'') & !missing(`c`i''[_n+1])
					local halfgraph `halfgraph' `c`i''
					local pstyle2 `pstyle2' p2
				}
				local halfgraph line `halfgraph' `sequenceVar' , pstyle(`pstyle2')
			}
			else {
				replace `Tihalf' = max(`si' + `Tihalf'[_n-1],0) in 2/`count'
				local halfgraph line `Tihalf' `sequenceVar' if `touse'
			}
			
		}
	}
	
	if "`title'" == "" {
		local title:variable label `observed'
		if "`title'"=="" {
			local title `observed'
		}
		local title title(`"`title'"')
	}
	
	if "`xaxis'" != "" {
		if "`sprtgraph'"=="" {
			if strpos("`halfgraph'",",")==0 {
				local halfgraph `halfgraph', `xaxis'
			}
			else {
				local halfgraph `halfgraph' `xaxis'
			}
		}
		else {
			if strpos("`sprtgraph'",",")==0 {
				local sprtgraph `sprtgraph', `xaxis'
			}
			else {
				local sprtgraph `sprtgraph' `xaxis'
			}
		}
	} 
	
	if "`sprtgraph'"!="" {
		local finalgraph (`sprtgraph')
	}
	
	if "`halfgraph'"!="" {
		local finalgraph `finalgraph' (`halfgraph')
	}

	capture noisily twoway `finalgraph' /*
	*/ , yline(`threshold_upper' `threshold_lower', lwidth(thin) lpattern(shortdash)) /*
	*/ legend(off) ytitle("Cumulative Log-Likelihood Ratio") `title' `note' `subtitle' `xlabel'/*
	*/ ylabel(`threshold_upper' `warn_upper' 0 `warn_lower' `threshold_lower', angle(0))
	
	qui drop in 1
end
