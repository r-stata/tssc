*! 1.0.0 NJC 14 December 2006
program pinvgauss, sort
	version 9
	syntax varname [fweight aweight/] [if] [in] ///
	[, Grid GENerate(namelist min=2 max=2) param(numlist max=2 min=2) show(str) * ]
	
	_get_gropts , graphopts(`options') getallowed(RLOPts addplot)
	local options `"`s(graphopts)'"'
	local rlopts `"`s(rlopts)'"'
	local addplot `"`s(addplot)'"'
	_check4gropts rlopts, opt(`rlopts')

	quietly { 
		if "`generate'" != "" { 
			capture confirm new var `generate' 
			if _rc { 
				di as err "generate() must name new variables"
				exit 198 
			}
		}

		marksample touse
		local y "`varlist'" 
		count if `y' <= 0 & `touse'
		if r(N) {
			noi di as txt "{p}warning: {res:`y'} has `r(N)' values <= 0;" ///
			" not used in calculations{p_end}"
		}
		replace `touse' = 0 if `y' <= 0
		count if `touse' 
		if r(N) == 0 error 2000 

		if `"`show'"' != ""  { 
			capture count if `show' 
			if _rc { 
				di as err "invalid show() option"
				exit 198 
			} 
			else { 
				count if (`show') & `touse' 
				if r(N) == 0 error 2000 
			}
		
			local show "& (`show')" 
		} 

		if "`param'" != "" { 
			tokenize `param' 
			args mu lambda 
			if `mu' <= 0 | `lambda' <= 0 { 
				di as err "parameters must be positive"
				exit 498 
			}	
		} 	
		else {
			if "`weight'" != "" { 
				invgausscf `y' if `touse' [`weight' = `exp'] 
			}	
			else invgausscf `y' if `touse'
			local mu = r(mu) 
			local lambda = r(lambda) 
		} 

		tempvar F Psubi
		if "`exp'" == "" local exp = 1 

		sort `touse' `varlist'
		gen float `Psubi' = sum(`touse' * `exp') - 0.5 * `exp' 
		su `touse' [w = `exp'], meanonly 
		replace `Psubi' = `Psubi' / r(sum) if `touse' 
		mata : invgaussvar(`mu', `lambda', "`y'", "`touse'", "`F'") 
	}
	
	local yttl "inverse Gaussian F[`varlist']"
	label var `F' "`yttl'"
	local xttl "Empirical P[i]"
	format `F' `Psubi' %9.2f
	if `"`plot'`addplot'"' == "" local legend legend(nodraw)
	
	graph twoway		        	///
	(scatter `F' `Psubi' if `touse' `show', ///
		sort				///
		ylabel(0(.25)1, nogrid `grid')	///
		xlabel(0(.25)1, nogrid `grid')	///
		ytitle(`"`yttl'"')		///
		xtitle(`"`xttl'"')		///
		`legend'			///
		`options'			///
	)					///
	(function y=x if `touse' `show',	///
		clstyle(refline)		///
		range(`Psubi')			///
		n(2)				///
		yvarlabel("Reference")		///
		`rlopts'			///
	)					///
	|| `addplot' 
	// blank

	// user will see messages about missing values 
	if "`generate'" != "" { 
		tokenize `generate' 
		gen `1' = `F' if `touse' 
		label var `1' "inverse Gaussian probabilities" 
		gen `2' = `Psubi' if `touse' 
		label var `2' "empirical probabilities" 
	}	
end

// NJC 10 December 2006

mata : 

// variable = F(y | mu, lambda)
void invgaussvar(real scalar mu, 
	      real scalar lambda, 
	      string scalar varname, 
	      string scalar tousename,
	      string scalar distname) 
{ 
	real colvector y, dist 
	y = st_data(., varname, tousename) 
	dist = sqrt(lambda :/ y) 
	dist = normal(dist :* (y :/ mu :- 1)) + 
		exp(2 * lambda / mu) :* normal(-dist :* (y :/ mu :+ 1))
	st_addvar("double", distname)
	st_store(., distname, tousename, dist) 
}

end 
