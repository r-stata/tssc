*! 2.1.0 NJC 1 November 2004
* 2.0.0 NJC 27 February 2003
* 1.1.1 NJC 26 July 2002
* 1.1.0 NJC 11 June 2002
* 1.0.0 NJC 5 June 2002
program ofrtplot
	version 8
	syntax [varname(ts def=none)]                 ///
	[ , SOrt SUPER combine(str asis) ofplot(str asis) rplot(str asis) ///
	plot(str asis) * ]          

	// x variable defaults to time variable 
	if "`varlist'" == "" { 
		qui tsset 
		local varlist "`r(timevar)'" 
	}
	
	// get observed and model results 
	tempvar fit residual
	quietly {
		// observed 
		if "`e(depvar)'" == "" { 
			di as err "estimates not found" 
			exit 301 
		} 
		if `: word count `e(depvar)'' > 1 { 
			di as err "ofrtplot not allowed after `e(cmd)'" 
			exit 498 
		} 	
		local observed "`e(depvar)'" 
 
 		// fitted and residual 
		predict `fit' if e(sample) 
		predict `residual' if e(sample), res
		label var `fit' "Fitted" 
		label var `residual' "Residual" 
	}	

	// draw graph
	if "`super'" != "" { 
		twoway line `observed' `fit' `varlist' if e(sample)     ///
		, yaxis(1 2)                                            ///
		yti("Observed and fitted") ytitle("Residual", axis(2))  ///
		sort `ofplot'                                        || ///  
		spike `residual' `varlist' if e(sample), `rplot' `options'  ///
		|| `plot' 
	}
	else {  
		tempname g1 g2

		local Varlist `varlist' 
		local Options `options' 
		local 0 , `ofplot' 
		syntax [, plot(str asis) *] 
		
		twoway line `observed' `fit' `Varlist' if e(sample)     ///
		, yti("Observed and fitted") clpattern(l "_")           ///
		xti(" ") xsc(noline) xla(, nolabels noticks)            ///  
		legend(position(11)) sort name(`g1') nodraw `Options'   ///
		`options'   ///
		|| `plot' 
		
		local 0 , `rplot' 
		syntax [, plot(str asis) *] 
	
		twoway spike `residual' `Varlist' if e(sample)         ///
		, yti("Residual") sort fysize(30) name(`g2') `xla' nodraw ///
		`Options' `options' ///
		|| `plot' 
		
		graph combine `g1' `g2', cols(1) xcommon imargin(zero) `combine'   
	}	
end 

