*! version 1.0.2 25may2007
*! Arjas plot checking proportional hazard assumption
program define starjas
	version 8.0
	syntax varname(numeric) [if] [in] ,  [ ADJust(varlist) LEVelplot(numlist integer) atobs(integer 0) RRGLAnce(real 1) * ]
	st_is 2 analysis
	marksample touse
	qui replace `touse' = 0 if _st==0
	capture assert `varlist' == int(`varlist') if `touse' 
	if _rc { 
		di as err "`varlist' contains non-integer values" 
		exit 459
	} 
	local id : char _dta[st_id]
	if "`id'"!="" {
		cap bysort `_dta[st_id]' : assert _N==1
		if _rc {
			di in smcl as err "{p}Arjas plot not allowed for multiple records per subjects.{p_end}"
			exit 459
		}
	}
	cap assert _t0 == 0
	if _rc {
		di in smcl as err "{p}Arjas plot not allowed for survival data with delayed entry.{p_end}"
		exit 459
	}
	qui tab `varlist'
	if `r(r)' > 2 & `rrglance'!=1 {
			di in smcl as err "{p}option rrglance() is only allowed for binary covariates.{p_end}"
			exit 459
	}
	 _get_gropts , graphopts(`options') getallowed(LColor LPattern LWidth SAving legend scheme plot xsize ysize)
	local options `"`s(graphopts)'"'
	local lpattern `"`s(lpattern)'"'
	local lcolor `"`s(lcolor)'"'
	local lwidth `"`s(lwidth)'"'
	local saving `"`s(saving)'"'
	local scheme `"`s(scheme)'"'
	local legend `"`s(legend)'"'
	local plot `"`s(plot)'"'
	local xsize `"`s(xsize)'"'
	local ysize `"`s(ysize)'"'
	if "`saving'" != "" local saving `"saving(`saving')"'
	if "`scheme'" != "" local scheme `"scheme(`scheme')"'
	if "`plot'" != ""   local plot `"(`plot')"'
	if "`xsize'" != ""   local xsize `"xsize(`xsize')"'
	if "`ysize'" != ""   local ysize `"ysize(`ysize')"'
	if `atobs'==0       local atobs 
	preserve
	tempname est
	cap _estimates hold `est'
	quietly {
		keep if `touse'
		levelsof `varlist', local(levels) clean
		if "`levelplot'"!="" {
			local ckplot : list levelplot - levels
			if "`ckplot'" != "" {
				di in smcl as err "{p}levelplot incorrectly specified.{p_end}"
				exit
			}
		}
		tempvar D H  n Expec cens ord un_ord hr hrsum D_RR
		g byte `cens' = 1-_d
		bysort `varlist' (_t `cens') : g long `ord' = _n
		g `un_ord' = -`ord'
		sort _t `cens'
		g long `D' = sum(_d)
		if "`adjust'"==""	stcox, estimate basech(`H') efron
		else 			stcox `adjust' , basech(`H') efron
		predict `hr' , hr
		bysort `varlist' (`un_ord') :	g double `hrsum' = sum(`hr')
		bysort `varlist' (`ord') :	g double `Expec' = sum(`H'*`hr') + `H'*`hrsum' - `H'*`hr'
		local i = 1
		foreach l of local levels { 
			tempvar exp`l' obs`l'
			g double `exp`l'' = `Expec' if `varlist'==`l'
			g long `obs`l'' = sum(_d) if `varlist'==`l'
			replace `exp`l'' = 0 if `exp`l''==.
			replace `obs`l'' = 0 if `obs`l''==.
			label var `exp`l'' "`varlist' `l'"
			if "`lpattern'" != "" local lp`i' = word("`lpattern'",`i')
			if "`lpattern'" != "" local lp`i' "lp(`lp`i'')"
			if "`lcolor'" != "" local lc`i' = word("`lcolor'",`i')
			if "`lcolor'" != "" local lc`i' "lc(`lc`i'')"
			if "`lwidth'" != "" local lw`i' = word("`lwidth'",`i')
			if "`lwidth'" != "" local lw`i' "lw(`lw`i'')"
			if "`atobs'"!=""    local ifatobs `"if `obs`l'' < `atobs'"'
			if "`levelplot'" != "" {
				local ckplot : list l & levelplot
				if "`ckplot'" != "" {
					local line `"`line'(line `exp`l'' `obs`l'' `ifatobs', c(L) `lc`i'' `lp`i'' `lw`i'' `options') "'
					local order "`order' `i'"
					local ++i
				}
			}
			else {
				local line `"`line'(line `exp`l'' `obs`l'' `ifatobs', c(L) `lc`i'' `lp`i'' `lw`i'') "'
				local order "`order' `i'"
				local ++i
			}
		}
	}
	cap _estimates unhold `est'
	su `Expec', meanonly
	local dmax = `r(max)'
	if "`atobs'"!="" local dmax = `atobs'
	if `"`legend'"' != "" local legend `"legend(`legend' order(`order'))"'
	else 	local legend "legend(order(`order'))"
	local title `"title("Arjas Plots - `varlist'")"'
	local ytitle `"ytitle("Estimated Cumulative Number of Events")"'
	local xtitle `"xtitle("Cumulative Number of Events")"'
	if `"`xsize'"' == "" local xsize `"xsize(5)"'
	if `"`ysize'"' == "" local ysize `"ysize(5)"'
	g `D_RR' = `D' * exp(ln(1/`rrglance')/2)
	twoway	`line' `plot' ///
		(line `D_RR' `D' if `D'<=`dmax', c(l) lc(black) lp(shortdash)) , ///
		 `title' `ytitle' `xtitle' `legend' `saving' `scheme' `ysize' `xsize' `options'
end
exit
