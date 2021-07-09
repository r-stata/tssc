*! 2.02 07Sep2008



program metacum

	version 9
	syntax varlist [if] [in], ///
	  [by(varlist max =1) or rr rd fixed fixedi random randomi peto log ///
	  wgt(varlist max=1) cc(string) NOINTeger cohen hedges glass standard *]


	capture which metan
	if _rc != 0{
		di as err "Program metacum requires metan to be installed. Type:"
		di in whi "ssc install metan"
		exit _rc
	}


	preserve
	if "`if'" != "" | "`in'" != ""{
		keep `if' `in'
	}
	qui count
	local N = r(N)
	tempvar es se
	qui gen `es' = .
	qui gen `se' = .
	tempvar by2
	if "`by'" != ""{
		cap confirm string var `by'
		if _rc == 0{
			qui encode `by', gen(`by2')
		}
		else{
			qui gen `by2' = `by'
		}
	}
	else{
		qui gen `by2' = 1
	}

	qui levelsof `by2', clean local(bys)

	if "`wgt'" != ""{
		local wgtcmd = "wgt(`wgt')"
	}
	if "`cc'" != ""{
		local cccmd = "cc(`cc')"
	}

	foreach b of numlist `bys'{
		forvalues i=1/`N'{
			if `by2'[`i'] == `b'{

	if "`standard'" != ""{
		local standard = "nostandard"
	}

metan `varlist' in 1/`i' if `by2'==`b', nograph notable `measure' `method' ///
  `or' `rr' `rd' `fixed' `fixedi' `random' `randomi' `peto' `wgtcmd' ///
  `nointeger' `cccmd' `cohen' `hedges' `glass' `standard'

				if _rc == 9{
					di as err "Something not specified correctly (probably multiple
					di as err "conflicting options for metan) - see metan.hlp"
					exit _rc
				}
				if r(selogES) < .{		// find if log or not
					qui replace `es' = ln(r(ES)) in `i'
					qui replace `se' = r(selogES) in `i'
					if "`log'" == ""{
						local eform = "eform"
					}
				}
				else{
					qui replace `es' = r(ES) in `i'
					qui replace `se' = r(seES) in `i'
				}
			}
		}
	}
	if strpos(`"`options'"',"effect(") == 0{
		local ff = r(measure)
		local eff = "effect(`ff')"
	}

	if "`by'" != ""{
		local bycmd = "by(`by2') nosubgroup"
	}
		
	metan `es' `se', nooverall nobox `eff' `options' `eform' `bycmd'

	if "`random'" != "" | "`randomi'" != ""{
		di "Note: random effects weighting used for pooled estimates"
	}
	if "`wgt'" != ""{
		di "Note: user defined weighting used for pooled estimates"
	}
	restore

end
