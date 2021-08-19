*! version 1.0.9  02feb2021
capture program drop mstbayes
program define mstbayes, rclass
version 16

quietly {
	preserve
		
	tempfile orig
	save `orig'

	syntax varlist(fv) [if] [in], INTervention(varlist fv max=1) RANdom(varlist max=1) [, THReshold(numlist) SEPCHains DIAGnostics noIsily SAVE *]
	
	
	if "`isily'" == "" {
		local isily noheader notable
		}
	else {
		local isily 
		}
	
	if "`threshold'" == "" local threshold 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1
	
	local intervraw: copy local intervention
	
	fvrevar `intervention', list
	local intervention `r(varlist)'
	
	cap {
		local newvarlist	
		foreach var of local varlist {
			if "`var'" != "`intervention'" & !regexm("`var'","i[^\.]*\.`intervention'$") & !regexm("`var'","\((#[0-9])\)*\.`intervention'$") | regexm("`var'","#")   {
				local newvarlist `newvarlist' `var'
				}
			else {
			noi disp as txt "Note: Inclusion of the intervention variable in the variable list is redundant."
			}
			}
		local varlist: copy local newvarlist
		}
	
	
	marksample touse
	markout `touse' `intervention' `random'
	
	keep if `touse'

	tempname X chk max grp_max Nt N b Beta c schCov UschCov Cov Sigma SchEffects count counted counted_to_exclude Sim_varB_Uncond Sim_varW_Uncond Sim_var_TT_Uncond Sim_ICC_Uncond Sim_varW_Cond Sim_var_TT_Cond Sim_ICC_Cond Sigma_Cond Sigma_Uncond size chns test1 x min Max
	tempvar total_chk

	tempfile mst
	save `mst'

	tab `random' `intervention', matcell(`X')

	drop _all
	svmat `X'
	describe
	scalar `max' = r(k)
		
	foreach i of numlist 1/`=`max'' {
		tempvar r`i'
		gen double `r`i''=0
		replace `r`i''=1 if `X'`i'>0
		}
	egen double `total_chk' = rowtotal(`r1'-`r`=`max''')
	count if `total_chk' >1
	scalar `chk' = `r(N)'
	if `chk'==0 {
		display as error "error: This is not an MST design"
		error 459
		}

	clear
	use `mst'
	
	baseset, max(`max') intervention(`intervraw')
	local refcat `r(refcat)'
	
	levelsof `intervention', local(levels)
	tokenize `levels'
	
	sort `random'
	tab `random'
	scalar `grp_max' = r(r)
	
	gettoken depvar indepvars: varlist
	
	local schcolnames "Intercept"
	forvalues i = 1/`=`max''{
		if "`=`refcat'+0'" != "``i''" {
			local schcolnames `schcolnames' "Estimate``i''"
			local fnc `fnc' `i'
			}
		}
	tokenize `fnc'
	
	matrix `Nt'=J(`=`max'-1',1,.)
	
	tab `intervention', gen(brkn_fctor) matcell(`x')
	forvalues i= 1/`=`max'-1' {
	matrix `Nt'[`i',1]=`x'[``i'',1]
	}
	local rowname "Intercept"
	tokenize `levels'
	foreach i of numlist 1/`=`max''{
		if "`=`refcat'+0'" != "``i''" {
			local rowname `rowname' "`intervention'``i''"
			local two `two' brkn_fctor`i'
			}
		else {
		local one `one' brkn_fctor`i'
		}
		}
		
	local broken_treatment
	foreach i of numlist 1/`=`max'' {
		local broken_treatment `broken_treatment' brkn_fctor`i' /*store all brokn_fctors in local*/
		}
	rename (`one' `two') (`broken_treatment')
	gettoken baseline rest: broken_treatment
		
	count
	scalar `N' = `r(N)'
	
	/*Unconditional Output*/
	noi bayes,saving(mcmcUncMST, replace) `isily' `options': mixed `depvar' || `random':, cov(unstructured)
	
	
	
	/*Conditional Output*/
	noi bayes, saving(mcmcCondMST, replace) `isily' `options': mixed `depvar' i.`intervention' `indepvars' || `random':`rest', cov(unstructured)
	
	if "`diagnostics'"!="" {
		bayesgraph diagnostics _all
		}
	if "`sepchains'" != "" {
		tempname chns
		bayesstats summary, sepchains
		scalar `chns' = r(nchains)
		
		forvalues i = 1/`=`chns'' {
			tempname spchns_`i'
			matrix `spchns_`i'' = r(summary_chain`i')
			return matrix sepchains_`i' = `spchns_`i''
			}
		}
	bayesstats summary
	matrix `b' = r(summary)
	scalar `size' = r(mcmcsize)
	scalar `chns' = r(nchains)  
	
	matrix `test1' = `b'[1.."`depvar':_cons", "Mean"],`b'[1.."`depvar':_cons", "CrI lower".."CrI upper"]
	matrix `Beta' = `test1'
	forvalues i = 1/`=rowsof(`test1')' {
		forvalues j = 1/`=colsof(`test1')' {
			matrix `Beta'[`i',`j']= round(`test1'[`i',`j'],.01)
			}
		}
	matrix colnames `Beta' = "Estimate" "95% LB" "95% UB"
	
	bayesstats summary, showreffects
	matrix `c' = r(summary)
	
	matrix `test1'=`c'["U0[`random']:1".."U0[`random']:`=`grp_max''",1]
	forvalues i = 1/`=`max'-1'{		
		matrix `test1' = `test1', `c'["U`i'[`random']:1".."U`i'[`random']:`=`grp_max''",1]
		}
	
	local schrownames "`random':1"
	foreach i of numlist 2/`=`grp_max'' {
		local schrownames `schrownames' "`random':`i'"
	}
		
	matrix `SchEffects' = `test1'
	forvalues i = 1/`=rowsof(`test1')' {
		forvalues j = 1/`=colsof(`test1')' {
			matrix `SchEffects'[`i',`j']= round(`test1'[`i',`j'],.01)
		}
	}
	matrix colnames `SchEffects' = `schcolnames'
	matrix rownames `SchEffects' = `schrownames'
	
		
	bayesstats summary {U:Sigma}
	matrix `test1' = r(summary)
	matrix `test1' = `test1'[1...,"Mean"]
	matrix `Sigma' = `test1'
	forvalues i = 1/`=rowsof(`test1')' {
		forvalues j = 1/`=colsof(`test1')' {
			matrix `Sigma'[`i',`j']= round(`test1'[`i',`j'],.01)
		}
	}
	
	
	use mcmcUncMST.dta, clear
	expand _frequency
	
	lookfor "e.`depvar':sigma2"
	rename `r(varlist)' Sim_varW_Uncond 
	label variable Sim_varW_Uncond "Sim_varW_Uncond"
	
	lookfor "U0:sigma2"
	rename `r(varlist)' Sim_varB_Uncond
	label variable Sim_varB_Uncond "Sim_varB_Uncond"
	
	keep Sim_varW_Uncond Sim_varB_Uncond  /*CHECK*/
	
	gen double Sim_var_TT_Uncond = Sim_varB_Uncond + Sim_varW_Uncond
	
	gen double Sim_ICC_Uncond = Sim_varB_Uncond/Sim_var_TT_Uncond
	
	
	mean Sim_varB_Uncond
	matrix `Sim_varB_Uncond' = round(e(b)[1,1],.01)
	
	mean Sim_varW_Uncond
	matrix `Sim_varW_Uncond' = round(e(b)[1,1],.01)
	
	mean Sim_var_TT_Uncond
	matrix `Sim_var_TT_Uncond' = round(e(b)[1,1],.01)
	
	mean Sim_ICC_Uncond
	matrix `Sim_ICC_Uncond' = round(e(b)[1,1],.01)
	
	matrix `Sigma_Uncond' = `Sim_varW_Uncond',`Sim_var_TT_Uncond',`Sim_ICC_Uncond'
	
	tempfile mcmcUncondMST
	save `mcmcUncondMST'

	
	use mcmcCondMST.dta, clear
	expand _frequency
	
	lookfor "b.`intervention'"
	drop `r(varlist)'
	
	local s
	lookfor ".`intervention'"
	foreach var of varlist `r(varlist)' {
		local s = `s'+1
		rename `var' Sim_Beta_t`s'
		}
		
	lookfor "sigma"
	keep `r(varlist)' Sim_Beta_t* /*isolate all sigmas*/
	
	lookfor "e.`depvar':sigma2" 
	rename `r(varlist)' Sim_varW_Cond
	local Sim_varW_Cond_l Sim_varW_Cond
	label variable Sim_varW_Cond "Sim_varW_Cond"
	
	lookfor "Sigma_1_1" 
	rename `r(varlist)' Sim_Sch_Cond
	local Sim_Sch_Cond_l Sim_Sch_Cond
	label variable Sim_Sch_Cond "Sim_Sch_Cond"
	
		
	forvalues i = 2/`=`max'' {
		lookfor "Sigma_`i'_`i'"
		rename `r(varlist)' Sim_varB_Slope_Cond`=`i'-1' /*slope (treatment)*/
		label variable Sim_varB_Slope_Cond`=`i'-1' "Sim_varB_Slope_Cond`=`i'-1'"
		
		lookfor "Sigma_`i'_1"
		rename `r(varlist)' Sim_varB_Cov_Cond`=`i'-1' /* covariance (treatment:intercept)*/
		label variable Sim_varB_Cov_Cond`=`i'-1' Sim_varB_Cov_Cond`=`i'-1'
		}
		
	local Sim_varB_Slope_Cond_l
	local Sim_varB_Cov_Cond_l
	
	foreach i of numlist 1/`=`max'-1'{
		local Sim_varB_Slope_Cond_l `Sim_varB_Slope_Cond_l' Sim_varB_Slope_Cond`i'
		local Sim_varB_Cov_Cond_l `Sim_varB_Cov_Cond_l' Sim_varB_Cov_Cond`i'
		}
	
	if `=`max''>2 {
		
		lookfor "Sigma_"
		local Sim_CovRest_Cond_l `r(varlist)'
		
		foreach var of varlist `Sim_CovRest_Cond_l'{
			local variable_label : variable label `var'
			local variable_label : subinstr local variable_label "{U:" ""
			local variable_label : subinstr local variable_label "}" "" /*remove {U: and } as they are invalid variable names, and rename variables by their label*/
			rename `var' `variable_label'
			}
			
		lookfor "Sigma_"
		local Sim_CovRest_Cond `r(varlist)'
		}
		
	merge 1:1 _n using `mcmcUncondMST', nogenerate
	
	
	mata: func4("`Sim_varW_Cond_l'","`Sim_Sch_Cond_l'","`Sim_varB_Cov_Cond_l'","`Sim_varB_Slope_Cond_l'", "`Nt'", "`N'")
	
	mean Sim_varW_Cond
	matrix `Sim_varW_Cond' = round(e(b)[1,1],.01)
	
	mean Sim_var_TT_Cond
	matrix `Sim_var_TT_Cond' = round(e(b)[1,1],.01)
	
	mean Sim_ICC_Cond
	matrix `Sim_ICC_Cond' = round(e(b)[1,1],.01)
	
	matrix `Sigma_Cond' = `Sim_varW_Cond', `Sim_var_TT_Cond', `Sim_ICC_Cond'

	matrix `Cov' = `Sigma_Cond' \ `Sigma_Uncond'
	matrix rownames `Cov' = "Conditional" "Unconditional"
	matrix colnames `Cov' = "Pupils" "Total" "ICC"
	
	matrix `UschCov' = `Sim_varB_Uncond'
	matrix rownames `UschCov' = "Unconditional"
	matrix colnames `UschCov' = "School"
	
	/*COVARIANCE MATRIX*/
	cap {
		matrix `schCov' = J(`=`max'',`=`max'',.) /*Create empty matrix*/
		
		forvalues i = 1/`=`max'' {
		tempname diagmatrow`i' intmatrow`i' DiagMat`i' IntMat`i'
		scalar `diagmatrow`i'' = rownumb(`Sigma', "`random':U:Sigma_`i'_`i'")
		scalar `intmatrow`i'' = rownumb(`Sigma', "`random':U:Sigma_`i'_1")
		
		matrix `DiagMat`i'' = `Sigma'[`=`diagmatrow`i''',1]
		matrix `IntMat`i'' = `Sigma'[`=`intmatrow`i''',1]
		}
		
	tempname DiagMat IntMat
	matrix `DiagMat' = `DiagMat1' 
	matrix `IntMat' = `IntMat1'
	
	foreach i of numlist 2/`=`max'' {
		matrix `DiagMat' = `DiagMat' ,`DiagMat`i''
		matrix `IntMat'  = `IntMat' \ `IntMat`i''
		}
	
	matrix `schCov' = diag(`DiagMat') /*Diagonally placed Sigma_1_1, Sigma_2_2 ... etc*/
	
	forvalues i = 1/`=`max'' {
		matrix `schCov'[`i',1] = `IntMat'[`i',1] /*place Sigma_2_1, Sigma_3_1 etc..*/
		matrix `schCov'[1,`i'] = `IntMat'[`i',1]	/*place Sigma_2_1, Sigma_3_1 etc..*/
		}
	
	if `=`max''>2 {	
		scalar `count' = `=`max'-2'
		tokenize `Sim_CovRest_Cond'
		local k
		forvalues j = 1/`=`count'' {
			forvalues i = 1/`=`count'-`j'+1' {
				local k = `k'+ 1
				matrix `schCov'[`=`i'+`j'+1',`=`j'+1'] = `Sigma'["`random':U:``k''",1] /*if arms>=3, place off-diagonal elements, i.e Sigma_3_2, Sigma_4_2, Sigma_4_3 etc..*/
				matrix `schCov'[`=`j'+1',`=`i'+`j'+1'] = `Sigma'["`random':U:``k''",1]
				}
			}
		}
	} /*cap*/
	
	matrix colnames `schCov' = `rowname'
	matrix rownames `schCov' = `rowname'
		
		
		
	forvalues i = 1/`=`max'-1' {
		tempvar sim_ESW_Cond`i' sim_ESTT_Cond`i' sim_ESW_Uncond`i' sim_ESTT_Uncond`i'
		gen double `sim_ESTT_Uncond`i'' = Sim_Beta_t`i'/sqrt(Sim_var_TT_Uncond)
		gen double `sim_ESW_Uncond`i'' = Sim_Beta_t`i'/sqrt(Sim_varW_Uncond)
		
		gen double `sim_ESTT_Cond`i'' = Sim_Beta_t`i'/sqrt(Sim_var_TT_Cond)
		gen double `sim_ESW_Cond`i'' = Sim_Beta_t`i'/sqrt(Sim_varW_Cond)
		
		tempname gtmp1_W`i' gtmp2_W`i' sim_ESW_Cond`i'_Cent25 sim_ESW_Cond`i'_Cent975 ///
		sim_ESW_Uncond`i'_Cent25 sim_ESW_Uncond`i'_Cent975 CondES_W`i' UncondES_W`i' gtmp1_TT`i' gtmp2_TT`i' sim_ESTT_Cond`i'_Cent25 ///
		sim_ESTT_Cond`i'_Cent975 sim_ESTT_Uncond`i'_Cent25 sim_ESTT_Uncond`i'_Cent975 CondES_TT`i' UncondES_TT`i' Cond_Prob_ES`i' Uncond_Prob_ES`i' Cond_ES`i' Uncond_ES`i'
		
		
		foreach v of numlist `threshold'{
			local k`i' =`k`i''+1
			tempvar indic1_`k`i''W_`i' indic2_`k`i''W_`i' indic1_`k`i''TT_`i' indic2_`k`i''TT_`i' 
			tempname Cond`k`i''_ProbES`i' Uncond`k`i''_ProbES`i' Cond`k`i''_ProbES_W_`i' Uncond`k`i''_ProbES_W_`i' Uncond`k`i''_ProbES_TT_`i' Cond`k`i''_ProbES_TT_`i'
			
			gen double `indic1_`k`i''W_`i'' = 0
			gen double `indic2_`k`i''W_`i'' = 0
			
			gen double `indic1_`k`i''TT_`i'' = 0
			gen double `indic2_`k`i''TT_`i'' = 0
				
			replace `indic1_`k`i''W_`i'' = 1 if `sim_ESW_Cond`i''>`v'
			replace `indic2_`k`i''W_`i'' = 1 if `sim_ESW_Uncond`i''>`v'
			
			replace `indic1_`k`i''TT_`i'' = 1 if `sim_ESTT_Cond`i''>`v'
			replace `indic2_`k`i''TT_`i'' = 1 if `sim_ESTT_Uncond`i''>`v'
			
			mean `indic1_`k`i''W_`i''
			matrix `Cond`k`i''_ProbES_W_`i'' = e(b)
			scalar `Cond`k`i''_ProbES_W_`i'' = round(`Cond`k`i''_ProbES_W_`i''[1,1],.001)
			
			mean `indic2_`k`i''W_`i''
			matrix `Uncond`k`i''_ProbES_W_`i'' = e(b)
			scalar `Uncond`k`i''_ProbES_W_`i'' = round(`Uncond`k`i''_ProbES_W_`i''[1,1],.001)
			
			mean `indic1_`k`i''TT_`i''
			matrix `Cond`k`i''_ProbES_TT_`i'' = e(b)
			scalar `Cond`k`i''_ProbES_TT_`i'' = round(`Cond`k`i''_ProbES_TT_`i''[1,1],.001)
			
			mean `indic2_`k`i''TT_`i''
			matrix `Uncond`k`i''_ProbES_TT_`i'' = e(b)
			scalar `Uncond`k`i''_ProbES_TT_`i'' = round(`Uncond`k`i''_ProbES_TT_`i''[1,1],.001)
			
			
			matrix `Cond`k`i''_ProbES`i'' = `Cond`k`i''_ProbES_W_`i'', `Cond`k`i''_ProbES_TT_`i''
			matrix `Uncond`k`i''_ProbES`i'' = `Uncond`k`i''_ProbES_W_`i'', `Uncond`k`i''_ProbES_TT_`i''
			
			matrix rownames `Cond`k`i''_ProbES`i'' = "Pr(ES>`v')"
			matrix colnames `Cond`k`i''_ProbES`i'' = "Within" "Total"
			
			matrix rownames `Uncond`k`i''_ProbES`i'' = "Pr(ES>`v')"
			matrix colnames `Uncond`k`i''_ProbES`i'' = "Within" "Total"
			}
			
		matrix `Cond_Prob_ES`i'' = `Cond1_ProbES`i''
		matrix `Uncond_Prob_ES`i'' = `Uncond1_ProbES`i''
		
		if `k`i''>1 {
			foreach j of numlist 2/`k`i'' {
				matrix `Cond_Prob_ES`i'' = `Cond_Prob_ES`i'' \ `Cond`j'_ProbES`i''
				matrix `Uncond_Prob_ES`i'' = `Uncond_Prob_ES`i'' \ `Uncond`j'_ProbES`i''
				}
			}
		
		mean `sim_ESW_Cond`i''
		matrix `gtmp1_W`i'' = e(b)
		
		mean `sim_ESW_Uncond`i''
		matrix `gtmp2_W`i'' = e(b)
		
		centile `sim_ESW_Cond`i'', centile(2.5)
		matrix `sim_ESW_Cond`i'_Cent25' =r(c_1)
		
		centile `sim_ESW_Cond`i'', centile(97.5)
		matrix `sim_ESW_Cond`i'_Cent975' =r(c_1)
		
		centile `sim_ESW_Uncond`i'', centile(2.5)
		matrix `sim_ESW_Uncond`i'_Cent25' =r(c_1)
		
		centile `sim_ESW_Uncond`i'', centile(97.5)
		matrix `sim_ESW_Uncond`i'_Cent975' =r(c_1)
		
		matrix `CondES_W`i'' = round(`gtmp1_W`i''[1,1],.01), round(`sim_ESW_Cond`i'_Cent25'[1,1],.01), round(`sim_ESW_Cond`i'_Cent975'[1,1],.01)
		matrix `UncondES_W`i'' = round(`gtmp2_W`i''[1,1],.01), round(`sim_ESW_Uncond`i'_Cent25'[1,1],.01), round(`sim_ESW_Uncond`i'_Cent975'[1,1],.01)
		
		
		mean `sim_ESTT_Cond`i''
		matrix `gtmp1_TT`i'' = e(b)
		
		mean `sim_ESTT_Uncond`i''
		matrix `gtmp2_TT`i'' = e(b)
		
		centile `sim_ESTT_Cond`i'', centile(2.5)
		matrix `sim_ESTT_Cond`i'_Cent25' =r(c_1)
		
		centile `sim_ESTT_Cond`i'', centile(97.5)
		matrix `sim_ESTT_Cond`i'_Cent975' =r(c_1)
		
		centile `sim_ESTT_Uncond`i'', centile(2.5)
		matrix `sim_ESTT_Uncond`i'_Cent25' =r(c_1)
		
		centile `sim_ESTT_Uncond`i'', centile(97.5)
		matrix `sim_ESTT_Uncond`i'_Cent975' =r(c_1)
		
		matrix `CondES_TT`i'' = round(`gtmp1_TT`i''[1,1],.01), round(`sim_ESTT_Cond`i'_Cent25'[1,1],.01), round(`sim_ESTT_Cond`i'_Cent975'[1,1],.01)
		matrix `UncondES_TT`i'' = round(`gtmp2_TT`i''[1,1],.01), round(`sim_ESTT_Uncond`i'_Cent25'[1,1],.01), round(`sim_ESTT_Uncond`i'_Cent975'[1,1],.01)
		
		matrix `Cond_ES`i''= `CondES_W`i'' \ `CondES_TT`i''
		matrix `Uncond_ES`i''= `UncondES_W`i'' \ `UncondES_TT`i''
		
		matrix rownames `Cond_ES`i'' = "Within" "Total"
		matrix colnames `Cond_ES`i'' = "Estimate" "95% LB" "95% UB"
		
		matrix rownames `Uncond_ES`i'' = "Within" "Total"
		matrix colnames `Uncond_ES`i'' = "Estimate" "95% LB" "95% UB"
		}
	
	if `=`=`size''/`=`chns'''<50000 {
		noi disp as error "MCMC size >= 100000 is recommended"
		}
	tokenize `levels'	
	local l
		forvalues i = 1/`=`max'' {
		if "`=`refcat'+0'" != "``i''" {
		local l = `l' + 1
		
		matrix CondES``i'' = `Cond_ES`l''
		local cond`l' CondES``i''
		matrix UncondES``i'' = `Uncond_ES`l''
		local uncond`l' UncondES``i''
	
		
		matrix Cond_ProbES``i'' = `Cond_Prob_ES`l''
		local cprob`l' Cond_ProbES``i''
		
		matrix Uncond_ProbES``i'' = `Uncond_Prob_ES`l''
		local uprob`l' Uncond_ProbES``i''
		}
		}
			
	noisily {
		return matrix Beta = `Beta'
		
		return matrix Cov = `Cov'
		
		cap return matrix schCov = `schCov'
		
		return matrix UschCov = `UschCov' 
		
		return matrix SchEffects = `SchEffects'
				
		forvalues i = 1/`=`max'-1' {
			matrix list `cond`i''
			return matrix `cond`i'' = `cond`i''
	 
			matrix list `uncond`i''
			return matrix `uncond`i'' = `uncond`i''
			
			matrix list `cprob`i''
			return matrix `cprob`i'' = `cprob`i''
			
			matrix list `uprob`i''
			return matrix `uprob`i'' = `uprob`i''
			}
		}
		
	if "`save'" == "" {
		cap erase mcmcCondMST.dta
		cap erase mcmcUncMST.dta
		}
	clear
	use `orig'	
	restore, not
	}
	
end
	

capture program drop baseset
program define baseset, rclass
syntax, max(name) INTervention(varlist fv)

	if regexm("`intervention'", "bn\.") | regexm("`intervention'", "^i\(?([0-9] ?)+\)?\.") {
	noi disp as error "i(numlist) not allowed; you must specify a base level"
	error 198
	}

	local refcat
	if regexm("`intervention'", "([0-9]?)[ ]*\.") local refcat = regexs(1) 
	local allow opt1
		
	if "`refcat'" == "" {
		if regexm("`intervention'", "\(\#*([0-9]?)\)[ ]*\.") local refcat = regexs(1)
		if "`refcat'"!="" local allow opt2
	}
	if "`refcat'" == "" {
		if regexm("`intervention'", "\(([a-zA-Z]+)*\)\.") local refcat = regexs(1)
		if "`refcat'"!="" local allow opt3
		}
	
	fvrevar `intervention', list
	local intervention `r(varlist)'

	levelsof `intervention', local(levels)
	tokenize `levels'
	
	tempname min Max
	scalar `min'=`1'
	scalar `Max' = ``=`max'''
	
	if "`allow'" == "opt1" { 
		forvalues i=1/`=`max'' {
			cap if "`refcat'" != "``i''" local s = `s'+1 /*checking cases were intervention is irregular (i.e. 1 4 9) and user has specified a number of baseline that is not 1,4 or 9 and not below 1 and not above 9*/
			}
		if "`refcat'" != "" {
			if "`refcat'">"`=`Max''" | "`refcat'"<"`=`min''" | "`s'" == "`=`max''" {
			noi disp as error "{bf:Warning:} selected baseline level `refcat' is out of bounds; level `=`Max'' chosen as baseline"
				}
			}
		else {
			local refcat = `=`min''
		}
		if "`s'" == "`=`max''" & "`refcat'" != "`=`min''" {
			local refcat = `=`Max''
			}
	
		if "`refcat'" != "" {
		fvset base `refcat' `intervention'
		}
	}
	else if "`allow'"=="opt2" {
		fvset base ``refcat'' `intervention'
		local refcat = ``refcat''
		}
	else if "`allow'"=="opt3" {
		fvset base `refcat' `intervention'
		if strpos("`refcat'","first") >0 {
		local refcat = `=`min''
		}
		if strpos("`refcat'","last") >0 {
		local refcat = `=`Max''
		}
		if strpos("`refcat'","freq")>0 {
		tempname maximum z
		tab `intervention', matcell(`maximum')
		mata: st_local("matr", strofreal(max(st_matrix("`maximum'"))))
		forvalues i = 1/`=`max''{
		scalar `z' = `maximum'[`i',1]
		if "`matr'"== "`=`z''" local refcat = ``i''
				}
			}
		}
		return local refcat = `refcat'
		end