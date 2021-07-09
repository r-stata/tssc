*! arrowplot: Combined macro scatter and micro regression plot
*! Version 1.0.0 agosto 18, 2014 @ 00:14:47
*! Author: Damian C. Clarke
*! Department of Economics
*! The University of Oxford
*! damian.clarke@economics.ox.ac.uk

cap program drop arrowplot
program arrowplot, eclass
	vers 10.0

	#delimit ;
	syntax varlist(min=2 max=2) [if] [in] [pweight fweight aweight iweight]
	, GROUPvar(varname)
	[
	  LINEsize(numlist min=0 max=1)
	  groupname(string)
	  CONTrols(varlist fv ts)
	  *
	  regopts(string asis)
	  GENerate(name min=1 max=1)
	]
	;
	#delimit cr
	*=============================================================================
	*=== (0) Error capture
	*=============================================================================
	qui ds `groupvar', not(type string)
	if "`r(varlist)'"=="`groupvar'" {
		local er2 "Please regenerate group names as string prior to running"
		dis as error "Group variable must be a string variable.  `er2'."
		exit 107
	}
	
	*=============================================================================
	*=== (1) set-up temporary variables for line plots and beta estimates
	*=============================================================================
	tempvar intercept x1 x2 y1 y2 delta line
	tempvar my mx miny maxy minx maxx rany ranx scale reX
	qui gen `intercept'=.

	tokenize `varlist'

	if "`groupname'"=="" local groupname "Group"
	*=============================================================================
	*=== (2) Rescale X so size of line will be equal regardless of slope
	*=============================================================================
	qui {
		bys `groupvar': egen `my'=mean(`1')
		bys `groupvar': egen `mx'=mean(`2')
		foreach var in x y {
			egen `min`var''=min(`m`var'')
			egen `max`var''=max(`m`var'')
			gen `ran`var''=`min`var''-`max`var''
		}

		gen `scale'=`rany'/`ranx'
		gen `reX'  = `2'*`scale'
		}
	
	*=============================================================================
	*=== (3) Calculate intra-correlation (conditional upon any controls)
	*=============================================================================
	qui levelsof `groupvar', local(levels)
	foreach c of local levels {
		if "`if'"=="" local ifplus if `groupvar'==`"`c'"'
		else local ifplus `if'&`groupvar'==`"`c'"'

		cap reg `1' `reX' `controls' `ifplus' `in' [`weight' `exp'], `regopts'
		if _rc==0 qui replace `intercept'=_b[`reX'] `ifplus'
	}
	if "`generate'"!="" gen `generate'=`intercept'
	preserve	
	collapse `1' `2' `reX' `scale' `intercept' `if' `in' [`weight' `exp'], by(`groupvar')

	qui sum `1'
	local scaledif = `r(max)'-`r(min)'
	if "`linesize'"=="" local linesize = 0.08*`scaledif'
	*=============================================================================
	*=== (4) Determine start and end point of lines (depends on slope and length)
	*=============================================================================
	gen  `delta'  = sqrt((`linesize'^2)/(`intercept'^2+1))
	gen  `x1'     = `reX'-`delta'
	gen  `x2'     = `reX'+`delta'
	gen  `y1'     = `1'-`delta'*`intercept'
	gen  `y2'     = `1'+`delta'*`intercept'

	gen `line'  = (`y2'-`y1')^2+(`x2'-`x1')^2

	qui replace `x1'=`x1'/`scale'
	qui replace `x2'=`x2'/`scale'
	*=============================================================================
	*=== (5) Plot
	*=============================================================================
	twoway pcarrow `y1' `x1' `y2' `x2' || scatter `1' `2', ///
	  mlabel(`groupvar') mlabsize(vsmall)  `options' ///
	  legend(label(1 "Within `groupname' Variation") label(2 "`groupname' Mean"))
	
	restore
	if "`generate'"!="" replace `generate'=`generate'*`scale'
end
