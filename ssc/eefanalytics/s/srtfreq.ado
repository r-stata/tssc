*! version 1.0.9  02feb2021
capture program drop srtfreq
program define srtfreq, rclass
version 15.1

syntax varlist(fv) [if] [in], INTervention(varlist fv max=1) [, NPerm(integer 0) NBoot(integer 0) SEED(integer 1020252) SHOWprogress noIsily *] 
quietly {
	preserve
	
	if "`nperm'" != "0" {
	cap drop PermC_I* PermUnc_I*
	}
	if "`nboot'" != "0" {
	cap drop BootC_I* BootUnc_I*
	}
	
	tempfile orig
	save `orig'
	
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
	
	fvrevar `varlist', list
	local varlist_clean `r(varlist)'
	
	marksample touse
	markout `touse' `intervention'
	keep if `touse'
	

	tempvar r 
	tempname test1 test0 Beta Beta1 Beta2 b Sigma1 Sigma2 Sigma x max nt nc N_total colnumber 
	
	gettoken depvar indepvar: varlist
	
	tab `intervention'
	scalar `max' = r(r)
	
	baseset, max(`max') intervention(`intervraw')
	local refcat `r(refcat)'
	
	levelsof `intervention', local(levels)
	tokenize `levels'
	
	tempfile srt
	save `srt'
	
	tempfile srt2
	save `srt2'

	reg `depvar', `options'
	scalar `Sigma2' = e(rmse)
	
	`isily' reg `depvar' i.`intervention' `indepvar' , `options'
	
	scalar `Sigma1' = e(rmse)
	matrix `Beta' = e(b)
	matrix rownames `Beta' = "Beta"
	matrix Coef = `Beta'[1,1..`=`max'']
	
	mata: st_matrix("Coef", select(st_matrix("Coef"), st_matrix("Coef") :!= 0))

	matrix coef=Coef'
	
	matrix `Sigma' = round(`Sigma1'^2,.01),round(`Sigma2'^2,.01)
	matrix rownames `Sigma' = "Sigma2"
	matrix colnames `Sigma' = "Conditional" "Unconditional"
	
	scalar `colnumber' = colnumb(r(table),"`=`refcat'+0'b.`intervention'")
	
	if "`=`colnumber''"=="1" { 
		matrix `test0' = r(table)[1...,2...]
		}
	else {
		matrix `test0' = r(table)[1...,1..`=`colnumber'-1'],r(table)[1...,`=`colnumber'+1'...]
		}
	matrix `test1' = `test0'
	forvalues i = 1/`=rowsof(`test0')' {
		forvalues j = 1/`=colsof(`test0')' {
			matrix `test1'[`i',`j']= round(`test0'[`i',`j'],.01)
		}
	}
	
	matrix `Beta1' = (`test1'["b", .] \ `test1'["ll".."ul", . ])
	matrix `Beta2'=`Beta1''
	matrix colnames `Beta2' = "Estimate" "95% LB" "95% UB"

	
	forvalues i = 1/`=`max''{
		if "`=`refcat'+0'" != "``i''" {
			local rowname `rowname' "`intervention'``i''"
			local fnc `fnc' `i'
			}
		else {
		local m `i'
		}
		}
	tokenize `fnc'
	qui tab `intervention', generate(brkn_fctor) matcell(`x') /* extract matrix x of broken Intervention to use in calculations below*/
	drop brkn_fctor1
	clear


	forvalues s = 1/2 {
		forvalues j = 1/`=`max'-1' {
		tempname cd`j'`s' varcd`j'`s' secd`j'`s' cdlb`j'`s' cdub`j'`s' jdf g`j'`s' varg`j'`s' seg`j'`s' 	glb`j'`s' gub`j'`s' A`j'`s' g`j'`s'
			scalar `cd`j'`s'' = (coef[`j',1]/ `Sigma`s'' )
			scalar `nt' = `x'[`m',1]
			scalar `nc' = `x'[``j'',1]
			scalar `varcd`j'`s''= ((`nt'+`nc')/(`nt'*`nc')+`cd`j'`s''^2/(2*(`nt'+`nc')))
			scalar `secd`j'`s'' = sqrt(`varcd`j'`s'')
			scalar `cdlb`j'`s'' = (`cd`j'`s'' - 1.96*`secd`j'`s'')
			scalar `cdub`j'`s'' = (`cd`j'`s'' + 1.96*`secd`j'`s'')
			scalar `jdf'     = (1 - (3/(4*(`nt'+`nc'-2)-1)))
			scalar `g`j'`s''    = (`jdf'*`cd`j'`s'')
			scalar `varg`j'`s'' = (`jdf'^2 * `varcd`j'`s'')
			scalar `seg`j'`s''  = sqrt(`varg`j'`s'')
			scalar `glb`j'`s''  = (`g`j'`s'' - 1.96*`seg`j'`s'')
			scalar `gub`j'`s''  = (`g`j'`s'' + 1.96*`seg`j'`s'')
			matrix `A`j'`s'' = round(`g`j'`s'',.01),round(`glb`j'`s'',.01),round(`gub`j'`s'',.01)
			}
		}
		forvalues s = 1/2 {
				tempname G`s' P`s'
				matrix `G`s'' = `A1`s''
				matrix `P`s'' = round(`g1`s'',.01)
				}
		
		forvalues s = 1/2 {
			if `=`max'-1'>1 {
				matrix `G`s'' = `A1`s''
				foreach i of numlist 2/`=`max'-1'{ /*extract g's (coefficients of the long calculation to be used later)*/
					matrix `G`s'' = `G`s'' \ `A`i'`s''
					}
				matrix `P`s'' = round(`g1`s'',.01)
				foreach i of numlist 2/`=`max'-1'{
					matrix `P`s'' = (`P`s'' \ round(`g`i'`s'',.01))
					}
				}
			}
		matrix CondES = `G1'
		matrix rownames CondES = `rowname'
		matrix colnames CondES = "Estimate" "95% LB" "95% UB"
		matrix UncondES = `G2'
		matrix rownames UncondES = `rowname'
		matrix colnames UncondES = "Estimate" "95% LB" "95% UB"
		use `srt'
	
   //====================================================//	
  //===================                =================//	
 //==================  PERMUTATIONS  ==================//
//=================                ===================//
//====================================================//
	
	if "`nperm'" != "0" {
		noisily di as txt "  Running Permutations..."
		
		set seed `seed'

		if `nperm'<1000 	{
			display as error "error: nPerm must be greater than 1000"
			error 7
			}
		forvalues k = 1/`nperm' {
		if "`showprogress'" != "" {	
				if !mod(`k', 100) {
				noi di _c "`k'"
				}
			else {
				if !mod(`k', 10) {
					noi di _c "." 
					}
				}
			}
			
			tempfile permute
			keep `intervention'
			tempvar shuffle
			gen `shuffle' = runiform()
			sort `shuffle' `intervention'
			drop `shuffle'
			save `permute'
			use `srt2'
			merge 1:1 _n using `permute', update replace nogenerate
			tempfile srt2
			save `srt2'
			gettoken depvar indepvar: varlist
			
			reg `depvar', `options'
			scalar `Sigma2' = e(rmse)
		
			`isily' reg `depvar' i.`intervention' `indepvar' , `options'
			scalar `Sigma1' = e(rmse)
			matrix `b' = e(b)
			capture drop coef
			matrix Coef = `b'[1,1..`=`max'']
			mata: st_matrix("Coef", select(st_matrix("Coef"), st_matrix("Coef") :!= 0))
			matrix coef=Coef'
		
			qui tab `intervention', generate(brkn_fctor) matcell(`x')
			drop brkn_fctor1
			clear

			forvalues s = 1/2 {
				forvalues j = 1/`=`max'-1' {
				tempname c`k'd`j'`s' var`k'cd`j'`s' g`k'`j'`s'
					scalar `c`k'd`j'`s'' = (coef[`j',1]/ `Sigma`s'' )
					scalar `nt' = `x'[`m',1]
					scalar `nc' = `x'[``j'',1]
					scalar `var`k'cd`j'`s''= ((`nt'+`nc')/(`nt'*`nc')+`c`k'd`j'`s''^2/(2*(`nt'+`nc')))
					scalar `jdf'     = (1 - (3/(4*(`nt'+`nc'-2)-1)))
					scalar `g`k'`j'`s''    = (`jdf'*`c`k'd`j'`s'')
					}
				}
			use `srt2'
			}
			clear
			use `srt'
			count
			scalar `N_total' = `r(N)'
			if `nperm'>`=`N_total'' {
				set obs `nperm'
				}
				
		forvalues k = 1/`nperm' {
			forvalues s = 1/2 {
				forvalues i = 1/`=`max'-1' {
					capture gen Treat_PEst`s'_`i' = .
					replace Treat_PEst`s'_`i' = `g`k'`i'`s'' in `k'
					}
				}
			}

		tokenize `levels'
		local m
		forvalues i = 1/`=`max'' {
			if "`=`refcat'+0'" != "``i''" {
			local m = `m' + 1
			rename (Treat_PEst1_`m' Treat_PEst2_`m') (PermC_I``i'' PermUnc_I``i'')
			}
		}
		keep PermC_I* PermUnc_I*
		
		tempfile perMES
		save `perMES'
		
		use `orig'
		merge 1:1 _n using `perMES', nogenerate
		tempfile orig
		save `orig'
		
		if "`showprogress'" != "" {
				noi di as txt ""
				}
		noi di as txt "  Permutations completed."
	} /*if nperm*/



   //====================================================//	
  //====================              ==================//	
 //===================	BOOTSTRAPS	===================//
//==================              ====================//
//====================================================//	
		
		if "`nboot'" != "0"  {
		clear 
		use `srt'
		count
		cap scalar `N_total' = `r(N)'
		
		noisily di as txt "  Running Bootstraps..."
		if `nboot'<1000 {
			display as error "error: nBoot must be greater than 1000"
			error 7
			}
		
		keep `varlist_clean' `intervention'
		
		
		tempfile touseit
		save `touseit'

		set seed `seed'

		forvalues i = 1/`nboot' {	
		if "`showprogress'" != "" {	
				if !mod(`i', 100) {
				noi di _c "`i'"
				}
			else {
				if !mod(`i', 10) {
					noi di _c "." 
					}
				}
			}

			bsample
			keep `varlist_clean' `intervention'
			gettoken depvar indepvar: varlist
			
			reg `depvar', `options'
			scalar `Sigma2' = e(rmse)
			
			`isily' reg `depvar' i.`intervention' `indepvar', `options'
			scalar `Sigma1' = e(rmse)
			
			matrix `b' = e(b)
			capture drop Coef
			matrix Coef = `b'[1,1..`=`max'']
			mata: st_matrix("Coef", select(st_matrix("Coef"), st_matrix("Coef") :!= 0))
			matrix Coef=Coef'
			
		forvalues s = 1/2 {
			forvalues j = 1/`=`max'-1' {
			tempvar Treat`j'_RM`i'SE`s'
				scalar `Treat`j'_RM`i'SE`s'' = (Coef[`j',1]/ `Sigma`s'' )
				}
			}
			clear
			use `touseit'
			}
			if `nboot'>`=`N_total'' {
				set obs `nboot'
				}
		forvalues i = 1/`nboot' {
			forvalues s = 1/2 {
				forvalues j = 1/`=`max'-1' {
					cap gen Treat`j'_RMSE`s' = .
					replace Treat`j'_RMSE`s' = `Treat`j'_RM`i'SE`s'' in `i'
					}
				}
			}
		
		forvalues s=1/2 {
			forvalues i=1/`=`max'-1' {
				centile Treat`i'_RMSE`s', centile(2.5)
				tempname x_`i'`s'  y_`i'`s'
				scalar `x_`i'`s''=r(c_1)
				centile Treat`i'_RMSE`s', centile(97.5)
				scalar `y_`i'`s''=r(c_1)
				}
				tempname L1`s' L2`s' L`s'
			matrix `L1`s''=round(`x_1`s'',.01)
			matrix `L2`s''=round(`y_1`s'',.01)
	
			if `=`max'-1'>1 {
				foreach i of numlist 2/`=`max'-1' {
					matrix `L1`s''=`L1`s'' \ round(`x_`i'`s'',.01)
					}
				foreach i of numlist 2/`=`max'-1' {
					matrix `L2`s''=`L2`s'' \ round(`y_`i'`s'',.01)
					}
				}
			matrix `L`s'' = (`P`s'',`L1`s'',`L2`s'')
			matrix rownames `L`s'' = `rowname'
			matrix colnames `L`s'' = "Estimate" "95% LB (BT)" "95% UB (BT)"
			}
		tokenize `levels'
		local m
		forvalues i = 1/`=`max'' {
			if "`=`refcat'+0'" != "``i''" {
			local m = `m' + 1
			rename (Treat`m'_RMSE1 Treat`m'_RMSE2) (BootC_I``i'' BootUnc_I``i'')
			}
		}

		keep BootC_I* BootUnc_I*
		tempfile origBoot
		save `origBoot'
		clear
		use `orig'
		merge 1:1 _n using `origBoot', nogenerate
		tempfile orig
		save `orig'
		
		if "`showprogress'" != "" {
				noi di as txt ""
				}
		noi di as txt "  Bootstraps completed."
	 matrix CondES = `L1'
	 matrix UncondES = `L2'
		}/*if nboot*/
	cap noi {
		noisily {	
			return matrix Beta = `Beta2'
			return matrix Sigma2 = `Sigma'
			
			matrix list CondES
			return matrix CondES = CondES
			
			matrix list UncondES 
			return matrix UncondES = UncondES
			}
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
			if "`refcat'" != "``i''" local s = `s'+1 /*checking cases were intervention is irregular (i.e. 1 4 9) and user has specified a number of baseline that is not 1,4 or 9 and not below 1 and not above 9*/
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
