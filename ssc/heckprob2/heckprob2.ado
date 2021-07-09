/**********************************/
/*Changed to be use with heckp_d2**/
/*evoluator by Jerzy Mycielski    */
/*Warsaw Uniwersity, 17.07.2004   */
/*aditional option nocoef - table */
/* of results not displayed       */
/**********************************/

*! version 6.0.11  23jun2003
program define heckprob2, byable(onecall)
	version 6

	if replay() {
		if "`e(cmd)'" != "heckprob2" { error 301 }
		if _by() { error 190 }
		Display `0'
		exit
	}
	if _by() {
		by `_byvars'`_byrc0':  Estimate `0'
	}
	else	Estimate `0'
end

program define Estimate, eclass byable(recall)

				/* parse syntax */	

					/* Allow = after depvar */

	gettoken depvar 0 : 0 , parse(" =,[")
	unab depvar : `depvar'
	confirm variable `depvar'
	gettoken equals rest : 0 , parse(" =")
	if "`equals'" == "=" { local 0 `"`rest'"' }

	syntax [varlist(numeric default=none)] [pw iw fw] [if] [in] ,	/*
		*/ SELect(string) [ 					/*
		*/ CLuster(varname) noCONstant FIRst FROM(string)	/*
		*/ FROM0(string) Level(integer $S_level) noLOg 		/*
		*/ OFFset(varname numeric) NOCOEf Robust noSKIP SCore(string) * ]

	if _by() {
		_byoptnotallowed score() `"`score'"'
	}

	SelectEq seldep selind selnc seloff : `"`select'"'

	mlopts mlopts, `options'
	local cns `s(constraints)'

	if "`weight'"  != "" { local wgt `"[`weight'`exp']"' }
	if "`cluster'" != "" { local clusopt "cluster(`cluster')" }
	if "`seloff'"  != "" { local soffopt "offset(`seloff')" }
	if "`offset'"  != "" { local offopt "offset(`offset')" }
	if "`first'"   == "" { local show1st "nocoef" }
	if "`log'"     != "" { local qui "quietly" }
	if "`weight'" == "pweight" | "`robust'`cluster'" != "" {
		local robust "robust"
		/* probit does not allow iweights and robust so use crittype
		 * instead of robust option */
		local crtype crittype("log pseudo-likelihood")
	}


					/* Check syntax errors */

	if "`constant'" != "" & "`varlist'" == "" { 
		noi di in red "must specify independent variables or "	/*
			*/ "allow constant for primary equation"
		exit 198
	}

	ChkSkip skip : "`skip'" "`robust'" "`constant'" "`varlist'" "`cns'"


					/* Process scores */

	local ct : word count `score'		/* stub -- score(stub*) */
	if `ct' == 1 {
		if substr("`score'",-1,1) == "*" {
			local score = substr("`score'",1,length("`score'")-1)
			local score `score'1 `score'2 `score'3 
		}
	}

	local ct : word count `score'
	if `ct' > 0 & `ct' != 3 {
		di in red "score() requires you specify 3 new variable "  /*
			*/ "names in this case"
		exit 198
	}

	if "`score'" != "" { 
		confirm new variable `score'
		local score "score(`score')" 
	}


				/* Find estimation sample */

	if "`seldep'" == "" {
		tempname seldep
		gen byte `seldep' = `depvar' != .
		local selname "select"
	}
	else	local selname `seldep'

	marksample touse, novarlist
	markout `touse' `seldep' `selind' `seloff' `cluster', strok
	marksample touse2
	markout `touse2' `depvar' `varlist' `offset'
	qui replace `touse' = 0 if `seldep' & !`touse2'


				/* Remove collinearity */

	_rmcoll `selind' `wgt' if `touse', `selnc'
	local selind "`r(varlist)'"
	_rmcoll `varlist' `wgt' if `touse' & `seldep', `constant'
	local varlist "`r(varlist)'"

				/* Only way to check for perfect pred */

	capture probit `seldep' `selind' `wgt' if `touse', `selnc' `soffopt' 
	if _rc == 2000 {
	    di as txt "selection equation:" _c
	    probit `seldep' `selind' `wgt' if `touse', `selnc' `soffopt' 
	}
	else if _rc { 
		error _rc 
	}


				/* Check selection condition */

	qui sum `seldep' if `touse'
	if `r(N)' == `r(sum)' {
		di in red "Dependent variable never censored due to selection: "
		di in red "model simplifies to probit regression"
		exit 498
	}


				/* Get starting values, etc. */

	tempname llc b0 b0sel b00
	tempvar  nshaz 

					/* just for part of comparison LL */
					/* and to check for prefect pred */
	`qui' di in gr _n "Fitting probit model:"
	`qui' probit `depvar' `varlist' `wgt' if `touse' & `seldep', /*
		*/ `constant' `offopt' nocoef `crtype'
	scalar `llc' = e(ll)

	if "`robust'"=="" | "`from'"=="" | ("`skip'"!="" & "`from0'"=="") {
		`qui' di in gr _n "Fitting selection model:"
		`qui' probit `seldep' `selind' `wgt' if `touse',  /*
			*/ `selnc' `soffopt' `show1st' asis  `crtype'
		mat `b0sel' = e(b)
		if "`robust'" == "" { scalar `llc' = `llc' + e(ll) }

		qui predict double `nshaz', xb
		qui replace `nshaz' = normd(`nshaz') / normprob(`nshaz')
	}

	if "`robust'" == "" {
		`qui' di in gr _n "Comparison:    log likelihood = " /*
			*/ in ye %10.0g `llc' 
	}

	if "`constant'" == "" { 
		tempname one
		gen byte `one' = 1 
	}

	if "`skip'" != "" & "`from0'" == "" {
		`qui' di in gr _n "Fitting constant-only starting values:"
		`qui' probit `depvar' `one' `nshaz' `wgt' 	/*
			*/ if `touse' & `seldep', 		/*
			*/ noconstant `offopt' nocoef asis `crtype'
		MkB0 `b00' : `b0sel' `nshaz'
		local from0 "`b00', copy"
	}

	if "`from'" == "" {
		`qui' di in gr _n "Fitting starting values:"
		`qui' probit `depvar' `varlist' `one' `nshaz' `wgt'	/*
			*/ if `touse' & `seldep', 			/*
			*/ noconstant `offopt' nocoef asis `crtype'
		MkB0 `b0' : `b0sel' `nshaz'
		local from "`b0', copy"
	}

	qui regress `seldep' `wgt' if !`seldep' & `touse'
	local N_cens = e(N)


				/* ML estimation */


	if "`skip'" != "" {
		`qui' di in gr _n "Fitting constant-only model:"

		capture noi ml model d2 heckp_d2 			/*
		*/ (`depvar': `depvar' = , `offopt') 	/*			
		*/ (`selname': `seldep' = `selind', `selnc' `soffopt')                   /*
		*/ /athrho						/*
		*/ `wgt' if `touse' , waldtest(0)			/*
		*/ collinear missing max nooutput nopreserve		/*
		*/ init(`from0') search(off) `log' `mlopts'

		if _rc == 1400 & "`from'" == "`b0', copy" {
			di as txt "note:  default initial values "	/*
			*/ "infeasible; starting from B=0"

			ml model d2 heckp_d2 			/*
			*/ (`depvar': `depvar' = , `offopt')		/*
			*/ (`selname': `seldep' = `selind', `selnc' `soffopt')/*
			*/ /athrho					/*
			*/ `wgt' if `touse' , waldtest(0)		/*
			*/ collinear missing max nooutput nopreserve	/*
			*/ init(/athrho=0) search(off) `log' `mlopts'
		}
		else if _rc { 
			error _rc 
		}

		local continu "continue"
	}

	`qui' di in gr _n "Fitting full model"
	capture noi ml model d2 heckp_d2 				 /*
		*/ (`depvar': `depvar' = `varlist', `offopt' `constant')/*
		*/ (`selname': `seldep' = `selind', `selnc' `soffopt')	 /*
		*/ /athrho						 /*
		*/ if `touse' `wgt',					 /*
		*/ collinear missing max nooutput nopreserve		 /*
		*/ title(Probit model with sample selection)		 /*
		*/ `score' `robust' `clusopt'				 /*
		*/ init(`from') search(off) `continu' `log' `mlopts'	

	if _rc == 1400 & "`from'" == "`b0', copy" {
		di as txt "note:  default initial values "		 /*
		*/ "infeasible; starting from B=0"

		ml model d2 heckp_d2 					 /*
		*/ (`depvar': `depvar' = `varlist', `offopt' `constant') /*
		*/ (`selname': `seldep' = `selind', `selnc' `soffopt')	 /*
		*/ /athrho						 /*
		*/ if `touse' `wgt',					 /*
		*/ collinear missing max nooutput nopreserve		 /*
		*/ title(Probit model with sample selection)		 /*
		*/ `score' `robust' `clusopt'				 /*
		*/ init(/athrho=0) search(off) `continu' `log' `mlopts'	

	} 
	else if _rc { 
		error _rc 
	}


				/* Saved results */

	if "`robust'" == "" {		/* test of idependent equations */
		est scalar ll_c = `llc'
		est scalar chi2_c = abs(-2*(e(ll)-e(ll_c)))
		est local chi2_ct "LR"
	}
	else {
		qui test [athrho]_cons = 0 
		est scalar chi2_c = r(chi2)
		est local chi2_ct "Wald"
	}
	est scalar p_c = chiprob(1, e(chi2_c))
	qui _diparm athrho, tanh
	est scalar rho = r(est)
	tokenize `e(depvar)'
	if substr("`2'", 1, 2) == "__" { est local depvar `1' }
	est scalar N_cens = `N_cens'
	est local predict "heckpr_p"
	est local cmd "heckprob2"

	if "`nocoef'"=="" {
	     Display , level(`level') 
	}

end



/* process the selecton equation
	[depvar =] indvars [, noconstant offset ]
*/

program define SelectEq
	args seldep selind selnc seloff colon sel_eqn

	gettoken dep rest : sel_eqn, parse(" =")
	gettoken equal rest : rest, parse(" =")

	if "`equal'" == "=" { 
		unab dep : `dep'
		c_local `seldep' `dep' 
	}
	else	local rest `"`sel_eqn'"'
	
	local 0 `"`rest'"'
	syntax [varlist(numeric default=none)] 	/*
		*/ [, noCONstant OFFset(varname numeric) ]

	if "`varlist'" == "" {
		di in red "no variables specified for selection equation"
		exit 198
	}

	c_local `selind' `varlist'
	c_local `selnc' `constant'
	c_local `seloff' `offset'
end


/* handle -noskip- option */

program define ChkSkip
	args newskip colon skip robust const indvars cns

	c_local `newskip' `skip'

	if "`skip'" != "" {
		if "`robust'" != "" {
			di as txt "model LR test inappropriate with " /*
				*/ "robust covariance estimates,"
			local skip
		}
		if "`const'" != "" {
			di as txt "model LR test inappropriate with " /*
				*/ "noconstant option,"
			local skip
		}
		if "`indvars'" == "" {
			di as txt "model LR test inappropriate with " /*
				*/ "constant-only model,"
			local skip
		}
		if "`robust'" != "" {
			di as txt "model LR test inappropriate with " /*
				*/ "constraints,"
			local skip
		}
		if "`skip'" == "" {
			di as txt "    option skip ignored and " /*
				*/ "performing Wald test instead"
		}
	}

	c_local `newskip' `skip'

end


/* make a Beta_0 matrix of initial values */

program define MkB0
	args b0 colon b0sel hazvar

	tempname athrho

	mat `b0' = e(b)
	local k = colsof(`b0')

	scalar `athrho' = _b[`hazvar']
	scalar `athrho' = max(min(`athrho',.85), -.85)
	scalar `athrho' = 0.5 * log((1+`athrho') / (1-`athrho'))

	mat `b0' =  `b0'[1,1..`k'-1] , `b0sel' ,`athrho'
end


program define Display
	syntax [, Level(integer $S_level) ]

	_crcshdr
	ml display , noheader level(`level') neq(2) plus

	_diparm athrho, level(`level')
	di in smcl in gr "{hline 13}{c +}{hline 64}"

	_diparm athrho, level(`level') tanh label("rho")
	di in smcl in gr "{hline 13}{c BT}{hline 64}"

	if "`e(vcetype)'" != "Robust" { 
		local testtyp LR
	}
	else    local testtyp Wald
	di in gr  "`testtyp' test of indep. eqns. (rho = 0):" /*
		*/ _col(38) "chi2(" in ye "1" in gr ") = "   /*
		*/ in ye %8.2f e(chi2_c) 		     /*
		*/ _col(59) in gr "Prob > chi2 = " in ye %6.4f e(p_c)
	di in smcl in gr "{hline 78}"

	exit e(rc)
end

