*! 1.2.0 NJC 3 July 2020 
* 1.1.0 NJC 1 July 2020 
* 1.0.1 NJC 30 June 2020
* 1.0.0 NJC 29 August 2019 
program transplot
	version 8
	gettoken cmd 0 : 0 
	if "`cmd'" == substr("twoway", 1, length("`cmd'")) { 
		gettoken subcmd 0 : 0 
		local cmd `cmd' `subcmd'
	}
	
	gettoken yvarlist 0 : 0, match(parens) parse(" ,")
	unab yvarlist : `yvarlist'
	confirm numeric var `yvarlist' 
	
	syntax [varlist(numeric default=none)] [if] [in], /// 
	[TRansform(string asis)     ///
	YTRansform(string asis)     ///
	XTRansform(string asis)     ///
	COMBINEopts(string) *  ] 

	// data to use 
	marksample touse 
	markout `touse' `yvarlist'
	quietly count if `touse'
	if r(N) == 0 error 2000 
	if r(N) == 1 error 2001
	local N = r(N) 

	// syntax checking 
	if `"`transform'`ytransform'`xtransform'"' == "" { 
		di as err "at least one transform option needed" 
		exit 198 
	} 
	else if `"`transform'"' != "" & `"`ytransform'`xtransform'"' != "" { 
		di as err "may not combine transform() and another transform option" 
		exit 198 
	}
	else if "`ytransform'" != "" & "`transform'`varlist'" == "" { 
		noisily di "note: ytransform() treated as transform()" 
		local varlist `yvarlist'
		local yvarlist  
		local transform `ytransform' 
		local ytransform 
	} 

	if "`xtransform'" != "" & "`transform'`varlist'" == "" { 
		noisily di "note: xtransform() treated as transform()" 
		local varlist `yvarlist' 
		local transform `xtransform' 
		local xtransform 
	} 

	// two-way mode: bail out when done 
	quietly if `"`ytransform'`xtransform'"' != "" { 
		if `"`ytransform'"' == "" local ytransform "@" 
		if `"`xtransform'"' == "" local xtransform "@" 
		
		local yvars 
		foreach t of local ytransform {
		    foreach y of local yvarlist { 
				if "`t'" == "@" { 
					local yvars `yvars' `y' 
				} 
				else if !strpos("`t'", "@") { 
					tempvar Y 
					gen `Y' = `t'(`y') 
					label var `Y' "`t'(`y')" 

					noisily CheckMiss `touse' `Y' `N' "`t(`y')'" 
				
					local yvars `yvars' `Y'
				}
				else { 
					tempvar Y 
					local defn : subinstr local t "@" "`y'", all 
					gen `Y' = `defn' 
					label var `Y' "`defn'"

					noisily CheckMiss `touse' `Y' `N' "`defn'" 
				
					local yvars `yvars' `Y'
				} 
			}

			local xvarlist `varlist'
			local xvars 
			foreach s of local xtransform {  
				foreach x of local xvarlist { 
					if "`s'" == "@" { 
						local xvars `xvars' `x' 
					} 
					else if !strpos("`s'", "@") { 
						tempvar X 
						gen `X' = `s'(`x') 
						label var `X' "`s'(`x')" 
						local xvars `xvars' `X'
						noisily CheckMiss `touse' `X' `N' "`t(`x')'" 
					}
					else { 
						tempvar X 
						local defn : subinstr local s "@" "`x'", all 
						gen `X' = `defn' 
						label var `X' "`defn'"
						local xvars `xvars' `X' 
						noisily CheckMiss `touse' `X' `N' "`defn'" 
					} 
				}
			}
		}
			
		foreach y of local yvars {
			foreach x of local xvars {
				tempname newplot 
				`cmd' `y' `x' if `touse', nodraw name(`newplot') `options'
				local plots `plots' `newplot'
 			}
		}

		graph combine `plots', `combineopts'
		exit 0 
	}

	// one-way mode 
	local varlist `yvarlist' `varlist'
	
	quietly foreach v of local varlist { 
		foreach t of local transform { 
			tempname newplot 
			local plots `plots' `newplot' 

			if "`t'" == "@" {
				`cmd' `v' if `touse', nodraw name(`newplot') `options' 
			}

			else if !strpos("`t'", "@") { 
				tempvar newvar 
				gen `newvar' = `t'(`v') 
				label var `newvar' "`t'(`v')" 

				noisily CheckMiss `touse' `newvar' `N' "`t'(`v')" 
		
				`cmd' `newvar' if `touse', nodraw name(`newplot') `options' 
			}

			else { 
				tempvar newvar 
				local defn : subinstr local t "@" "`v'", all 
				gen `newvar' = `defn' 
				label var `newvar' "`defn'"

 				noisily CheckMiss `touse' `newvar' `N' "`defn'" 

				`cmd' `newvar' if `touse', nodraw name(`newplot') `options' 
			}	
		}
	}

	graph combine `plots', `combineopts' 
end 

program CheckMiss 
	args TOUSE NEWVAR N WHAT 

	quietly count if `TOUSE' & `NEWVAR' < . 

	if r(N) < `N' { 
		display `N' - r(N) " missing values created in `WHAT'" 
		if r(N) == 0 error 2000
		if r(N) == 1 error 2001 
	} 
end 

