*! NJC 1.0.0 29 April 2004 
program circpvm, sort 
	version 8 
	syntax varname [if] [in] [, Grid a(real 0.5) * ]  
	marksample touse
	qui count if `touse' 
	if r(N) == 0 exit 2000
	
	_get_gropts , graphopts(`options') getallowed(rlopts plot)
	local options `"`s(graphopts)'"'
	local rlopts `"`s(rlopts)'"'
	local plot `"`s(plot)'"'
	_check4gropts rlopts, opt(`rlopts')
	
	tempvar centred F Psubi  
	tempname vecmean kappa 
	
	qui circvm `varlist' if `touse' 
	local vecmean = r(vecmean)
	local kappa = r(kappa) 
	local N = r(N) 
	local vtxt : di %2.1f `vecmean' 
	local ktxt : di %4.3f `kappa'
	
	circcentre `varlist' if `touse', gen(`centred') c(`vecmean')
	gsort -`touse' `centred'
	egen `F' = vm(`varlist') if `touse', k(`kappa') m(`vecmean')  
	gen float `Psubi' = (_n - `a') / (`N' - 2 * `a' + 1) if `touse'
	
	local yttl "von Mises F[`varlist' | `vtxt'`=char(176)', `ktxt']"
	label var `F' "von Mises, mu `vtxt'`=char(176)' kappa `ktxt'"
	local xttl "Empirical P[i]"
	format `F' `Psubi' %9.2f
	if `"`plot'"' == "" {
		local legend legend(nodraw)
	}

	twoway (scatter `F' `Psubi',		///
		sort				///
		ylabel(0(.25)1, nogrid `grid')	///
		xlabel(0(.25)1, nogrid `grid')	///
		ytitle(`"`yttl'"')		///
		xtitle(`"`xttl'"')		///
		`legend'			///
		`options'			///
	)					///
	(function y=x,				///
		clstyle(refline)		///
		range(`Psubi')			///
		n(2)				///
		yvarlabel("Reference")		///
		`rlopts'			///
	)					///
	|| `plot'				
	// blank
end 
