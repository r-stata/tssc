*! version 1.0.9  02feb2021
capture program drop srtbayes
program define srtbayes, rclass
version 16
quietly {
	preserve
	
	tempfile orig
	save `orig'

	syntax varlist(fv) [if] [in], INTervention(varlist fv max=1) [, THReshold(numlist) SEPCHains DIAGnostics noIsily SAVE *] 
	
	
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
	markout `touse' `intervention'
	keep if `touse'
	
	tempname max Cond_Sigma Uncond_Sigma b Beta Sigma size chns test1 min Max

	tab `intervention'
	scalar `max' = r(r)
	
	baseset, max(`max') intervention(`intervraw')
	local refcat `r(refcat)'
	
	levelsof `intervention', local(levels)
	tokenize `levels'
	
	
	gettoken depvar indepvar: varlist
	
	noi bayes, saving(mcmcUnc, replace) `isily' `options': reg `depvar'
	
	noi bayes, saving(mcmcCond, replace) `isily' `options': reg `depvar' i.`intervention' `indepvar'
	
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
	
	matrix `test1' = `b'[1.."`depvar':_cons", "Mean"], `b'[1.."`depvar':_cons", "CrI lower".."CrI upper"]
	matrix `Beta' = `test1'
	forvalues i = 1/`=rowsof(`test1')' {
		forvalues j = 1/`=colsof(`test1')' {
			matrix `Beta'[`i',`j']= round(`test1'[`i',`j'],.01)
		}
	}
	matrix colnames `Beta' = "Estimate" "95% LB" "95% UB"
	
	use mcmcUnc.dta,clear
	expand _frequency
	
	lookfor "sigma2"
	rename `r(varlist)' Sigma_Uncond
	keep Sigma_Uncond
	
	tempfile mcmcUnc
	save `mcmcUnc'
	
	use mcmcCond.dta, clear
	expand _frequency
	
	lookfor "sigma2"
	rename `r(varlist)' Sigma_Cond
	
	lookfor "b.`intervention'"
	drop `r(varlist)'
	
	lookfor ".`intervention'"
	 foreach v in `r(varlist)' {
		local j = `j' + 1
		rename `v' Sim_Beta_t`j'
		}
	
	merge 1:1 _n using `mcmcUnc', nogenerate
	
	keep Sim_Beta_t1-Sim_Beta_t`=`max'-1' Sigma_Cond Sigma_Uncond
	
	tempfile mcmcCond
	save `mcmcCond'

	mean Sigma_Cond
	matrix `Cond_Sigma' = round(e(b)[1,1],.01)
	
	mean Sigma_Uncond
	matrix `Uncond_Sigma' = round(e(b)[1,1],.01)
	
	matrix `Sigma' = `Cond_Sigma', `Uncond_Sigma'
	matrix rownames `Sigma' = "Sigma2"
	matrix colnames `Sigma' = "Conditional" "Unconditional"
	
	tempvar Sigma_CondSqrt Sigma_UncondSqrt
	gen double `Sigma_CondSqrt' = sqrt(Sigma_Cond)
	gen double `Sigma_UncondSqrt' = sqrt(Sigma_Uncond)
	
	forvalues i = 1/`=`max'-1' {
		tempvar sim_ES1_`i' sim_ES2_`i' indic1_`i' indic2_`i' 
		tempname sim_ES1_`i'_Cent25 sim_ES1_`i'_Cent975 sim_ES2_`i'_Cent25 sim_ES2_`i'_Cent975 CondES`i' UncondES`i' gtmp1_`i' gtmp2_`i' Prob_ES`i'
		
		gen double `sim_ES1_`i'' = Sim_Beta_t`i'/`Sigma_CondSqrt'
		gen double `sim_ES2_`i'' = Sim_Beta_t`i'/`Sigma_UncondSqrt'
		
		foreach v of numlist `threshold'{
			local k`i' =`k`i''+1
			tempvar indic1_`k`i''_`i' indic2_`k`i''_`i' 
			tempname  Cond`k`i''_ProbES0_`i' Uncond`k`i''_ProbES0_`i' Prob`k`i''ES`i'
			 
			gen double `indic1_`k`i''_`i'' = 0
			gen double `indic2_`k`i''_`i'' = 0
		
			replace `indic1_`k`i''_`i'' = 1 if `sim_ES1_`i''>`v'
			mean `indic1_`k`i''_`i''
			matrix `Cond`k`i''_ProbES0_`i'' = e(b)
			scalar `Cond`k`i''_ProbES0_`i'' = round(`Cond`k`i''_ProbES0_`i''[1,1],.001)
			
			replace `indic2_`k`i''_`i'' = 1 if `sim_ES2_`i''>`v'
			mean `indic2_`k`i''_`i''
			matrix `Uncond`k`i''_ProbES0_`i'' = e(b)
			scalar `Uncond`k`i''_ProbES0_`i'' = round(`Uncond`k`i''_ProbES0_`i''[1,1],.001)
			
			matrix `Prob`k`i''ES`i''=(`Cond`k`i''_ProbES0_`i'',`Uncond`k`i''_ProbES0_`i'')
			matrix rownames `Prob`k`i''ES`i'' = "Pr(ES>`v')"
			matrix colnames `Prob`k`i''ES`i'' = "Conditional" "Unconditional"
			}
			
		matrix `Prob_ES`i'' = `Prob1ES`i''
		
		if `k`i''>1 {
			foreach j of numlist 2/`k`i'' {
				matrix `Prob_ES`i'' = `Prob_ES`i'' \ `Prob`j'ES`i''
				}
			}
		
		
		mean `sim_ES1_`i''
		matrix `gtmp1_`i'' = e(b)
		
		mean `sim_ES2_`i''
		matrix `gtmp2_`i'' = e(b)
		
		centile `sim_ES1_`i'', centile(2.5)
		matrix `sim_ES1_`i'_Cent25' =r(c_1)
		
		centile `sim_ES1_`i'', centile(97.5)
		matrix `sim_ES1_`i'_Cent975' =r(c_1)
		
		centile `sim_ES2_`i'', centile(2.5)
		matrix `sim_ES2_`i'_Cent25' =r(c_1)
		
		centile `sim_ES2_`i'', centile(97.5)
		matrix `sim_ES2_`i'_Cent975' =r(c_1)
		
		matrix `CondES`i'' = round(`gtmp1_`i''[1,1],.01), round(`sim_ES1_`i'_Cent25'[1,1],.01), round(`sim_ES1_`i'_Cent975'[1,1],.01)
		matrix `UncondES`i'' = round(`gtmp2_`i''[1,1],.01), round(`sim_ES2_`i'_Cent25'[1,1],.01), round(`sim_ES2_`i'_Cent975'[1,1],.01)
		
		} 
		
		matrix CondES = `CondES1'
		matrix UncondES = `UncondES1'
		if `=`max''>2 {
			foreach i of numlist 2/`=`max'-1' {
				matrix CondES = CondES \ `CondES`i''
				matrix UncondES = UncondES \ `UncondES`i''
				}
			}

		forvalues i = 1/`=`max''{
		if "`intervention'`=`refcat'+0'" != "`intervention'``i''" {
			local rowname `rowname' "`intervention'``i''"
			}
		}
		
		local m
		forvalues i = 1/`=`max'' {
		if "`=`refcat'+0'" != "``i''" {
		local m = `m' + 1
		
		matrix ProbES``i'' = `Prob_ES`m''
		local prob`m' ProbES``i''  
		}
		}
		
		matrix rownames CondES = `rowname'
		matrix colnames CondES = "Estimate" "95% LB" "95% UB"
		
		matrix rownames UncondES = `rowname'
		matrix colnames UncondES = "Estimate" "95% LB" "95% UB"
		
		if `=`=`size''/`=`chns'''<50000 {
			noi disp as error "MCMC size >= 100000 is recommended"
			}
		
			
		return matrix Beta = `Beta'
	
		return matrix Sigma2 = `Sigma'
		noisily {
			matrix list CondES
			return matrix CondES = CondES
	 
			matrix list UncondES
			return matrix UncondES = UncondES

				forvalues i = 1/`=`max'-1' {				
					matrix list `prob`i''
					return matrix `prob`i'' = `prob`i''
				}
			}
	clear
	use `orig'
	
	if "`save'" == "" {
		cap erase mcmcCond.dta
		cap erase mcmcUnc.dta
		}
	
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