*Title: drm
*Description: Fits Sobel's DRM model 
*Version: 0.5 (19th November 2018)
*Author: Caspar Kaiser (caspar.kaiser@nuffield.ox.ax.uk)

*==============================*
*1. Wrapper that allows for replay
*==============================*
program drm
	version 12
	if replay()==1 {
		syntax [, Level(integer 95) COEFLegend]				
		if ("`e(cmd)'" != "ml" & "`e(cmd)'" != "nl" ) error 301 // if the previous command was not drm, previous results of drm won't have been saved
		if "`e(cmd)'" == "nl" nl, level(`level') `coeflegend'
		if "`e(cmd)'" == "ml" ml, level(`level') `coeflegend' nocnsreport
	}	
	else {
		Estimate `0'
	}
end

*==============================*
*2. Main routine
*==============================*
program Estimate, eclass
	
	*======================================================
	*2.1 Parsing, checks and setup
	*======================================================
	
	// Drop globals that may have been left over
	cap macro drop DRMCONSTRAIN 
	cap macro drop DRMWGTVAR
	cap macro drop DRMINTERVARS
	cap macro drop DRMSETOFP DRMSETOFQ
	cap macro drop DRMRHO
	cap macro drop DRMBYVAR
	
	// drops constrains if any are left
	cap cons drop _all
	
	// Setup
	syntax varlist(min=3 fv) [aw fw iw pw] [if] [, ///
	vce(string) 		///
	wgt(string)				///
	INTERvars(varlist fv)	///
	ITERate(integer 1000)	///
	tech(string) 			///
	DIFFicult				///
	link(string) 			///
	Level(integer 95)		///
	COEFLegend				///
	OWNConstrains(string)	///
	Sobel					///
	Alternative				///
	CLassic					///
	Nl						///
	by(varlist fv) 			///	
	Constrain				///
	old						///
	KEep]					//
	
	gettoken depvar varlist : varlist
	gettoken rowvar varlist	: varlist
	gettoken colvar controls: varlist
	
	// Marksample
	marksample touse
	markout `touse' `depvar' `rowvar' `colvar' `controls' `by' `intervars' // Listwise deletion
	
	// Check if wgt is correctly specified
	if ("`wgt'" != "") & ("`wgt'" != "cons") & ("`wgt'" != "row") & ("`wgt'" != "col") {
		disp as error "`wgt' is not a valid wgt option. Choose one of: cons, row, col."
		exit		
	}
	
	// Check if link is correctly specified 
	if ("`link'"!="") & ("`link'"!="linear") & ("`link'"!="logit") & ("`link'"!="probit") {
		disp as error "`link' is not a valid link option. Choose one of: linear, logit, probit, or omit link option."
		exit		
	}
	if "`nl'"=="nl" & "`link'"!="" {
		disp as error "May not specify both nl and link()."
		exit	
	}
	
	// Create intervar global
	if "`intervars'" != "" {
		fvrevar `intervars'
		local intervars `r(varlist)'
		_rmcoll `intervars', forcedrop
		local intervars `r(varlist)'
		global DRMINTERVARS `intervars'
	}

	// Check if rowvar and colvar are correctly specified
	qui sum `rowvar' 
	*Is minimum==1?
	if r(min) != 1 {
		disp as error "Minimum of rowvar (`rowvar') and colvar (`colvar') must be 1"
		exit
	}
	*Same number of categories?
	local NROWS = `r(max)'
	qui sum `colvar' 
	local NCOLS = `r(max)'
	if `NROWS' != `NCOLS' { // rowvar and colvar must have same number of levels
		disp as error "Numbers of categories of rowvar (`rowvar') and colvar (`colvar') are not equal."
		exit
	}
	*Consecutive values?
	qui levelsof `rowvar', local(values)
	forvalues i=1/`NROWS' {
		local current: word `i' of `values'
		if "`current'" != "`i'" {
			local error = 1
		}
	}
	qui levelsof `colvar', local(values)
	forvalues i=1/`NCOLS' {
		local current: word `i' of `values'
		if "`current'" != "`i'" {
			local error = 1
		}
	}
	if "`error'"=="1" {
		dis as error "rowvar (`rowvar') and colvar (`colvar') must only contain consecutive values and may not contain gaps"
		exit
	}
	// Check if depvar is binary when link is logit or probit
	if "`link'" == "logit" | "`link'" == "probit" {
		qui levelsof `depvar', local(levels)
		if "`levels'" != "0 1" {
			dis as error "depvar (`depvar') may only be 0 or 1 when using `link'."
			exit
		}
	}
	// If weight is made conditional, set which it is and store in global
	if "`wgt'" == "row" global DRMWGTVAR = "`rowvar'" 
	if "`wgt'" == "col" global DRMWGTVAR = "`colvar'" 
	
	*======================================================
	*2.2 Begin of part specific to nl
	*======================================================
	
	if "`nl'" == "nl" {
		
		*----------------------------------------------------
		*	2.2.1 More setup
		*----------------------------------------------------
		
		// Handle factor variables and drop collinear variables
		fvrevar `controls'
		local controls `r(varlist)'
		_rmcoll `controls', forcedrop
		local controls `r(varlist)'
		
		// Create byvar and set global for byvar
		if "`by'" != "" {
			tempvar byvar
			egen `byvar' = group(`by')
			global DRMBYVAR = "`byvar'"
		}
		
		// Check if p should be explicitly constrained in nl
		if "`constrain'" == "constrain" global DRMCONSTRAIN = "yes"
			
		// Specify parameter names for mu
		if "`by'" != "" {
			qui sum `byvar'
			local NBYVAR = `r(max)'
			forvalues i=1(1)`NBYVAR'{
				forvalues j=1(1)`NROWS'{
					local mu_names "`mu_names' mu_`j'`j'_`i'"
				}
			}
		}
		
		if "`by'" == "" { 
			forvalues i=1(1)`NROWS'{
				local mu_names "`mu_names' mu_`i'`i'"
			}
		}
		
		// If relevant assign rhonames
		if "`intervars'" != "" {
			foreach i of local intervars {
				local rhonames "`rhonames' rho_`i'" 
			}
		}

		*----------------------------------------------------
		*	2.2.2 Run nl
		*----------------------------------------------------
		
		// For constant weights
		if "`wgt'" == "" | "`wgt'" == "cons" { 
		
			if "`constrain'" == "constrain" 	local wgtname = "gamma"
			else 								local wgtname = "p"

			// run routine
			nl drm_constant @ `depvar' `rowvar' `colvar' `controls' [`weight'`exp']  if `touse', parameters(`wgtname' `mu_names' `controls' `rhonames') vce(`vce') iterate(`iterate')  level(`level') `coeflegend'
		
			if "`constrain'" == "constrain" nlcom (p: exp(_b[/gamma]) / ( 1 + exp(_b[/gamma]))) (q: 1 - (exp(_b[/gamma]) / ( 1 + exp(_b[/gamma]))))
		}
		
		// For row or column specific weights
		if "`wgt'" == "row" | "`wgt'" == "col"  { // Row or column weight
			// Specify wgt names
			forvalues i=1(1)`NROWS'{
				if "`constrain'" == "constrain" 	local wgt_names "`wgt_names' gamma_`i'" 
				else 								local wgt_names "`wgt_names' p_`i'"
			}

			// run routine
			nl drm_rowcol @ `depvar' `rowvar' `colvar' `controls' [`weight'`exp'] if `touse' , parameters(`wgt_names' `mu_names' `controls' `rhonames') vce(`vce') iterate(`iterate') level(`level') `coeflegend'
			
			if "`constrain'" == "constrain" {
				forvalues i=1/`NROWS' {
					local to_test_row `to_test_row' (p_`i': exp(_b[/gamma_`i']) / (1+exp(_b[/gamma_`i'])))
					local to_test_col `to_test_col' (q_`i': 1-exp(_b[/gamma_`i']) / (1+exp(_b[/gamma_`i'])))			
				}		
				nlcom `to_test_row' 
				nlcom `to_test_col' 
			}
		}
	}

	*======================================================
	*2.3. Begin of Routine specific to ml
	*======================================================
	if "`nl'" != "nl" {
		
		*----------------------------------------------------
		*	2.3.1 Declare wgt settings if no wgt is specified, correct iterate option, drop previous constrains, initialize NCONSTR, start loop
		*----------------------------------------------------
		
		if "$DRMWGTVAR" == "" {
			local 	pestimate 	= "(p: `depvar' = )"
			local 	qestimate 	= "(q: `depvar' = )"
			global 	DRMSETOFP 	= "p"
			global 	DRMSETOFQ 	= "q"
		}
				
		cons drop _all
		local NCONSTR = 1
		qui sum `rowvar' 
		local NROWS = r(max)
		forvalues i=1/`NROWS' { 
		
			*----------------------------------------------------
			*	2.3.2 Create Row and column dummies and set constraint: mu_ii=mu_jj
			*----------------------------------------------------
				if "`old'" != "old" {
					capture confirm variable _`rowvar'_`i'
					if _rc != 0 {
						qui gen _`rowvar'_`i' = 0
						qui replace _`rowvar'_`i' = 1 if `rowvar' == `i' 
					}
					else local notifydummy = "yes" 
					capture confirm variable _`colvar'_`i'
					if _rc != 0 {
						qui gen  _`colvar'_`i' = 0
						qui replace _`colvar'_`i' = 1 if `colvar' == `i'
					}
					else local notifydummy = "yes" 
					
					local ROWVARS `ROWVARS' _`rowvar'_`i'
					local COLVARS `COLVARS' _`colvar'_`i'

					// Set constraints
					cons def `NCONSTR' [row]_`rowvar'_`i'=[col]_`colvar'_`i'
					local ++NCONSTR
					
					local SUMCONSTR "`SUMCONSTR' [row]_`rowvar'_`i' +"
					local COLCONSTR "`COLCONSTR' [col]_`colvar'_`i' +"
				}
				else {
					tempvar `rowvar'`i'
					tempvar `colvar'`i'
					qui gen ``rowvar'`i'' = 0
					qui replace ``rowvar'`i'' = 1 if `rowvar' == `i' 
					qui gen  ``colvar'`i'' = 0
					qui replace ``colvar'`i'' = 1 if `colvar' == `i'
					
					
					local ROWVARS `ROWVARS' ``rowvar'`i''
					local COLVARS `COLVARS' ``colvar'`i''
			
					cons def `NCONSTR' [row]``rowvar'`i''=[col]``colvar'`i''
					local ++NCONSTR
					
					local SUMCONSTR "`SUMCONSTR' [row]``rowvar'`i'' +"
					local COLCONSTR "`COLCONSTR' [col]``colvar'`i'' +"
				}
				
			*----------------------------------------------------
			*	2.3.3 Set options for p
			*----------------------------------------------------
			if "$DRMWGTVAR" != "" {
				local 	pestimate	= "`pestimate' (p`i': `depvar' = )"
				local 	qestimate	= "`qestimate' (q`i': `depvar' = )"
				global 	DRMSETOFP 	= "$DRMSETOFP p`i'"				
				global 	DRMSETOFQ 	= "$DRMSETOFQ q`i'"
				
			}			
		}
		if "`notifydummy'" == "yes" dis "Note: One or more dummies for rowvar (`rowvar') and colvar (`colvar') already existed and were not newly generated by drm"
	
		*----------------------------------------------------
		*	2.3.4 Set options for rho
		*----------------------------------------------------
		
		if "$DRMINTERVARS" != "" {
			local 	rhoestimate	= "(rho: `depvar' = $DRMINTERVARS, nocons)"
			global 	DRMRHO = "rho"
			local NRHO : list sizeof local intervars
			
			if "`alternative'" != "alternative" & "`classic'" != "classic" {
				forvalues i=1/`NRHO' {
					local rhoinit `rhoinit' 0
				}
			}
		}
		
		*----------------------------------------------------
		*	2.3.5 Find initial values for mu_ii (classic and alternative)
		*----------------------------------------------------
		
		if "`alternative'" == "alternative" | "`classic'" 	== "classic" {
			
			if "$DRMWGTVAR" == "" {
				local 	pinit		= "p:_cons=0.5" 
				local 	qinit		= "q:_cons=0.5" 
			}
			forvalues i=1/`NROWS' { 
				if "$DRMWGTVAR" != "" {
					local 	pinit		= "`pinit' p`i':_cons=0.5" 
					local 	qinit		= "`qinit' q`i':_cons=0.5" 
				}
				qui sum `depvar' if `rowvar'==`i' & `colvar'==`i' & `touse', meanonly
				local MUINIT`i'_temp = r(mean)
				local MUINIT_SUM = "`MUINIT_SUM' `MUINIT`i'_temp' + "
			}
			
			forvalues i=1(1)`NROWS' {
				if "`alternative'" == "alternative"	local MUINIT`i' = exp(`MUINIT`i'_temp'-(`MUINIT_SUM' 0/`NROWS')) // Gives exponentiated deviation of diagonal elements from mean diagonal elements
				if "`classic'" 	== "classic"		local MUINIT`i' = `MUINIT`i'_temp'-(`MUINIT_SUM' 0/`NROWS') // Gives deviation of diagonal elements from mean diagonal elements
				local rowinit "`rowinit' row:``rowvar'`i''=`MUINIT`i''"
				local colinit "`colinit' col:``colvar'`i''=`MUINIT`i''"
			}
		}

		*----------------------------------------------------
		*	2.3.7 Find initial values using Sobel's method (default)
		*----------------------------------------------------
		if "`alternative'" != "alternative" & "`classic'" != "classic" {
			fvrevar `controls' if `touse'
			local controlssobel `r(varlist)'

			if "`link'" == "linear" | "`link'" == "" {
				qui reg `depvar' i.`rowvar' `controlssobel' [`weight'`exp'] if `touse' & `rowvar'==`colvar'
				local sigmainit = (e(rss)/e(N))^(0.5)
			}
			if "`link'" == "probit"  qui probit `depvar' i.`rowvar' `controlssobel' [`weight'`exp'] if `touse' & `rowvar'==`colvar'
			if "`link'" == "logit"  qui logit `depvar' i.`rowvar' `controlssobel' [`weight'`exp'] if `touse' & `rowvar'==`colvar'
			
			tempname sobel1 muresult xbinit avgdev
			matrix `sobel1' = e(b)
			matrix `muresult' = `sobel1'[1,1..`NROWS']
			matrix `xbinit' = `sobel1'[1,`NROWS'+1...]
			mata : st_matrix("`avgdev'", (rowsum(st_matrix("`muresult'"))/`NROWS'))
			matrix `xbinit'[1,colsof(`xbinit')] = `xbinit'[1,colsof(`xbinit')] + `avgdev'[1,1]
			forvalues i=1/`NROWS' {
				local MUINIT`i' = `sobel1'[1,`i'] - `avgdev'[1,1]
				local rowinit `rowinit' `MUINIT`i''
				local colinit `colinit' `MUINIT`i''
			}
			tempvar muii
			qui predict `muii' , xb
			nobreak {
				rename `rowvar' `rowvar'_temp
				rename `colvar' `rowvar'
				tempvar mujj
				qui predict `mujj' , xb
				rename `rowvar' `colvar'
				rename `rowvar'_temp `rowvar'
			}
			if "`link'" == "linear" | "`link'" == "" {
				if "`wgt'" == "" | "`wgt'"=="cons" {
					qui reg `depvar' `muii' `mujj' [`weight'`exp'] if `touse'
					local pinit = _b[`muii']
					local qinit = _b[`mujj']
				}
				if "`wgt'" != "" {
					qui reg `depvar' i.$DRMWGTVAR#c.`muii' i.$DRMWGTVAR#c.`mujj' [`weight'`exp'] if `touse'
					local pinit ""
					local qinit ""
					forvalues i=1/`NROWS' {
						local ptemp = _b[`i'.$DRMWGTVAR#c.`muii']
						local pinit  `pinit' `ptemp'
						local qtemp = _b[`i'.$DRMWGTVAR#c.`mujj']						
						local qinit  `qinit' `qtemp'
					}
				}
			}
			if "`link'" == "probit" { 
				if "`wgt'" == "" {
					qui probit `depvar' `muii' `mujj' [`weight'`exp'] if `touse'
					local pinit = _b[`muii']
					local qinit = _b[`mujj']
				}
				else {
					qui probit `depvar' i.$DRMWGTVAR#c.`muii' i.$DRMWGTVAR#c.`mujj' [`weight'`exp'] if `touse'
					local pinit ""
					local qinit ""
					forvalues i=1/`NROWS' {
						local ptemp = _b[`i'.$DRMWGTVAR#c.`muii']
						local pinit  `pinit' `ptemp'
						local qtemp = _b[`i'.$DRMWGTVAR#c.`mujj']						
						local qinit  `qinit' `qtemp'
					}
				}
			}
			if "`link'" == "logit" {
				if "`wgt'" == "" {
					qui logit `depvar' `muii' `mujj' [`weight'`exp'] if `touse'
					local pinit = _b[`muii']
					local qinit = _b[`mujj']
				}
				else {
					qui logit `depvar' i.$DRMWGTVAR#c.`muii' i.$DRMWGTVAR#c.`mujj' [`weight'`exp'] if `touse'
					local pinit ""
					local qinit ""
					forvalues i=1/`NROWS' {
						local ptemp = _b[`i'.$DRMWGTVAR#c.`muii']
						local pinit  `pinit' `ptemp'
						local qtemp = _b[`i'.$DRMWGTVAR#c.`mujj']						
						local qinit  `qinit' `qtemp'
					}
				}
			}
			local copy ", copy"
		}	

		*----------------------------------------------------
		*	2.3.8 Set constraint: sum(mu_ii)=0 & sum(mu_jj)=0 ; p+q=1
		*----------------------------------------------------

		cons def `NCONSTR' `SUMCONSTR' 0 = 0
		local ++NCONSTR
		cons def `NCONSTR' `COLCONSTR' 0 = 0
		local ++NCONSTR
		
		if "`wgt'" == "" {
			cons def `NCONSTR' [q]_cons + [p]_cons=1
			local ++NCONSTR
		}
		else {
			forvalues i=1/`NROWS' {
				cons def `NCONSTR' [q`i']_cons + [p`i']_cons=1
				local ++NCONSTR
			}
		}
		
		*----------------------------------------------------
		*	2.3.9 Declare link
		*----------------------------------------------------
		
		if "`link'" == "" | "`link'" == "linear" {
			local model_type = "drm_normal_ll"
			local sigma "(sigma: `depvar' = )"
			if "`alternative'" == "alternative" | "`classic'" == "classic" {
				qui sum `depvar' 
				local sigmainit "sigma:_cons=`r(sd)'"
			}
		}
		
		if "`link'" == "logit" local model_type = "drm_logit_ll"
		if "`link'" == "probit" local model_type = "drm_probit_ll"
	
		*----------------------------------------------------
		*	2.3.10 Add user defined constrains
		*----------------------------------------------------
		
		local Nownconstrains : list sizeof local ownconstrains
		tokenize `ownconstrains'
		forvalues i=1(1)`Nownconstrains' {
			if "``i''" == "[p]_cons=1" local `i' "[p]_cons=1.0000001" 
			if "``i''" == "[q]_cons=1" local `i' "[q]_cons=1.0000001" 
			cons def `NCONSTR' ``i''
			local ++NCONSTR
		}
		*----------------------------------------------------
		*	2.3.11 Maximize and display
		*----------------------------------------------------
		ml model lf `model_type' ///
			(row: `depvar' = `ROWVARS', nocons) ///
			(col: `depvar' = `COLVARS', nocons) ///
			`pestimate' `qestimate' ///
			`rhoestimate' ///
			(xb: `depvar' = `controls') ///
			`sigma' ///
			[`weight'`exp'] if `touse', ///
			nopre tech(`tech') vce(`vce') constraint(2/`NCONSTR')  ///
			iter(`iterate') `difficult' max   ///
			init(`rowinit' `colinit' `pinit' `qinit' `rhoinit' `xbinit' `sigmainit' `copy') //
		if "`link'" == "linear" | "`link'" == ""  local NEQ = e(k_eq) - 1	
		else  local NEQ = e(k_eq) 
		ml display, level(`level') `coeflegend' nocnsreport neq(`NEQ')
	} 
	cap macro drop DRMCONSTRAIN 
	cap macro drop DRMWGTVAR
	cap macro drop DRMINTERVARS
	cap macro drop DRMSETOFP DRMSETOFQ
	cap macro drop DRMRHO
	cap macro drop DRMBYVAR
	cap cons drop _all
	if "`keep'"!="keep" {
		cap drop _`rowvar'_*
		cap drop _`colvar'_*
	}
end


