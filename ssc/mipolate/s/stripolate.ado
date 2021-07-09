* stripolate 
*! 1.1.0 NJC 15dec2016 
* 1.0.0 NJC 14dec2016 
* mipolate 1.2.0 NJC 2sep2015 
* 1.1.0 NJC 27aug2015 
* 1.0.0 NJC 20jul2015 
* ipolate 1.3.3  21sep2004
program stripolate, byable(onecall) sort
	version 10          
	syntax varlist(min=2 max=2) [if] [in], /// 
	GENerate(string) ///
	[ BY(varlist)    /// 
	Forward          ///
	Backward         ///
	Groupwise ]

	// syntax checks 
	tokenize `varlist' 
	args stry x 

	capture confirm string var `stry' 
	if _rc { 
		di as err "{p}stripolate is for interpolation of " ///
		"string variables only: try {cmd:mipolate} (SSC)?{p_end}" 
		exit _rc 
	} 

	capture confirm numeric var `x' 
	if _rc { 
		di as err "{p}stripolate is for interpolation with " ///
		"respect to a numeric variable: see {help stripolate}{p_end}" 
		exit _rc 
	} 

	if _by() {
		if "`by'" != "" {
			di as err /*
			*/ "option by() may not be combined with by prefix"
			exit 190
		}
		local by "`_byvars'"
	}

	local nopts : word count `forward' `backward' `groupwise' 

	if `nopts' != 1 {
		di as err "must specify one interpolation method" 
		exit 198 
	}

	confirm new var `generate'

	quietly {
		// anything to do? 
		marksample touse, novarlist  
		replace `touse' = 0 if missing(`x')
		count if `touse' 
		if r(N) == 0 error 2000 

		count if missing(`stry') & `touse' 
		if r(N) == 0 { 
			noisily di as txt "{p}nothing to do; " /// 
			"no missing `stry' that can be interpolated{p_end}" 
			exit 0 
		} 

		// uniqueness checks  
		tempvar diff z  
		// if we have different strings say "A" "B" for identical `x' 
		// then we don't know which to use 
		
		bysort `touse' `by' `x' (`stry') : ///
			gen byte `diff' = !missing(`stry') & (`stry' != `stry'[_N]) 
		bysort `touse' `by' (`diff'): replace `diff' = `diff'[_N] 
		replace `touse' = 0 if `diff' 

		count if `touse' 
		if r(N) == 0 { 
			local msg "{p}no interpolation: different non-missing string values" 
			if "`by'" != "" { 
				di as err "`msg' for same `by' and `x'{p_end}" 
			}
			else di as err "`msg' for same `x'{p_end}" 
			exit 498 
		} 

		// forward or backward 
		if "`forward'`backward'" != "" { 
			clonevar `z' = `stry' 

			if "`forward'" != "" { 
				bysort `touse' `by' (`x') : ///
				replace `z' = `z'[_n-1] if `touse' & missing(`z' ) 
			}
			else { 
				tempvar negx 
				gen double `negx' = -`x' 
				bysort `touse' `by' (`negx'): /// 
				replace `z' = `z'[_n-1] if `touse' & missing(`z') 
			}
		}

		if "`groupwise'" != "" { 
			// check for uniqueness again 
			// if we have different strings say "A" "B" in any group       
			// then we don't know which to use 
			bysort `touse' `by' (`stry') : ///
				replace `diff' = !missing(`stry') & (`stry' != `stry'[_N]) 
			bysort `touse' `by' (`diff') : replace `touse' = 0 if `diff'[_N] 
			count if `touse' 

			if r(N) == 0 { 
				local msg1 "{p}no interpolation: different non-missing string values" 
				if "`by'" != "" local msg2 " for same `by'" 
				di as err "`msg1'`msg2'{p_end}" 
				exit 498 
			} 
			
			clonevar `z' = `stry' 
			bysort `touse' `by' (`stry') : ///
				replace `z' = `z'[_N] if missing(`z') & `touse'  
		} 

		rename `z' `generate'
		compress `generate' 
		count if missing(`generate') 
	}

	if r(N) > 0 {
		if r(N) != 1 local pl "s" 
		di as txt "(" r(N) `" missing value`pl' generated)"'
	}
end

