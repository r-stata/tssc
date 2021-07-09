*! 1.0.2 NJC 25 November 2008 
* 1.0.1 NJC 25 November 2008 
* 1.0.0 NJC 19 November 2008 
program bandplot
	version 8 
	syntax anything [if] [in] [aweight fweight] ///
	[, Statistics(str) dta(str asis) CATegorical(varlist) CONTinuous(varlist) ///
	NQuantiles(int 4) xweighted xvarlabels yvarlabels NUmber MISSing ///
	recast(str) bandopts(str asis) xopts(str asis) by(str) *  ] 

	// not documented 
	if "`by'" != "" { 
		di as err "by() option not supported"
		exit 0 
	} 

	gettoken yvars xvars : anything, match(ny) 
	unab yvars : `yvars' 
	unab xvars : `xvars' 
	confirm numeric var `yvars' 
	local varlist `yvars' `xvars' 

	if "`missing'" == "" marksample touse, strok  
	else { 
		marksample touse, novarlist 
		markout `touse' `yvars' 
	} 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	if "`categorical'" != "" { 
		if !`: list categorical in xvars' { 
			di as err "`categorical' not a subset of `xvars'"
			exit 498 
		} 
	} 

	if "`continuous'" != "" { 
		if !`: list continuous in xvars' { 
			di as err "`continuous' not a subset of `xvars'"
			exit 498 
		}

		if "`categorical'" != "" { 
			local both : list categorical & continuous 
			if "`both'" != "" { 
				di as err "`both' categorical and continuous?" 
				exit 498 
			} 
			local either : list categorical | continuous 
			local neither : list xvars - either  
			if "`neither'" != "" {
				di as err "`neither' unclassified" 
				exit 498 
			}
		} 
		else local categorical : list xvars - continuous 
	} 

	if "`recast'" != "" { 
		if !inlist("`recast'", "dot", "bar", "hbar") { 
			di as err "recast(`recast') invalid" 
			exit 198 
		}
	}
	else local recast dot 

	tokenize "`yvars'"
	local ny : word count `yvars' 
	if `ny' > 1 { 
		local ns = `: word count `statistics'' 
		if `ns' > 1 { 
			di as err ///
			"`ns' statistics not allowed with `ny' responses" 
			exit 198 
		}

		if "`yvarlabels'" != "" { 
			forval j = 1/`ny' { 
				local Y`j' `"`: var label ``j'''"' 
				if `"`Y`j''"' == "" local Y`j' "``j''" 
			}
		} 
	} 
	else { 
		local Y : var label `yvars' 
		if `"`Y'"' == "" local Y "`yvars'" 
	} 

	if "`statistics'" == "" local statistics "mean" 
	local how 1  
	local OK1 N sum sum_w mean min max 
	local OK2 sd Var 
	local OK3 skewness kurtosis p1 p5 p10 p25 p50 p75 p90 p95 p99 

	foreach s of local statistics { 
		local OK 0 
		forval i = 1/3 { 
			if `: list s in OK`i'' { 
				local OK 1 
				local how = max(`how', `i') 
			} 
		}
		if !`OK' { 
			di as err "`s' not allowed as statistic" 
			exit 198 
		}
		local svars `svars' `s' 
		local slist `slist' (r(`s')) 
	} 

	if "`number'" != "" local slist `slist' (r(N)) 
	local how : word `how' of "meanonly" " " "detail" 

	local nqm1 = `nquantiles' - 1 
	forval i = 0/`nqm1' { 
		tempname q`i' 
	} 

	tempfile results 
	tempname out 
	postfile `out' str244(x lbl) xorder band yorder `svars' `number' ///
	using `results' 
	local band = 0 
	local xorder = 0 
	if "`xweighted'" != "" local xw "[`weight' `exp']" 

	qui foreach x of local xvars { 
		local X = cond("`xvarlabels'" != "", `"`: var label `x''"', "`x'")
		if `"`X'"' == "" local X "`x'" 
		local ++xorder 
		local X`xorder' "`X'" 

		if `: list x in categorical' | substr("`: type `x''", 1, 3) == "str" {
			tempvar g 
			egen `g' = group(`x') if `touse', label `missing'  
			su `g', meanonly 
			forval i = 1/`r(max)' { 
				local lbl : label (`g') `i' 
				local ++band 
				forval j = 1/`ny' { 
	su ``j'' if `g' == `i' [`weight' `exp'], `how' 
	post `out' ("`X'") ("`lbl'") (`xorder') (`band') (`j') `slist'
				}
			} 
			drop `g' 
		} 
		else {
			_pctile `x' if `touse' `xw', nq(`nquantiles') 
			forval i = 1/`nqm1' { 
				scalar `q`i'' = r(r`i') 
			}
			
			su `x' if `touse', meanonly 
			local xfmt : format `x' 
			local l1 : di `xfmt' r(min) 
			local l1 = trim("`l1'") 
			local lm : di `xfmt' r(max) 
			local lm = trim("`lm'") 

			// why subtract 1?
			// > (min - 1) is >= min just below 
			scalar `q0' = r(min) - 1 
			
			forval i = 1/`nqm1' { 
				local im1 = `i' - 1
				local ifx `x' > `q`im1'' & `x' <= `q`i''  
				local l2 : di `xfmt' `q`i'' 
				local l2 = trim("`l2'") 
				local lbl "[`l1', `l2')"
				local ++band 
				forval j = 1/`ny' {
 	su ``j'' if `ifx' & `touse' [`weight' `exp'], `how' 
	post `out' ("`X'") ("`lbl'") (`xorder') (`band') (`j') `slist'
				}					 
				local l1 "`l2'" 
			} 

			local lbl "[`l2', `lm']" 
			local ++band 
			forval j = 1/`ny' { 
	su ``j'' if `x' > `q`nqm1'' & `x' < . & `touse' [`weight' `exp'], `how'
	post `out' ("`X'") ("`lbl'") (`xorder') (`band') (`j') `slist'
			}

			count if missing(`x') & `touse' 
			if r(N) > 0 & "`missing'" != "" { 
				tempvar g 
				egen `g' = group(`x') ///
				if missing(`x') & `touse', label missing  
				su `g', meanonly 
				forval i = 1/`r(max)' { 
					local lbl : label (`g') `i' 
					local ++band 
					forval j = 1/`ny' { 
	su ``j'' if `g' == `i' [`weight' `exp'], `how' 
	post `out' ("`X'") ("`lbl'") (`xorder') (`band') (`j') `slist'
					}
				} 
				drop `g' 
			}
		} 
	}

	postclose `out' 
	preserve 
	qui use `results', clear 
	qui compress 


	if `: word count `svars'' > 1 local ytitle "`Y'" 
	else if `ny' > 1 local ytitle " "  
	else local ytitle "`svars' `Y'" 

	if `ny' > 1 { 
		qui reshape wide `svars', i(x band) j(yorder)  
		unab svars : `svars'* 
		tokenize `svars' 

		if "`yvarlabels'" != "" { 
			forval j = 1/`ny' { 
				label var ``j'' `"`Y`j''"' 
			} 
		}
		else { 
			forval j = 1/`ny' { 
				local Y : word `j' of `yvars' 
				label var ``j'' "`Y'" 
			} 
		} 
	}

	if "`number'" != "" { 
		su `number', meanonly 
		local maxl = 3 + length("`r(max)'") 
	}

	sort band  

	forval i = 1 / `=_N' { 
                local label1 = lbl[`i'] 
		if "`number'" != "" { 
			local thisn = number[`i'] 
			local thissp = `maxl' - length("`thisn'") 
			local label2 : di _dup(`thissp') `" "' 
			local label2 `"`label2'`thisn'"'   
		} 
                label def band `i' `"`label1'`label2'"', modify         
        } 
        label val band band          

	forval i = 1/`xorder' { 
		label def xorder `i' `"`X`i''"', modify 
	}
	label val xorder xorder 

	graph `recast' (asis) `svars', ///
	over(band, `bandopts')         ///
	over(xorder, `xopts')          ///
	nofill                         ///
	ytitle(`"`ytitle'"')           ///
	`options' 

	if `"`dta'"' != "" { 
		save `dta' 
	} 
end 

