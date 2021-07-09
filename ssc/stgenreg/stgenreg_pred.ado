*! version 0.2.0 14nov2012

program stgenreg_pred
	version 11.2
	
	syntax newvarname [if] [in], 	[									///
										Hazard 							///
										CUMHazard						///
										Survival						///
										Failure							///
																		///
										MATA							///
																		///
										CI 								///
										Level(cilevel) 					///
										TIMEvar(varname) 				///
										AT(string)						///
										ZEROS							///
									]

	marksample touse, novarlist
	local newvarname `varlist'
	qui count if `touse'
	local nobs = `r(N)'
	if `nobs'==0 {
		error 2000
	}
	
	if wordcount(`"`hazard' `cumhazard' `survival' `failure'"')>1 {
		di as error "You have specified more than one prediction option"
		exit 198
	}
	
	if "`mata'"!="" & wordcount(`"`ci' `stdp'"')>0 {
		di as error "ci/stdp not allowed with mata"
		exit 198
	}	
	
/* Preserve data for out of sample prediction  */	
	tempfile newvars 
	preserve	
	
/* Use _t if option timevar not specified */
	tempvar t
	if "`timevar'" == "" {
		gen double `t' = _t
	}
	else gen double `t' = `timevar'

/* Baseline predictions */
	if "`zeros'"!="" {
		foreach var in `e(varlist)' {
			if `"`: list posof `"`var'"' in at'"' == "0" { 
				qui replace `var' = 0 if `touse'
			}
		}
	}	
	
/* Out of sample predictions using at() */
	if "`at'" != "" {
		tokenize `at'
		while "`1'"!="" {
			unab 1: `1'
			cap confirm var `2'
			if _rc {
				cap confirm num `2'
				if _rc {
					di in red "invalid at(... `1' `2' ...)"
					exit 198
				}
			}
			qui replace `1' = `2' if `touse'
			mac shift 2
		}
	}	
	
/* CI option */
	if "`ci'"!="" {
		local opt "ci(`newvarname'_lci `newvarname'_uci)"
	}
	
	
	/********************************************************************************************************************************************************/
	/*** Rebuild variables and time-dep effects etc. ***/
	
	if "`timevar'"!="" | "`at'"!="" | "`zeros'"!="" {
	
			/* Loop over parameters */
			forvalues i=1/`e(nparams)' {
				
				/* Extract number of components for ith parameter */
				local ncomp : word `i' of `e(ncomps)'
				
				if `ncomp'>0 {
				
					forvalues k = 1/`ncomp' {
						
						/* time function */
						if regexm("`e(eqn`i'comp`k')'","#t")==1 {
							cap drop _eqn`i'_comp`k'
							qui gen double _eqn`i'_comp`k' = . if `touse'
							mata: _newt = st_data(.,"`t'","`touse'")
							mata: st_local("newcovform", subinstr("`e(eqn`i'comp`k')'","#t","_newt",.))
							
							//if tde need to throw vars into Mata
							foreach var in `e(varlist)' {
								if regexm("`e(eqn`i'comp`k')'","`var'")==1 {
									mata: `var' = st_data(.,"`var'","`touse'")
								}
							}
							
							mata: component = `newcovform'
							mata: st_store(.,"_eqn`i'_comp`k'","`touse'",component)
						}
						
						/* splines */
						if regexm("`e(eqn`i'comp`k')'","#rcs")==1 {
							cap drop _eq`i'_cp`k'_rcs*
							if "`e(eqn`i'comp`k'rcsoffset)'"!="" {
								local addoffset_`i'_`k' + `e(eqn`i'comp`k'rcsoffset)'
							}
							else {
								local addoffset_`i'_`k'
							}
							if "`e(eqn`i'comp`k'rcstime)'"=="" {
								tempvar lnt
								gen double `lnt' = ln(`t' `addoffset_`i'_`k'') if `touse'
								local newt "`lnt'"
							}
							else {
								tempvar timetemp
								qui gen double `timetemp' = `t' `addoffset_`i'_`k''
								local newt "`timetemp'"
							}
							local rmatname`i'_`k'
							if "`e(eqn`i'comp`k'noorthog)'"=="" {
								tempname rmat`i'_`k'
								mat `rmat`i'_`k'' = e(eqn`i'comp`k'rcsmat)
								local rmatname`i'_`k' rmat(`rmat`i'_`k'')
							}
							qui rcsgen `newt' if `touse', knots(`e(eqn`i'comp`k'bhknots)') `rmatname`i'_`k'' gen(_eq`i'_cp`k'_rcs)
							/* TDE */
							if "`e(eqn`i'comp`k'tde)'"!="" {
								if "`e(eqn`i'comp`k'bhknots)'"!="" {
									local df : word count `e(eqn`i'comp`k'bhknots)'
									local df = `df'-1
								}
								else local df = 1
								forvalues j = 1/`df' {
									qui replace _eq`i'_cp`k'_rcs`j' = _eq`i'_cp`k'_rcs`j' * `e(eqn`i'comp`k'tde)' if `touse'								
								}
							}							
						}
						
						/* FP's */
						if "`e(eqn`i'comp`k'fps)'"!="" {
							cap drop _eq`i'_cp`k'_fp_*
							if "`e(eqn`i'comp`k'fpsoffset)'"!="" {
								local addoffset_`i'_`k' + `e(eqn`i'comp`k'fpsoffset)'
							}
							else {
								local addoffset_`i'_`k'
							}
							if "`e(eqn`i'comp`k'fps)'"=="1" {
								qui gen double _eq`i'_cp`k'_fp_1 = `t' `addoffset_`i'_`k'' if `touse'
								local nfps_`i'_`k' = 1
							}
							else {
								qui gen double _eq`i'_cp`k'_fp = `t' `addoffset_`i'_`k'' if `touse'
								qui fracgen _eq`i'_cp`k'_fp `e(eqn`i'comp`k'fps)' if `touse', stub(20) noscaling center(no)
								local nfps_`i'_`k' : word count `r(names)'
								drop _eq`i'_cp`k'_fp
							}
							/* TDE */
							if "`e(eqn`i'comp`k'tde)'"!="" {
								forvalues j = 1/`nfps_`i'_`k'' {
									qui replace _eq`i'_cp`k'_fp_`j' = _eq`i'_cp`k'_fp_`j' * `e(eqn`i'comp`k'tde)' if `touse'								
								}
							}							
						}			
					}
				}
			}
	}
		
	/********************************************************************************************************************************************************/
	/*** Hazard function ***/
	
	if "`hazard'"!="" {
		
		if "`mata'"=="" {
			local haz "`e(hazard)'"
			mata: st_local("haz",subinstr("`haz'",":+","+",.))
			mata: st_local("haz",subinstr("`haz'",":-","-",.))
			mata: st_local("haz",subinstr("`haz'",":/","/",.))
			mata: st_local("haz",subinstr("`haz'",":*","*",.))
			mata: st_local("haz",subinstr("`haz'",":^","^",.))
			mata: st_local("haz",subinstr("`haz'","#t","`t'",.))
			mata: st_local("haz",subinstr("`haz'",":<","<",.))
			mata: st_local("haz",subinstr("`haz'",":>",">",.))
			mata: st_local("haz",subinstr("`haz'",":<=","<=",.))
			mata: st_local("haz",subinstr("`haz'",":>=",">=",.))
			mata: st_local("haz",subinstr("`haz'",":=<","=<",.))
			mata: st_local("haz",subinstr("`haz'",":=>","=>",.))
			mata: st_local("haz",subinstr("`haz'",":==","==",.))
			
			forvalues i = 1/`e(nparams)' {
				local eqname : word `i' of `e(eqnames)'
				mata: st_local("haz",subinstr("`haz'","p`i'","xb(`eqname')",.))
			}
			
			qui predictnl `newvarname' = log(`haz') if `touse', `opt'
		}
		else {
			
			/* Need to pass p*'s to Mata */
			forvalues i = 1/`e(nparams)' {
				tempvar p`i'
				local eqname : word `i' of `e(eqnames)'
				qui predictnl `p`i'' = xb(`eqname') if `touse'
				mata: p`i' = st_data(.,"`p`i''","`touse'")
			}
			mata: st_local("codeline",subinstr("`e(hazard)'","#t","t",.))
			mata: t = st_data(.,"`t'","`touse'")
			mata: haz = `codeline'
			qui gen double `newvarname' = . if `touse'
			mata: st_store(.,"`newvarname'","`touse'",haz)
		}
	}
	
	/********************************************************************************************************************************************************/
	/*** Cumulative hazard function ***/
	
	if "`cumhazard'"!="" {
		
		/* Basis nodes and weights */
		forvalues i=1/`e(ns)' {
			tempname knodes`i' kweights`i'
			local quad : word `i' of `e(quadrature)'
			if "`quad'"=="jacobi" {
				local abopts alpha(`e(alpha)') beta(`e(beta)')
			}
			else local abopts
			stgenreg_gaussquad, n(`e(nodes`i')') `quad' `abopts'
			matrix `knodes`i'' = r(nodes)'
			matrix `kweights`i'' = r(weights)'
		}
		
		local eqnlist "0"
		forvalues j = 1/`e(nodes1)' {
			tempvar node1_`j'
			qui gen double `node1_`j'' =  0.5*(`t')*(el(`knodes1',1,`j')) + 0.5*(`t') if `touse'
			local eqnlist "`eqnlist' + (predict(hazard timevar(`node1_`j'') `mata' `zeros' at(`at')))*el(`kweights1',1,`j')*(`t')/2 "
		}
		
		qui predictnl `newvarname' = `eqnlist' if `touse', `opt'
	
	}
	
	/********************************************************************************************************************************************************/
	/*** Survival function ***/
	
	if "`survival'"!="" {
		qui predictnl `newvarname' = exp(-predict(cumhazard `zeros' `mata' at(`at') timevar(`timevar'))) if `touse', `opt'
	}

	/********************************************************************************************************************************************************/
	/*** Survival function ***/
	
	if "`failure'"!="" {
		if "`mata'"=="" {
			qui predictnl `newvarname' = 1-exp(-predict(cumhazard `zeros' at(`at') timevar(`timevar'))) if `touse', `opt'
		}
		else {
			qui predict `newvarname' if `touse', cumhazard mata `zeros' at(`at') timevar(`timevar') `ci'
			qui replace `newvarname' = 1-exp(-`newvarname') if `touse'
		}
	}

	/********************************************************************************************************************************************************/
	/* restore original data and merge in new variables */
	
		if "`hazard'`cumhazard'`survival'"!="" {
			local keep `newvarname'
		}
		if "`ci'" != "" { 
			local keep `keep' `newvarname'_lci `newvarname'_uci
		}

		keep `keep'
		qui save `newvars'
		restore
		merge 1:1 _n using `newvars', nogenerate noreport
		
		if "`hazard'"!="" & "`mata'"=="" {
			qui replace `newvarname' = exp(`newvarname')
			if "`ci'" != "" { 
				qui replace `newvarname'_lci = exp(`newvarname'_lci)
				qui replace `newvarname'_uci = exp(`newvarname'_uci)
			}
		}
	
end
