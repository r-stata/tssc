*! CFB/NJC 1.0.8 18oct2005
* 1.0.0 16apr2004
* from mvsumm 1.0.6 of 10apr2003
* 1.0.1 20apr2004 modify window option
* 1.0.2 20apr2004 add ts option
* 1.0.3 21apr2004 promote to 8.2, remove levels7, preserve sort order
* 1.0.4 24jun2004 remove levels to permit use on large # panels
* 1.0.5 15jul2004 parallel change to mvsumm to change if to in
* 1.0.6 24sep2004 parallel change to mvsumm to correct results with if/in
* 1.0.7 17oct2005 parallel change to mvsumm to add force option
* 1.0.8 18oct2005 code tweaks 
program mvcorr, rclass sort
        version 8.2  
	syntax varlist(min=2 max=2 ts) [if] [in]  /// 
	, Generate(name)  [ Window(int -1) End FORCE]

	* generated variable must be new 
	confirm new var `generate' 

	* what data to use 
	marksample touse, novarlist  

	* ensure that we have a calendar; check for panel var
        qui tsset 
	* if panelvar is defined, call that the by option
    	local by `r(panelvar)'
 	local timevar `r(timevar)'
        markout `touse' `timevar'
        tsreport if `touse', report panel
        if r(N_gaps) {
                di as err "sample may not contain gaps"
                exit 198 
        }
        
	if "`by'" != ""  { 
		markout `touse' `by', strok
	} 	
	
	qui count if `touse'
	if r(N) == 0 error 2000 
	return local N = r(N)
	
	if `window' < 3  {
        	di as err ///
		"window length must be provided and at least 3 periods"
		exit 198
	}

	* from movsumm
	local jaybase = `window'
        local jlast = _N
	
	* check for odd-length window
	if mod(`window',2) != 0 & "`end'" != "end" { 
		local shift = int(`window'/2) 
	}

	* initialise -generate()- 
	local gen "`generate'" 
	qui gen `gen' = .

	* in panel context, get distinct values of panelvar 
	* and hit with -forval-
	qui if "`by'" != "" { 
		tempvar group
		egen `group' = group(`by') /* if `touse' */
		su `group', meanonly
		local max = `r(max)'
		local start 0
		local fin 0
		forval i = 1 / 	`max' {
			count if `group' == `i'
  			local enn = r(N)
  			local jlast = `enn' + `fin'
			* logic from movsumm
			local eye = 1 + `start'
			local kay = `window' + `start'
			forval jay = `jaybase'/`jlast' {
				capt corr `varlist' in `eye'/`kay' 
				if _rc != 2000 {
			        	local na = r(N)
				        if "`force'" == "" {
						replace `gen' = r(rho) in `jay' ///
						if `na' == `window'
					}
					else replace `gen' = r(rho) in `jay' 
				}
				local ++eye
				local ++kay 
                	}
			local start = `start' + `enn'
			local fin = `fin' + `enn'
			local jaybase = `jaybase' + `enn' 
	        }
	} /* end of code for panels */ 
	
	* single timeseries, no loop over panel var
	else  qui { 
		* logic from movsumm
		local eye = 1
		local kay = `window'
		forval jay = `jaybase'/`jlast' {
			capt corr `varlist' in `eye'/`kay'  
			if _rc != 2000 {
				local na = r(N)
				if "`force'" == "" {
					replace `gen' = r(rho) in `jay' ///
					if `na' == `window'
				}
				else replace `gen' = r(rho) in `jay' 
			}
			local ++eye 
			local ++kay 
		}     	
	} /* end of code for no panels */ 
	
	qui if "`shift'" != "" {
		replace `gen' = F`shift'.`gen'
	} 
	qui replace `gen' = . if !`touse'	
end 
