*! version 2.13 Januar 15, 2019 @ 17:36:51 UK
*! Decomposing total effects using the KHB method 
*! Support: ukohler@uni-potsdam.de

* 1.0: New name (was dlp). First version sent to SSC
* 1.1: Percentage of total added to disentangle table
* 1.2: - Disentangle not worked varlist appreviations -> fixed
*      - New way to set vcetype
*      . Option -keep-
* 1.3: -mlogit, outcome()- not worked with labeled depvar -> fixed
* 1.4: Add facility to cooperate with -bootstrap- and -permute-
* 1.5: Naming conventions changed to full, reduced, difference
* 2.0: New standard errors, Move things to Mata
* 2.1: Bug fix regarding suest
* 2.2: vce(clustervar) did not work. Fixed
* 2.3: Option or implemented
* 2.4: Bug with Option -keep-; Fixed. Bug with option Concomittant. Fixed
* 2.5: Erase SE from when user specified -ape-
* 2.6: Allow xtlogit/xtprobit: factor variables for Z variables
* 2.7: Backport to Stata 11 (No Factor variables for Z in Stata 11)
* 2.8: Interactions in Z-Vars not used -> work in progress
* 2.9: Option outcome not used for slogit -> fixed
* 2.10: Option -continuous- not used. -> fixed
* 2.11: S.E. incorrect with option -concomittant()- -> fixed
* 2.12: Changes names of residuals stored with -khb ..., keep-
* 2.13: Version 2.12 accidently outcommented a line. -> fixed

// Caller Program
// ==============

program khb, eclass

local caller = c(version)

version 11
	
	// Low level parsing
	// -----------------
	
	syntax [anything] [if] [in] [aweight fweight pweight] 		/// 
	  [, Concomitant(varlist fv) Summary ape Disentangle  ///
	  vce(string) Verbose Keep or ///
	  continuous NOTable OUTcome(string) XStandard ZStandard nopost *]

	// Clean -permute-/-bootstrap- generated call
	local anything: subinstr local anything ") (" " || ", all
	local anything: subinstr local anything "(" "", all
	local anything: subinstr local anything ")" "", all

	gettoken model anything:anything
	gettoken Y anything:anything
	gettoken X Z: anything, parse("||")
	local Z: subinstr local Z "||" ""
	fvunab Z: `Z'
	local method = cond("`ape'"=="","KHB","APE")

	// Check for input errors
	// ----------------------

	if strpos(`"`X'"',`"|"') > 0 {
		di as error 					/// 
		  `"Key variable of interest not specified;"' 	/// 
		  `" check position of "||"."'
		exit 198
	}

	if `"`Z'"' == "" {
		di as error 					/// 
		  `"No mediator specified (Use "||" to separate mediators"' ///
		  `" from variables to be decomposed)"'
		exit 198
	}

	if "`model'" == "rologit" & "`ape'" != "" {
		di as error "Option ape not allowed for rologit"
		exit 198
	}

	if "`weight'"!="" {
		local wexp [`weight'`exp']
		local aweight [aweight`exp']
	}

	marksample touse
	markout `touse' `Y' `X' `Z' `concomitant'

	if "`keep'" !="" {
		capture drop _khb_res*
		capture drop __KHB_ID_
		gen long __KHB_ID_ = _n
		tempfile keep
	}
	preserve
	quietly keep if `touse'

	// Remove Z if constant
	// --------------------

	foreach var of local Z {
		sum `var', meanonly
		if r(min) == r(max) {
			di as text `"Note: `var' is a constant in estimation sample; not used"'
			local remove `var'
		}
	}
	local Z: list Z - remove

	// Standardize
	// -----------

	if `"`xstandard'"' == `"xstandard"' _KHB_Std `X', weight(`aweight')
	if `"`zstandard'"' == `"zstandard"' _KHB_Std `Z', weight(`aweight')

	// SUREG or SUEST?
	if "`weight'" == "pweight" local suest suest
	if "`suest'" == "" & "`vce'" != "" local suest suest
	if "`suest'" == "" {
		foreach var of local Z {
			capture assert `var' == 0 | `var'==1 if !mi(`var')
			if !_rc local suest suest
		}
	}
	
	// Subprogram calling
	// ------------------

	// Main table
	_KHB `model', y(`Y') x(`X') z(`Z') method(`method')	/// 
	  c(`concomitant') `summary' `disentangle' vce(`vce') `notable'     ///
	  outcome(`outcome') `continuous' `options' `verbose' keep(`keep') 	/// 
	  weight(`wexp') `suest' `or' caller(`caller')

	tempname khb
	estimates store `khb'
	restore
	quietly estimates restore `khb'
	ereturn repost, esample(`touse')

	if "`keep'" != "" {
		merge 1:1 __KHB_ID_ using `keep', nogenerate assert(1 3) noreport
		drop __KHB_ID_
	}

end

// Karlson/Holm/Breen Method
// =========================

program _KHB, eclass
	syntax anything, y(varlist) x(varlist fv) z(varlist fv) method(string) /// 
	  [c(varlist fv) summary vce(string) NOTable continuous outcome(string) ///
     verbose weight(string) aweight(string) keep(string) disentangle suest ///
     or caller(string) *]

	local nofz: word count `z'

	if "`verbose'" != "" local verbose noisily
	
	unabcmd `anything'
	local model `r(cmd)'

	local typ1 regress rologit
	local typ2 logit ologit probit oprobit scobit cloglog clogit  /// 
	  xtlogit xtprobit
	local typ3 mlogit slogit 
	local typ4 slogit // Temporarily turn off

	if `: list posof "`model'" in typ1' > 0 local typ 1
	if `: list posof "`model'" in typ2' > 0 local typ 2
	if `: list posof "`model'" in typ3' > 0 local typ 3
	if `: list posof "`model'" in typ4' > 0 local typ 4

	if "`typ'" == "" {
		di "{txt} Note: `model' not supported. Output is experimental"
		local typ 2
	}


	quietly {

		// Helper-Regression
		// -----------------

		local zspec `z'
		if `caller' > 11.2 {
			foreach token of local z {
				local stubname: subinstr local token "." "_", all
				local stubname: subinstr local stubname "#" "_", all
				fvrevar `token', stub(_`stubname')
				if `"`r(varlist)'"' != `"`token'"' {
					local factor `r(varlist)'
					gettoken first rest: factor
					if "`rest'"=="" local zexp `zexp' `first'
					else local zexp `zexp' `: list clean rest'
				}
				else local zexp `zexp' `token'
			}
			local z `zexp'
		}
		else if `caller' < 12 {
			capture confirm numeric variable `z'
			if _rc == 101 {
				display as error 	/// 
				  "Factor variables for z-vars not allowed for Stata 11"
				exit 101
			}
		}
				
		// Sureg or suest?
		if "`suest'" == "" {
			sureg `z' = `x' `c' `weight'
			
			// Store Residuals (for rescaling factor)
			foreach var of local z {
				tempname e`var'
				predict `e`var'', resid equation(`var')
				local elist `elist' `e`var''
				char `e`var''[khbres] `var'
			}
		}

		else {
			if "`weight'" != "" | `=strpos("`vce'","cluster")' {
				if `=strpos("`vce'","cluster")' ///
				  gettoken cluster clustervar: vce
				svyset `clustervar' `weight'
				local svy "svy:"
			}

		
			foreach var of local z {
				`svy' reg `var' `x' `c'
				
				tempname e`var'
				predict `e`var'', resid 
				local elist `elist' `e`var''
				char `e`var''[khbres] `var'
				estimates store e`var'
				local models `models' e`var'
			}
			suest `models', `=cond("`svy'"!="","svy","")'
		}
		
		// Keep results for Mata
		matrix _SURb = e(b)
		matrix list _SURb
		matrix _SURcov = e(V)

		// Full Model
		// ----------

		// The model
		`verbose' `model' `y' `x' `z' `c' `weight', vce(`vce') `options'

		// Store features for ereturn
		local vcetype = cond("`=e(vcetype)'"!=".","`=e(vcetype)'","")

		if "`model'" == "mlogit"  {
			local eqnames `e(eqnames)'
			local basename: word `e(k_eq_model_skip)' of `eqnames'
			local removed: list eqnames - basename
			local mlogitY: word 1 of `removed'
			local outcome = cond("`outcome'"=="","`mlogitY'","`outcome'")
			local predict predict(outcome(`outcome'))
			local base = e(baseout)
		}

		if "`model'" == "ologit" | "`model'" == "oprobit"  | "`model'" == "slogit" {
			local predict predict(outcome(`outcome'))
		}
		
		local r2full = cond("`model'"=="regress",e(r2),e(r2_p))
		local N = e(N)

		// Option APE
		if "`method'"=="APE" margins, dydx(*) post  ///
		  `continuous' `predict'

		// Store results
		matrix _FULLb = e(b)
		matrix _FULLcov = e(V)

		if "`method'" == "KHB" & "`model'"=="mlogit" {
			matrix _FULLb = _FULLb[1,"`outcome':"]
			matrix _FULLcov = _FULLcov["`outcome':"1,"`outcome':"]
		}

		// Reduced model
		// -------------
		
		`verbose' `model' `y' `x' `elist' `c' `weight', vce(`vce') `options'

		// Option APE
		if "`method'"=="APE" margins, dydx(*) post ///
		  `continuous' `predict'

		matrix _REDUCEDb = e(b)
		matrix _REDUCEDcov = e(V)

		if "`method'" == "KHB" & "`model'"=="mlogit" {
			matrix _REDUCEDb = _REDUCEDb[1,"`outcome':"]
			matrix _REDUCEDcov = _REDUCEDcov["`outcome':","`outcome':"]
		}

*DEBUG		noisily matrix list _REDUCEDcov
		
		
		// Call Mata Function
		// -------------------

		// Coef names of Concommitant
		if "`c'" != "" {
			reg `y' `c'
			local Cnames: colnames e(b)
		}

		// Coefnames in Helper Regresson
		local SURxnames: colnames _SURb
		local SURxnames: list uniq SURxnames
		local SURxnames: list SURxnames - Cnames /* 2.13: brought back in this line */
		local SURxnames: subinstr local SURxnames " _cons" "", all
		local SURxnames: subinstr local SURxnames " " `"",""' , all
		
		// Z variables
		local FULLznames: subinstr local z " " `"",""' , all
		
		// Coefnames of Full model
		local FULLxnames: colnames _FULLb
		local FULLxnames: list FULLxnames - z
		local FULLxnames: list FULLxnames  - Cnames 
		local FULLxnames: subinstr local FULLxnames " _cons" "", all
		local FULLxnames: subinstr local FULLxnames " " `"",""' , all
		
		// Call it
		noi mata: khb(("`SURxnames'"),("`FULLznames'"),("`FULLxnames'"),("`method'"))
		
		// Calculate Summary table
		// ----------------------
		
		if "`summary'"!="" {
			
			// Naive total effects
			// --------------------
			
			`model' `y' `x' `c' `weight', vce(`vce') `options'
			
			// Store for ereturn
			local r2naive = e(r2_p)
			
			// Option APE
			if "`method'"=="APE" margins, dydx(*) post ///
			  `continuous' `predict'
			
			matrix _NAIVEb = e(b)
			matrix _NAIVEcov = e(V)
			
			if "`method'" == "KHB" & "`model'"=="mlogit" {
				matrix _NAIVEb = _NAIVEb[1,"`outcome':"]
				matrix _NAIVEcov = _NAIVEcov["`outcome':","`outcome':"]
			}
			
			local NAIVExnames: colnames _NAIVEb
			local NAIVExnames: list NAIVExnames - Cnames
			local NAIVExnames: subinstr local NAIVExnames " _cons" "", all
			local NAIVExnames: subinstr local NAIVExnames " " `"",""' , all
			noi mata: khb_summary(("`NAIVExnames'"))
		}

		// Disentangle table
		// -------------------

		if "`disentangle'" != ""  {

			noi mata: khb_disentangle(("`FULLznames'"),("`FULLxnames'"))
		}
	}
	
	// Output
	// ------

	if "`model'" == "regress" local title "{res}Linear Probability Models"
	else local title "the {res}`method'{txt}-Method"

	if "`model'" == "regress" local fit "R-squared"
	else local fit "Pseudo R2"
	
	// Header
	di _n `"{txt}Decomposition using `title'"'
	di _n `"{txt}Model-Type: {res} `model'{txt}"' ///
	  _col(52)`"Number of obs     ={res}"' %8.0f `N'
	di `"{txt}Variables of Interest:{res} `x'{txt}"'  /// 
	  _col(52) `"{txt}`fit'         ={res}"' %8.2f `r2full'
	di `"{txt}Z-variable(s):{res} `zspec'"' 	
	if "`c'" != "" di `"{txt}Concomitant:{res} `c'"'
	if "`model'" == "mlogit" di "{txt}Results for outcome {res}`outcome'" ///
	  `"{txt} and base outcome {res}`basename'"'

	// Table of coefficients
	if "`or'" != "" local eform eform(or)
	ereturn post _b _V, esample(`touse') obs(`N') depname(`y') 
	ereturn local vcetype `vcetype'
	if "`notable'" == "" {
		ereturn display, `eform'
		if "`method'" == "APE" display 		/// 
		  "{txt} Note: Standard errors of difference not known" ///
		  " for APE method"
	}

	// Summary table
	if "`summary'" != "" {
		local rescaletitle 				/// 
		  = cond("`method'"=="KHB","Resc_Fact","Dist_Sens")

		local rspec
		forv i = 2/`=rowsof(_SUMMARY)' {
			local rspec `rspec'&
		}
		
		// Display table
		matrix colnames _SUMMARY = Conf_ratio Conf_Pct `rescaletitle'
		matlist _SUMMARY ///
		  , rowtitle(Variable) title(Summary of confounding) ///
		  cspec(o4& %12s | %10.0g & %10.2f & %10.0g o2&)  ///
		  rspec(&-`rspec'-)

		ereturn matrix Naive_b _NAIVEb
		ereturn matrix Naive_V _NAIVEcov

		// Ereturn Info in Summary as scalar
		local rownames: rownames _SUMMARY
		local i 1
		foreach row of local rownames {
			local row: subinstr local row "." "_"
			local rescale = cond("`method'"=="KHB","rescale","distsens")
			ereturn scalar ratio_`row' = _SUMMARY[`i',1]
			ereturn scalar pct_`row' = _SUMMARY[`i',2]
			ereturn scalar `rescale'_`row' = _SUMMARY[`i++',3]
		}
		matrix drop _SUMMARY
	}


	// Disentangle table
	if "`disentangle'" != "" {

		local rspec
		forv i = 2/`=rowsof(_DISENTANGLE)' {
			local rspec `rspec'&
		}
		
		// Display table
		matlist _DISENTANGLE ///
		  , rowtitle(Z-Variable) title(Components of Difference) ///
		  cspec(o4& %12s | %9.0g & %9.0g & %9.2f & %9.2f o2&)  ///
		  rspec(&-`rspec'-)

		ereturn matrix disentangle _DISENTANGLE
	}


	// Nonstandard Returns
	// -------------------
	
	ereturn local cmd khb
	ereturn local model `model'
	ereturn local method `method'
	ereturn local depvar `y'
	ereturn local key_vars `x'
	ereturn local mediator_vars `z'
	if "`c'" !="" local concomitant_vars `c'
	ereturn local title Decomposition
	ereturn local vce `vcetype'
	ereturn matrix Reduced_V _REDUCEDcov
	ereturn matrix Reduced_b _REDUCEDb
	ereturn matrix Full_V _FULLcov
	ereturn matrix Full_b _FULLb
	ereturn matrix SUR_V _SURcov
	ereturn matrix SUR_b _SURb
	ereturn matrix Diff_V _Vdiff

	// Keep residuals
	// --------------
	local i 1
	if "`keep'" != "" {
		
		capture drop _khb_res*
		foreach var of varlist `elist' {
			local name ``var'[khbres]'

			ren `var' _khb_res_`name'
		}
		keep __KHB_ID_ _khb_res*
		quietly save `keep'
	}

end

// Subprogram for standardization
// ==============================

program _KHB_Std
	syntax varlist(fv) [, weight(string)]
	if strpos("`varlist'",".") > 0 {
		di as error "Factor variables not allowed with option xstandard"
		exit 198
	}
	tempvar z
	foreach var of local varlist {
		quietly {
			sum `var' `weight'
			gen double z = (`var' - r(mean))/r(sd)
			drop `var'
			ren z `var'
		}
	}
end

exit

