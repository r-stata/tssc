*! version 1.0 August 29, 2011 @ 09:21:45 UK
*! Correlation metric for cross-sample comparisons with non-linear prob. models

* 0.1. First serious sketch
* 0.2. Syntaxes 1 and 2
* 0.3. Remove -nlcom- and calculate SE in Mata
* 0.4. R2 Bug. Fixed. New way to handle weights
* 0.5. R2 Bug, revisited. 
* 0.6. Implementation of Option altout
* 0.7. Changed header in output
* 0.8. Weights not used in stand-alone version -> fixed
* 0.9. New suboption subpop to over(). Bug in column "sig" -> fixed
* 1.0. Bug in column "sig" with -basecategory- not empty -> fixed

// Main Program to call _nlcorr with/without over option
// -----------------------------------------------------

program nlcorr
version 11.1

	// Parsing
	syntax [anything] [if] [in] [aweight fweight pweight]  /// 
	  [, Over(string) Basecategory(string) Altout clear ]
	gettoken model anything:anything
	gettoken Y X:anything

	// No altout with basecategory
	if "`altout'" != "" & "`basecategory'" != "" {
		display as txt "Note: Alternative Output ignored with option basecategory()"
	}

	// Over Option
	if "`over'" != "" {
		_nlcorr_parseover `over'
		local over `r(overvar)'
		local subpop `r(subpop)'
		if "`weight'" != "pweight" & "`subpop'" != "" {
			di as txt "subpop ignored without pweights"
			macro drop _subpop
		}
	}
	
	// Listwise deletion
	marksample touse
	markout `touse' `Y' `X' `over', strok // strok = string ok
	if "`clear'" == "" preserve
	else if "`clear'" != "" & "`over'" == "" {
		di as text "Note: Option clear has no effect without option over"
		preserve
	}
	quietly keep if `touse'

	// Branch Syntax Styles
	if "`anything'" == "" _NLCORR_POST `altout' 
	else _NLCORR_OVER `Y' `X' [`weight'`exp'], model(`model') over(`over') ///
		  `subpop' `clear' `altout' basecategory(`basecategory')
		
end

// Syntax 1
// --------

program _NLCORR_POST, eclass

	if "`e(cmd)'" == "" {
		di as error "Last estimates not found"
		exit 301
	}

	tempname V SE Z P results

	// Calculate correlations
	if "`e(wexp)'" != "" local myweight myweight([`e(wtype)'`e(wexp)'])
	quietly _nlcorr if e(sample), post `myweight'

	// Normal output
	if "`1'" == "" {
		matrix `results' = _R \ _FR \ _SE \ _Z \ _P
		
		// Set row/columnames
		matrix rownames `results' = Corr Fisher Std_Err z sig
		local covariates: colnames(_R)
		matrix colnames `results'  = `covariates'
		}

	// Alternative output
	else if "`1'" == "altout" {
		matrix `results' = _R \ _FR \ _SE \ _Ratio \ _SD
		
		// Set row/columnames
		matrix rownames `results' = Corr Fisher Std_Err Corr_Ratio StdDev|X
		local covariates: colnames(_R)
		matrix colnames `results'  = `covariates'
		

	}
		
	// Returns
	ereturn matrix nlcorr_R = _R
	ereturn matrix nlcorr_FR = _FR
	ereturn matrix nlcorr_SE = _SE
	ereturn matrix nlcorr_Ratio = _Ratio
	ereturn matrix nlcorr_SD = _SD
	ereturn matrix nlcorr_Z = _Z
	ereturn matrix nlcorr_P = _P
	ereturn scalar r2_L = _R2_L
	
	// Output Header
	di _n "{txt}Correlation metric for {res}`e(cmd)'" ///
	  _col(48) ///
	  "{txt}{ralign 17:Number of obs   =}{res}" ///
	  %10.0f `e(N)' ///
	  _n _col(48) ///
	  "{txt}{ralign 17:LR chi({res}" e(df_m) "{txt})       =}{res}" ///
	  %10.2f `e(chi2)' ///
	  _n _col(48) ///
	  "{txt}{ralign 17:Prob > chi2     =}{res}" ///
	  %10.4f `e(p)' ///
	  _n _col(48) ///
	  "{txt}{ralign 17:Pseudo R2       =}{res}" ///
	  %10.4f `e(r2_p)' ///
	  _n _col(48) ///
	  "{txt}{ralign 17:Latent R2       =}{res}" ///
	  %10.4f `e(r2_L)' ///
	  
	// Table
	local rspec: subinstr local covariates " " " & ", all
	local rspec: list rspec - covariates
	local rspec: subinstr local rspec " " "", all
	
	matrix `results' = `results''
	matlist `results' ///
	  , rowtitle(Variable)  ///
	  cspec(o0& %13s | %10.0g & %10.0g & %10.7f & %10.8g & %10.8g o0&)  ///
	  rspec(--`rspec'-)
end

// Syntax 2
// --------

program define _NLCORR_OVER
	syntax varlist [aweight fweight pweight], ///
	  model(string) over(string) [subpop basecategory(string) altout clear]

	// Check Syntax
	gettoken Y X: varlist
	
	capture confirm numeric variable `over'
	local overisstring = cond(_rc,1,0)

	if "`weight'" != "" local weight myweight([`weight'`exp'])

	quietly levelsof `over', local(K)
	local vallabel: value label `over'
	local varlabel: variable label `over'
	
	// Initialize Loop and Postfile
	unab xnames: `X'
	tempname results SE
	tempfile resfile

	// Numeric over 
	if !`overisstring' {
		postfile `results' str60 `over'str `over' str32 covariate ///
		  double Corr double Fisher double Std_Err double N double Ratio double SD using `resfile'
		
		foreach k of local K {
			
			// Calculate Correlations
			capture _nlcorr `model' if `over' == `k' ///
			  , y(`Y') x(`X') `weight' `subpop'
			if _rc == 2000 {
				display ///
				  `"{txt}Note: `model' has no observations for `over'==`k'"'
			}
			else {
				
				// Store results in Postfile
				local i 1
				foreach name of local xnames {
					
					post `results' ///
					  (`"`:label (`over') `k''"') (`k') (`"`name'"') ///
					  (`=_R[1,`i']') (`=_FR[1,`i']') (`=_SE[1,`i']') (e(N)) ///
					  (`=_Ratio[1,`i']') (`=_SD[1,`i']') 

					local i = `i' + 1
				}
			}
		}
	}
	
	// String over
	else if `overisstring' {
		
		postfile `results' str60 `over' str32 covariate ///
		  double Corr double Fisher double Std_Err double N double Ratio double SD using `resfile'
		
		foreach k of local K {
			
			// Calculate Correlations
			capture _nlcorr `model' if `over' == `"`k'"' ///
			  , y(`Y') x(`X') `weight' `subpop'
			if _rc == 2000 {
				display ///
				  `"{txt}Note: `model' has no observations for `over'==`k'"'
			}
			else {
				
				// Store results in Postfile
				local i 1
				foreach name of local xnames {
					
					post `results' (`"`k'"') (`"`name'"') ///
					  (`=_R[1,`i']') (`=_FR[1,`i']') (`=_SE[1,`i']') (e(N)) ///
					  (`=_Ratio[1,`i']') (`=_SD[1,`i']') 
					
					local i = `i' + 1
				}
			}
		}
	}
	postclose `results'
	
	// Output
	drop _all
	use `resfile'
	capture destring `over', replace
	
	label variable `over' "`varlabel'"
	capture label variable `over'str "`over'"
	label variable covariate "Covariate"
	
	if "`basecategory'" == "" {
		gen double Z = Fisher/Std_Err
		gen double P = normal(-abs(Z))*2

		label variable Corr "Corr"
		label variable Fisher "Fisher"
		label variable Std_Err "Std. Err."
		label variable Z "z"
		label variable P "sig."
		label variable Ratio "Ratio"
		label variable SD "Std. Dev.|X"
		
		local showcolumn = "`=cond("`vallabel'"=="","`over'","`over'str")'"

		if "`altout'" == "" local varout Z P
		else local varout Ratio SD
		
		sort covariate `over'
		tabdisp `showcolumn' ///
		  , cellvar(Corr Fisher Std_Err `varout') ///
		  by(covariate)
		
		if "`clear'" != "" quietly compress
	}
	
	if "`basecategory'" != "" {
		tempvar tagbase
		if `overisstring' gen byte `tagbase' = `over' != "`basecategory'"
		else if !`overisstring' gen byte `tagbase' = `over' != `basecategory'
		bysort covariate (`tagbase' `over'): ///
		  gen double Corr_diff = Corr - Corr[1] 
		by covariate (`tagbase' `over'): ///
		  gen double Fisher_diff = Fisher - Fisher[1] 
		by covariate (`tagbase' `over'): ///
		  gen double Z_diff = Fisher_diff/sqrt(1/(N-3) + 1/(N[1]-2)) 
		by covariate (`tagbase' `over'): ///
		  gen double P_diff = normal(-abs(Z_diff))*2 if _n!=1
		
		label variable Fisher_diff "Fisher Diff."
		label variable Corr_diff "Corr. Diff."
		label variable Z_diff "z"
		label variable P_diff "sig."
		
		local showcolumn = "`=cond("`vallabel'" == "","`over'","`over'str")'"
		
		sort covariate `over'
		tabdisp `showcolumn' ///
		  , cellvar(Corr_diff Fisher_diff Z_diff P_diff) ///
		  by(covariate) missing
		
		if "`clear'" != "" quietly compress
	}
	ereturn clear
end

// Calculate values
// -----------------

program _nlcorr, rclass
	syntax [name(name=model id="model-type")] ///
	  [if] [, y(varname) x(varlist fv) post myweight(string) subpop ] 

	tempvar resid
	tempname MODEST  
	
	marksample touse 

	// Check model
	if "`model'" == "" local model `e(cmd)'
	if inlist("`model'","logit","ologit","mlogit") local MODVAR = (_pi^2)/3
	else if inlist("`model'","probit","oprobit","mprobit") local MODVAR = 1
	else {
		di as error `"Model type "`model'" not allowed"'
		exit 198
	}
	
	// Estimate model for syntax 2
	if "`post'" == "" {
		if "`subpop'" == "" `model' `y' `x' `myweight' if `touse'
		else {
			svyset `myweight'
			svy, subpop(`touse'): `model' `y' `x'
		}
	}
		
	// List of model covariates
	local covarlist: colnames e(b)
	local covarlist: subinstr local covarlist "_cons" "", all
	local covarlist: list uniq covarlist 
	foreach name of local covarlist {
		if strpos("`name'",".") == 0 {
			local xnames `xnames' `name'
			local rownames `rownames' `name'
		}
		else {
			if strpos(`"`name'"',`"#"') > 0 {
				di as error "Interaction expansion not allowed for nlcorr"
				exit 198
			}
			gettoken value variable:name, parse(".")
			capture confirm number `value'
			if !_rc {
				local variable: subinstr local variable "." ""
				tempvar `variable'`value'
				gen byte ``variable'`value'' = `variable'==`value'
				local xnames `xnames' ``variable'`value''
				local rownames `rownames' `name'
			}
		}
	}
	
	// Variance/Covariance matrix for variables in model
	estimates store `MODEST'
	matrix accum _V0 = `xnames' `myweight' if `touse', deviations noconstant
	matrix _V0 = _V0/(r(N)-1)
	
	// Variances of residuals of each X on all others
	local i 1
	foreach var of local xnames {

		local controls: list xnames - var
		if "`subpop'"== "" regress `var' `controls' `myweight' if `touse'
		else svy, subpop(`touse'): regress `var' `controls'
		predict double `resid' if `touse', resid
		if "`subpop'"== "" mean `resid' `myweight' if `touse'
		else svy, subpop(`touse'): mean `resid' 
		estat sd

		if `i' == 1 matrix _V1 = r(variance)
		else matrix _V1 = _V1, r(variance) 
		drop `resid'
		local i 0
	}
	
	// R, FR, and R2_L
	estimates restore `MODEST'
	local N = r(N)

	mata: nlcorr((`MODVAR'))

	matrix drop _V0
	matrix drop _V1

	matrix colnames _R = `rownames'
	matrix colnames _FR = `rownames'
	matrix colnames _SE = `rownames'
	matrix colnames _Ratio = `rownames'
	matrix colnames _SD = `rownames'
	matrix colnames _Z = `rownames'
	matrix colnames _P = `rownames'
	
	return scalar N = `N'
end


// Parse Over-Option
program _nlcorr_parseover, rclass
	syntax varname [, subpop]

	return local overvar `varlist'
	return local subpop `subpop'
end






exit



