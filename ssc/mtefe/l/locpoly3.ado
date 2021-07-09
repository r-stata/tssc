*! locpoly3 v1.8 30apr2018
* Author: Martin Eckhoff Andresen. 
* This program slightly modifies locpoly2 (Brave & Walstrum) by allowing frequency and probability weights, which in turn builds on the original locpoly by Roberto G. Gutierrez, Jean Marie Linhart and Jeffrey S. Pitblado.
* This program is part of the mtefe package

{
program locpoly3, rclass sortpreserve
	version 8

	syntax varlist(min=2 max=2 numeric)	///
		[if] [in] [fweight pweight] [,		///
		noGraph				///
		noScatter			///
		GENerate(string)	///
		AT(varname)			///
		N(integer 50)		///
		Degree(integer 0)	///
		Width(real 0.0)		///
		BIweight			///
		COSine				///
		EPanechnikov		///
		GAUssian			///	
		PARzen				///
		RECtangle			///
		TRIangle			///
	]

	local kernel `biweight' `cosine' `epanechnikov' `gaussian'  ///
		     `parzen' `rectangle' `triangle' 
	local k : word count `kernel'
	if `k'  > 1 {
		display as error "Only one kernel may be specified."
		exit 198
	}
	if `k' == 0 {
		local kernel epanechnikov
	}

	tokenize `generate'	
	local k : word count `generate'
	if `k' { 
		if `k' == 1 {
			if "`at'" == "" {
				display as error "Option at() must be specified for generate() " _continue
				display as error "to work with two variables."
				error 198
			}
			confirm new variable `1'
			local xname `"`at'"'
			local yname `"`1'"'
			*Number of variables to generate.
			local nsave 1
		}
		else {
			if "`at'" != "" {
				confirm new variable `1'	
				local xname `"`at'"'
				local yname `"`1'"'
				local start 2
				local nsave 1
			}
			else {
				confirm new variable `1'	
				confirm new variable `2'
				local xname `"`1'"'
				local yname `"`2'"'
				local start 3
				local nsave 2
				local noAt  + 1
			}
			*Degree number.
			local deg 1
			*Number of derivatives to generate.
			local dsave 0
			*Get names of derivate variables to generate and count them.
			forvalues i = `start'(1)`k' {
				confirm new variable ``i''
				local dname`deg' `"``i''"'
				local deg   = `deg'   + 1
				local nsave = `nsave' + 1
				local dsave = `dsave' + 1
			}
			if (`k') > (`degree' + 1 `noAt') {
				display as text "Note: more variables specified in generate()" _continue
				display as text "than needed to return all degree coefficients."
				display as text "Extra variable names will be ignored."
				local nsave = `degree' + 1 `noAt'
				local dsave = `degree'
			}
		}
	}
	else {
		local dsave 0
	}

	marksample touse

	tokenize `varlist'
	local y `1'
	local x `2'

	local bw = `width'
	if `bw' <= 0.0 {
		quietly summarize `x' if `touse', detail
		local bw = min( r(sd), (r(p75)-r(p25))/1.349 )
		if `bw' <= 0.0 {
			local bw = r(sd)
		}
		local bw = 0.9*`bw'/(r(N)^.20)
	}

	tempvar xgrid yhat
	quietly generate double `xgrid' = .
	quietly generate double `yhat'  = .
	
	*Generate derivative variables.
	if `dsave' > 0 {
		forvalues i = 1(1)`dsave' {
			tempvar d`i'yhat
			quietly generate double `d`i'yhat' = .
			local dnames `dnames' `d`i'yhat'
		}
	}

	if `"`at'"' != `""' {
		qui count if `at' < .
		local n = r(N)
		qui replace `xgrid' = `at'
		tempvar obssrt
		gen `obssrt' = _n	
		sort `xgrid' `obssrt'	
	}

	else {
		if `n' <= 1 {
			local n = 50
		}
		if `n' > _N {
			local n = _N
			noi di in gr "(n() set to " `n' ")"
		}
		qui summ `x' if `touse'
		tempname delta
		scalar `delta' = (r(max)-r(min))/(`n'-1)
		qui replace `xgrid' = r(min)+(_n-1)*`delta' in 1/`n'
	}
	
	Lpwork `y' `x' if `touse' [`weight'`exp'], xgrid(`xgrid') yhat(`yhat') dnames(`dnames') ///
		n(`n') h(`bw') p(`degree') k(`kernel')		
	

	qui count if `yhat' < . 
	local ngrid = r(N)

	/* Graph (if required) */
	if "`graph'" == "" { 
		local title title("Local polynomial smooth")
		local subttl1 subtitle(`"Degree: `degree'"')
		local yttl : var label `y'
		if `"`yttl'"' == "" {
			local yttl `y'
		}
		local xttl : var label `x'
		if `"`xttl'"' == "" {
			local xttl `x'
		}
		label var `yhat' "locpoly smooth: `yttl'"
		local titles			///
			`title'				///
			`subttl1'			///
			// blank

		if "`scatter'" == "" {
			local scat (scatter `y' `x' if `touse')
		}
		graph twoway			///
		`scat'					///
		(line `yhat' `xgrid',	///
			lcolor(maroon)		///
			lwidth(medium)		///
			lpattern(solid)		///
			connect(direct)		///
			cmissing(n)			///
			sort				///
			pstyle(p1)			///
			`titles'			///
			ytitle(`"`yttl'"')	///	
			xtitle(`"`xttl'"') 	///
			`rlopts'			///
			`twopts'			///
			`options'			///
		)						///
		|| `plot'				///
		// blank
	}
	
	ret local kernel `"`kernel'"'
	ret scalar width = `bw'
	ret scalar ngrid = `ngrid'
	ret scalar degree = `degree'
		
	if `"`nsave'"' != "" {
		if "`at'" == "" {
			rename `xgrid' `xname'
			label variable `xname' `"locpoly smoothing grid"'
		}
		label variable `yhat' `"locpoly smooth: `y'"'
		rename `yhat' `yname'
		if "`dsave'" != "" {
			forvalues i = 1(1)`dsave' {
				label variable `d`i'yhat' `"locpoly derivative `i' of `y'"'
				rename `d`i'yhat' `dname`i''
			}
		}
	}
end
}

*Program Lpwork
{
program Lpwork
	syntax varlist(min=2 max=2 numeric)	///
		[if] [fweight pweight/],				///
		xgrid(varname) 					///
		yhat(varname)					///
		n(integer)						///
		[ p(integer 0)					///
		h(real 0.0)						///
		k(string)						///
		dnames(string) ]

	tokenize `varlist'	
	local y `1'
	local x `2'

	marksample touse
	
	tempvar arg karg
	forvalues j = 1/`p' {
		tempvar x`j'
		quietly generate double `x`j'' = .
		local xs `xs' `x`j''
	}
	quietly generate double `arg'  = .
	quietly generate double `karg' = .
	
	forvalues i = 1/`n' {
		quietly replace `arg' = (`x' - `xgrid'[`i'])/`h' if `touse'
		GetK `arg' `karg' `k' `touse' `exp'
		forvalues j = 1/`p' {
			quietly replace `x`j'' = (`h'*`arg')^`j' if `touse'	
		}	
		capture regress `y' `xs' [iw = `karg'] if `touse'
		if !_rc {
			if _b[_cons] < . {
				quietly replace `yhat' = _b[_cons] in `i'
			}
			
			local numDeg : word count `dnames'
			forvalues j = 1(1)`numDeg' {
				if _b[`x`j'']  < . {
					local replace: word `j' of `dnames'
					quietly replace `replace' = exp(lnfactorial(`j')) * _b[`x`j''] in `i'
				}
			}
		}
	}
end
}

*Program GetK.
{
program GetK
	args arg karg kern touse weightvar
	
	if "`weightvar'"=="" {
		loc weightvar=1
		}
	qui replace `karg' = .
	if "`kern'" == "biweight" {
		local con1 = .9375
		qui replace `karg' = `weightvar'*`con1'*(1-(`arg')^2)^2 /* 
			*/ if `touse' & abs(round(`arg',1e-8))<1 
	}
	else if "`kern'" == "cosine" {
		qui replace `karg' = `weightvar'*(1 + cos(2*_pi*`arg')) /*
			*/ if `touse' & abs(round(`arg',1e-8))<0.5	
	}
	else if "`kern'" == "triangle" {
		qui replace `karg' = `weightvar'*(1 - abs(`arg')) /*
			*/ if `touse' & abs(round(`arg',1e-8))<1
	}
	else if "`kern'" == "parzen" {
		local con1 = 4/3
		local con2 = 2*`con1'
		qui replace `karg' = `weightvar'*`con1'-8*`arg'^2 + 8*abs(`arg')^3 /*
			*/ if abs(round(`arg',1e-8))<=0.5 & `touse'
		qui replace `karg' = `weightvar'*`con2'*(1-abs(`arg'))^3 /*
			*/ if abs(round(`arg',1e-8))>.5 & /*
			*/ abs(round(`arg',1e-8))<1 & `touse'	
	}
	else if "`kern'" == "gaussian" {
		local con1 = sqrt(2*_pi)
		qui replace `karg' = `weightvar'*exp(-0.5*((`arg')^2))/`con1' if `touse'
	}
	else if "`kern'" == "rectangle" {
		qui replace `karg' = `weightvar'*0.5 if abs(round(`arg',1e-8))<1 & `touse'
	}
	else { 				// epanechnikov
		local con1 = 3/(4*sqrt(5))
		local con2 = sqrt(5)
		qui replace `karg' = `weightvar'*`con1'*(1-((`arg')^2/5)) /*
			*/ if abs(round(`arg',1e-8)) <= `con2' & `touse'	
	}
end
}
