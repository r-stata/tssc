*! 2.1.1 NJC 11 November 2004 
* 2.1.0 NJC 7 November 2004 
* 2.0.2 NJC 27 Feb 2003 
* 2.0.1 NJC 20 Feb 2003 
* 2.0.0 NJC 14 Feb 2003 
* 1.2.0 NJC 19 Sept 2001 
program regplot
	version 8.0
	syntax [varlist(max=1 numeric default=none ts)]                     ///
	[ , Bands(int 20) plottype(str) SEParate(varname) FITopts(str asis) ///
	BY(str asis) YTItle(str asis) MSymbol(str) SOrt plot(str asis) * ] 

	// initial checking and picking up what -regress- type command 
	// leaves behind

	if "`separate'" != "" & "`plottype'" == "" { 
		local plottype "line" 
	}	

	if "`e(cmd)'" == "anova" { 
		di as err "regplot not allowed after anova" 
		di as txt "recommendation: try " as inp "anovaplot" 
		exit 498 
	}
	
	if "`e(depvar)'" == "" { 
		di as err "estimates not found" 
		exit 301 
	} 

	local ndepvar : word count `e(depvar)' 
	if `ndepvar' > 1 { 
		di as err "regplot not allowed after `e(cmd)'" 
		exit 498 
	} 	

	if "`varlist'" == "" { 
		tempname b 
		mat `b' = e(b) 
		local x : word 1 of `: colnames `b''
		if "`x'" == "_cons" { 
			di as err "model fitted without predictors; no plot" 
			exit 198 
		}	
	} 
	else local x "`varlist'" 

	local y "`e(depvar)'" 

	// get fit 
        tempvar fit
	qui predict `fit' if e(sample)
	
	// set up graph defaults

	if "`msymbol'" == "" local msymbol "oh"
	
	if `"`ytitle'"' == "" { 
		// strip any time series operators
		tsrevar `y', list 
		local y2 "`r(varlist)'" 
		
		// identify the operator 
		if "`y2'" != "`y'" { 
			local op = substr("`y'",1,index("`y'","`y2'")-1)
		}
		
		local what : variable label `y2'

		// put any operator back again 
		local what = cond(`"`what'"' == "", "`y'", "`op'`what'") 
		
		if "`: word 1 of `msymbol''" == "i" { 
			local ytitle `""fit for `what'""' 
		}
		else local ytitle `""data and fit for `what'""' 
	} 

	if "`by'" != "" {
		if index(`"`by'"',",") { 
			local byby "by(`by' legend(off))" 
		}
		else local byby "by(`by', legend(off))" 
	}	

	// separate ? 
	qui if "`separate'" != "" { 
		preserve 

		if "`plottype'" != "" { 
			capture separate `fit', by(`separate') veryshort 
			if _rc capture separate `fit', by(`separate') short 
			if _rc separate `fit', by(`separate') 
			local fit `r(varlist)' 
		} 	

		tempvar Y 
		gen `Y' = `y' 
		capture separate `Y', by(`separate') veryshortlabel 
		if _rc capture separate `Y', by(`separate') shortlabel 
		if _rc separate `Y', by(`separate') 
		local y `r(varlist)' 
		local legend "legend(on)" 
	}
	else local legend "legend(off)" 
	
	if "`plottype'" == "" { 
		twoway scatter `y' `x' if e(sample),                     ///      ///
		yti(`ytitle') ms(`msymbol') `legend' `byby' `options' || ///
		mspline `fit' `x', sort bands(`bands') `fitopts'      || ///
		|| `plot' 
	} 
	else {
		twoway scatter `y' `x' if e(sample),                     ///
		yti(`ytitle') ms(`msymbol') `legend' `byby' `options' || ///
		`plottype' `fit' `x', sort `fitopts'                  || ///
		|| `plot' 
	}	
end

