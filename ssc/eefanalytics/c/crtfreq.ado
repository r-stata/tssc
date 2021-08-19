*! version 1.0.9  02feb2021
capture program drop crtfreq
program define crtfreq, rclass
version 15.1
syntax varlist(fv) [if] [in], INTervention(varlist fv max=1) RANdom(varlist max=1) [, NPerm(integer 0) NBoot(integer 0) SEED(integer 1020252) SHOWprogress noIsily ML REML *]

quietly {
	preserve

	if "`nperm'" != "0" {
	cap drop PermC_I*_W PermUnc_I*_W PermC_I*_T PermUnc_I*_T
	}
	if "`nboot'" != "0" {
	cap drop BootC_I*_W BootC_I*_T BootUnc_I*_W BootUnc_I*_T
	}
	
	tempfile Original
	save `Original'
	
	local intervraw: copy local intervention
	
	fvrevar `intervention', list
	local intervention `r(varlist)'
	
	local maximization reml
	if "`ml'" != "" & "`reml'" != "" {
	noi disp as error "ml and reml may not be specified at the same time"
	error 198
	}
	if "`ml'" != "" {
		local maximization
		}
	if "`reml'" != "" {
		}
	
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
	markout `touse' `intervention' `random'
	keep if `touse'

	tempfile crt
	save `crt'
	
	tempfile crt2
	save `crt2'
	
	tempname X Beta Beta1 test1 test0 b0 Cov schRand X max chk b id_var_col cluster_variance2 res_var_col res_variance1 res_variance2 Total2 ICC2 ICC1 B cluster_variance1 Total1 A N_total colnumber min Max
	tempvar r total_chk
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
	if `chk'>0 {
	display as error "error: This is not a CRT design"
	error 459
	}
	
	clear 
	use `crt'
	
	baseset, max(`max') intervention(`intervraw')
	local refcat `r(refcat)'
	
	tempfile crt
	save `crt'
	
	tempfile crt2
	save `crt2'
	
	levelsof `intervention', local(levels)
	tokenize `levels'
	
	sort `random'
	gettoken depvar indepvars: varlist
	
	mixed `depvar' || `random':, `options' `maximization'
	matrix `b' = e(b)
	
	scalar `id_var_col' = colnumb(`b', "lns1_1_1:_cons")
	scalar `cluster_variance2' = exp(`b'[1, `id_var_col'])^2

	scalar `res_var_col' = colnumb(`b', "lnsig_e:_cons")
	scalar `res_variance2' = exp(`b'[1, `res_var_col'])^2
	scalar `Total2' = `res_variance2' + `cluster_variance2'

	scalar `ICC2' = `cluster_variance2'/`Total2'
	
	matrix `B' = (round(`cluster_variance2',.01),round(`res_variance2',.01),round(`Total2',.01),round(`ICC2',.01))
	
	`isily' mixed `depvar' i.`intervention' `indepvars' || `random':, `options' `maximization'
	matrix `test0' = r(table)[1...,1.."`depvar':_cons"]
	scalar `colnumber' = colnumb(`test0',"`=`refcat'+0'b.`intervention'")
	
	if "`=`colnumber''"=="1" { 
		matrix `test0' = `test0'[1...,2...]
		}
	else {
		matrix `test0' = `test0'[1...,1..`=`colnumber'-1'],`test0'[1...,`=`colnumber'+1'...]
		}
	matrix `test1' = `test0'
	forvalues i = 1/`=rowsof(`test0')' {
		forvalues j = 1/`=colsof(`test0')' {
			matrix `test1'[`i',`j']= round(`test0'[`i',`j'],.01)
		}
	}
		
	matrix `Beta1' = (`test1'["b", .] \ `test1'["ll".."ul", . ])
	matrix `Beta'=`Beta1''
	matrix colnames `Beta' = "Estimate" "95% LB" "95% UB"

	matrix `b' = e(b)

	scalar `id_var_col' = colnumb(`b', "lns1_1_1:_cons")
	scalar `cluster_variance1' = exp(`b'[1, `id_var_col'])^2

	scalar `res_var_col' = colnumb(`b', "lnsig_e:_cons")
	scalar `res_variance1' = exp(`b'[1, `res_var_col'])^2
	scalar `Total1' = `res_variance1' + `cluster_variance1'

	scalar `ICC1' = `cluster_variance1' / `Total1'

	matrix `A' = (round(`cluster_variance1',.01),round(`res_variance1',.01),round(`Total1',.01),round(`ICC1',.01))
	
	matrix `Cov' = (`A' \ `B')
	matrix colnames `Cov' = "Schools" "Pupils" "Total" "ICC"
	matrix rownames `Cov' = "Conditional" "Unconditional"
	
	predict Intercept, reffects
	
	tempfile beta1
	save `beta1'
	
	matrix Coef = `b'[1,1..`=`max'']
	
	mata: st_matrix("Coef", select(st_matrix("Coef"), st_matrix("Coef") :!= 0))
	
	
	matrix Coef = Coef'
	
	clear

	use `beta1'
	collapse Intercept, by(`random')
	mkmat Intercept `random', matrix(`test1')
	matrix `schRand'=`test1'
	forvalues i = 1/`=rowsof(`test1')' {
		forvalues j = 1/`=colsof(`test1')' {
			matrix `schRand'[`i',`j']= round(`test1'[`i',`j'],.01)
		}
	}
	clear
	use `crt'
	
	foreach i of numlist 1/`=`max''{
		if "`=`refcat'+0'" != "``i''" {
			local rowname `rowname' "`intervention'``i''"
			local two `two' broken_factor`i'
			}
		else {
		local one `one' broken_factor`i'
		}
		}
	/*g.within*/

	tab `intervention', generate(broken_factor)


	local broken_treatment
	foreach i of numlist 1/`=`max'' {
		local broken_treatment `broken_treatment' broken_factor`i' /*store all brokn_fctors in local*/
		}
	rename (`one' `two') (`broken_treatment') /*rename broken_factors based on new ref category (i.e. broken2 broken1 broken3 to broken1 broken2 broken3)*/
	forvalues s = 1/2 {
		forvalues i = 1/`=`max'-1' {
			tempfile forloop
			save `forloop'
			
			tempname d`s'w`i' MatNt`i' Nc`i' N`i' Nt`i' Mc`i' Mt`i' M`i' Nu
			
			scalar `d`s'w`i'' = Coef[`i',1] / sqrt( `res_variance`s'' )
	
			tab `random' broken_factor`=`i'+1', matcell(Br_F`i')  /*because `=`max'-1' = 2 , broken factor is 1,2,3 but we need 2,3 because 1 is baseline*/
			svmat Br_F`i'
	
			total Br_F`i'1 /*Br_F will always be 0/1 ( Br_F`i'1 is 0 and Br_F`i'2 is 1)*/
			matrix `MatNt`i'' = e(b) 
			scalar `Nc`i'' = `MatNt`i''[1,1]
	
			total Br_F`i'2
			matrix `MatNt`i'' = e(b)
			scalar `Nt`i'' = `MatNt`i''[1,1]
			
			scalar `N`i'' = `Nc`i'' + `Nt`i'' 
			
			tab `random' broken_factor`=`i'+1' if broken_factor`=`i'+1'==1, matcell(nt`i') 
			scalar `Mt`i''= r(r) 
			
			tab `random' broken_factor`=`i'+1' if broken_factor`=`i'+1'==0, matcell(nc`i') 
			scalar `Mc`i''= r(r) 
			
			scalar `M`i'' = `Mc`i'' + `Mt`i''
			clear
			use `forloop'
			}
		

	scalar `Nu' = `=`max'-1'
	
	mata func3("`Nu'", "nt", "nc") 
	
	forvalues i = 1/`=`max'-1' {
	tempname nsim1`i' nsim2`i' nsimTotal`i' vterm1`i' v`s'term2`i' v`s'term3`i' s`s'te`i' L`s'B`i' U`s'B`i' Out`s'put`i' nut`i' nuc`i' d`s't1`i' d`s't2`i' d`s'tTotal`i' B`i' At`i' Ac`i' A`i' v`s'term1Tot`i' v`s'term2Tot`i' v`s'term3Tot`i' s`s'teTot`i' L`s'Btot`i' U`s'Btot`i' Out`s'putTot`i' Out`s'putG`i'
	
		scalar `nsim1`i''     = (`Nc`i'' *sqnt`i')/(`Nt`i''*`N`i'')
		scalar `nsim2`i''     = (`Nt`i'' * sqnc`i')/( `Nc`i''*`N`i'')
		scalar `nsimTotal`i'' = `nsim1`i'' + `nsim2`i''
		scalar `vterm1`i''    = ((`Nt`i''+`Nc`i'')/(`Nt`i''*`Nc`i''))
		scalar `v`s'term2`i''    = (((1+( `nsimTotal`i''-1) * `ICC`s'' ))/(1- `ICC`s''))
		scalar `v`s'term3`i''    = ((`d`s'w`i''^2)/(2*(`N`i'' - `M`i'')))
		scalar `s`s'te`i''       = sqrt( `vterm1`i'' * `v`s'term2`i'' + `v`s'term3`i'')
		scalar `L`s'B`i''        = (`d`s'w`i'' -1.96* `s`s'te`i'')
		scalar `U`s'B`i''        = (`d`s'w`i'' +1.96* `s`s'te`i'')
		matrix `Out`s'put`i''    = (round(`d`s'w`i'',.01), round(`L`s'B`i'',.01), round(`U`s'B`i'',.01))
		
		
		/*End of g.within*/
		
		/*g.total*/
		
		scalar `nut`i''     = ((`Nt`i''^2-sqnt`i')/(`Nt`i'' *( `Mt`i'' -1)))
		scalar `nuc`i''     = ((`Nc`i''^2-sqnc`i')/(`Nc`i''*(`Mc`i''-1)))
		scalar `d`s't1`i''     = Coef[`i',1] / sqrt( `Total`s'' )
		scalar `d`s't2`i''     = sqrt(1-`ICC`s'' * ((( `N`i'' - `nut`i'' * `Mt`i'' - `nuc`i'' * `Mc`i'' ) + `nut`i'' + `nuc`i'' -2) / ( `N`i'' -2)))
		scalar `d`s'tTotal`i'' = ( `d`s't1`i'' * `d`s't2`i'' )
		
		scalar `B`i''  = (`nut`i''*(`Mt`i''-1)+`nuc`i''*(`Mc`i''-1))
		scalar `At`i'' = ((`Nt`i''^2*sqnt`i'+(sqnt`i')^2-2*`Nt`i''*qnt`i')/`Nt`i''^2)
		scalar `Ac`i'' = ((`Nc`i''^2*sqnc`i'+(sqnc`i')^2-2*`Nc`i''*qnc`i')/`Nc`i''^2)
	
		scalar `A`i''  = (`At`i'' + `Ac`i'')
	
		scalar `v`s'term1Tot`i'' = (((`Nt`i''+`Nc`i'')/(`Nt`i''*`Nc`i''))*(1+(`nsimTotal`i''-1)*`ICC`s''))
		scalar `v`s'term2Tot`i'' = (((`N`i''-2)*(1-`ICC`s'')^2+`A`i''*`ICC`s''^2+2*`B`i''*`ICC`s''*(1-`ICC`s''))*`d`s'tTotal`i''^2)
		scalar `v`s'term3Tot`i'' = (2*(`N`i''-2)*((`N`i''-2)-`ICC`s''*(`N`i''-2-`B`i'')))
		scalar `s`s'teTot`i''    = sqrt(`v`s'term1Tot`i''+`v`s'term2Tot`i''/`v`s'term3Tot`i'')
		scalar `L`s'Btot`i''     = (`d`s'tTotal`i''-1.96*`s`s'teTot`i'') 
		scalar `U`s'Btot`i''		= (`d`s'tTotal`i''+1.96*`s`s'teTot`i'')
		matrix `Out`s'putTot`i'' = (round(`d`s'tTotal`i'',.01), round(`L`s'Btot`i'',.01), round(`U`s'Btot`i'',.01))
		
		scalar drop sqnt`i' sqnc`i' qnt`i' qnc`i'
		
		matrix `Out`s'putG`i'' = ( `Out`s'put`i'' \ `Out`s'putTot`i'' )
		matrix rownames `Out`s'putG`i'' = "Within" "Total"
		matrix colnames `Out`s'putG`i'' = "Estimate" "95% LB" "95% UB"
		}
	}
	local g
	forvalues i = 1/`=`max'' {
		if "`=`refcat'+0'" != "``i''" {
		local g = `g' + 1
		
		matrix CondES``i'' = `Out1putG`g''
		local cond`g' CondES``i'' 
		matrix UncondES``i'' = `Out2putG`g''
		local uncond`g' UncondES``i'' 
		}
		}
	tempfile touseit
	save `touseit'
		
	   //====================================================//	
	  //===================                =================//	
	 //==================  PERMUTATIONS  ==================//
	//=================                ===================//
   //====================================================//
	
	if "`nperm'" != "0"  {
		count
		scalar `N_total' = `r(N)'
		
			if `nperm'<1000 {
				display as error "error: nPerm must be greater than 1000"
				error 7
				}
		noisily di as txt "  Running Permutations..."
		forvalues j = 1/`nperm' {
			if "`seed'" == "1020252" {
				local defseed = `=12890*`j'+1'
				set seed `defseed'
				}
			else {
				local seeds = `=`seed'*`j'+1'
				set seed `seeds'
				}
			if "`showprogress'" != "" {	
					if !mod(`j', 100) {
					noi di _c "`j'"
					}
				else {
					if !mod(`j', 10) {
						noi di _c "." 
						}
					}
				}
			tempvar new
			keep `intervention' `random'
			collapse `intervention', by(`random')
			tempfile first
			save `first'
			keep `random'
			tempfile second
			save `second'
			use `first'
			tempvar shuffle
			gen double `shuffle'=runiform()
			drop `random'
			sort `shuffle'
			gen `new'=_n
			drop `shuffle'
			sort `new'
			merge 1:1 _n using `second', nogenerate
			drop `new'
			tempfile clust
			save `clust'
			use `crt'
			merge m:1 `random' using `clust', update replace nogenerate
			
			`isily' mixed `depvar' i.`intervention' `indepvars' || `random':, `options' `maximization'
			matrix `b' = e(b)

			scalar `id_var_col' = colnumb(`b', "lns1_1_1:_cons")
			scalar `cluster_variance1' = exp(`b'[1, `id_var_col'])^2

			scalar `res_var_col' = colnumb(`b', "lnsig_e:_cons")
			scalar `res_variance1' = exp(`b'[1, `res_var_col'])^2
			scalar `Total1' = `res_variance1' + `cluster_variance1'

			scalar `ICC1' = `cluster_variance1'/`Total1'

			matrix Coef = `b'[1,1..`=`max'']
			
	mata: st_matrix("Coef", select(st_matrix("Coef"), st_matrix("Coef") :!= 0))
	
			matrix Coef = Coef'
			clear
		
			use `crt'

	/*g.within*/
			forvalues s = 1/2 {
			
				forvalues i = 1/`=`max'-1' {
				tempname  d`s'w`i'`j' d`s't1`i'`j' d`s't2`i'`j' d`s'tTotal`i'`j' 
				
					scalar `d`s'w`i'`j''        = Coef[`i',1]/sqrt(`res_variance`s'')
					scalar `d`s't1`i'`j''     = Coef[`i',1]/sqrt(`Total`s'')
					scalar `d`s't2`i'`j''     = sqrt(1-`ICC`s''*(((`N`i''-`nut`i''*`Mt`i''-`nuc`i''*`Mc`i'')+`nut`i''+`nuc`i''-2)/(`N`i''-2)))
					scalar `d`s'tTotal`i'`j'' = (`d`s't1`i'`j''*`d`s't2`i'`j'')
					}
				}
			clear
			use `touseit'
			} /*nperm*/
			forvalues s = 1/2 {
				forvalues j = 1/`nperm' {
					forvalues i = 1/`=`max'-1' {
						if `nperm'>`=`N_total'' {
							set obs `nperm'
							}
						capture gen double Perm`s'_T`i'_W=.
						capture gen double Perm`s'_T`i'_T=.
						replace Perm`s'_T`i'_W = `d`s'w`i'`j'' in `j'
						replace Perm`s'_T`i'_T = `d`s'tTotal`i'`j'' in `j'
						}
					}
				}

		if "`showprogress'" != "" {
			noi di as txt ""
			}
		noisily di as txt "  Permutations completed."
		tempfile crt
		save `crt'
		
		local f
		forvalues i = 1/`=`max'' {
			if "`=`refcat'+0'" != "``i''" {
			local f = `f' + 1
			rename (Perm1_T`f'_W Perm2_T`f'_W Perm1_T`f'_T Perm2_T`f'_T) (PermC_I``i''_W PermUnc_I``i''_W PermC_I``i''_T PermUnc_I``i''_T )
			}
		}
		keep PermC_I*_W PermUnc_I*_W PermC_I*_T PermUnc_I*_T
		tempfile perMES
		save `perMES'
		use `Original'
		merge 1:1 _n using `perMES', nogenerate
		tempfile Original
		save `Original'
		} /*if nperm is chosen*/
		
		
	   //====================================================//	
	  //====================              ==================//	
	 //===================	BOOTSTRAPS	===================//
	//==================              ====================//
   //====================================================//	
	
	if "`nboot'" != "0" {
		clear
		use `crt2'
		count
		scalar `N_total' = `r(N)'
		
		if `nboot'<1000 {
			display as error "error: nBoot must be greater than 1000"
			error 7
			}
				
		set seed `seed'
				
		noisily di as txt "  Running Bootstraps..."
		forvalues j = 1/`nboot' {
			
			if "`showprogress'" != "" {	
					if !mod(`j', 100) {
					noi di _c "`j'"
					}
				else {
					if !mod(`j', 10) {
						noi di _c "." 
						}
					}
				}
		
			keep `varlist_clean' `intervention' `random'
			bsample, strata(`random')
		
			gettoken depvar indepvars: varlist
			
			mixed `depvar' || `random':, `options' `maximization'
			matrix `b0' = e(b)
	
			scalar `id_var_col' = colnumb(`b0', "lns1_1_1:_cons")
			scalar `cluster_variance2' = exp(`b0'[1, `id_var_col'])^2

			scalar `res_var_col' = colnumb(`b0', "lnsig_e:_cons")
			scalar `res_variance2' = exp(`b0'[1, `res_var_col'])^2
			scalar `Total2' = `res_variance2' + `cluster_variance2'

			scalar `ICC2' = `cluster_variance2'/`Total2'
	
		
			`isily' mixed `depvar' i.`intervention' `indepvars' || `random':, `options' `maximization'
			matrix `b' = e(b)

			scalar `id_var_col' = colnumb(`b', "lns1_1_1:_cons")
			scalar `cluster_variance1' = exp(`b'[1, `id_var_col'])^2

			scalar `res_var_col' = colnumb(`b', "lnsig_e:_cons")
			scalar `res_variance1' = exp(`b'[1, `res_var_col'])^2
			scalar `Total1' = `res_variance1' + `cluster_variance1'

			scalar `ICC1' = `cluster_variance1'/`Total1'
			
			matrix list `b'
			matrix Coef = `b'[1,1..`=`max'']
			
	mata: st_matrix("Coef", select(st_matrix("Coef"), st_matrix("Coef") :!= 0))
	
			matrix Coef = Coef'		
			
			
			forvalues s = 1/2 {
				forvalues i=1/`=`max'-1' {
				tempname Within`s'_`i'`j' Total`s'_`i'`j' 
					scalar `Within`s'_`i'`j'' = Coef[`i',1]/sqrt(`res_variance`s'')
					scalar `Total`s'_`i'`j'' = Coef[`i',1]/sqrt(`Total`s'')
					}
				}
			clear
			use `crt2'
			} /*nboot*/
		forvalues s = 1/2 {
			forvalues j = 1/`nboot' {	
				forvalues i = 1/`=`max'-1' {
					if `nboot'>`=`N_total'' {
						set obs `nboot'
						}
					capture gen double Boot`s'_T`i'_W=.
					capture gen double Boot`s'_T`i'_T=.
					replace Boot`s'_T`i'_W = `Within`s'_`i'`j'' in `j'
					replace Boot`s'_T`i'_T = `Total`s'_`i'`j'' in `j'
					}
				}
			}
			
		forvalues s = 1/2 {
			forvalues i = 1/ `=`max'-1' {
			tempname W`s'_25_`i' W`s'_975_`i' T`s'_25_`i' T`s'_975_`i'
			
				centile Boot`s'_T`i'_W, centile(2.5)
				scalar `W`s'_25_`i''	=r(c_1)
				centile Boot`s'_T`i'_W, centile(97.5)
				scalar `W`s'_975_`i''	=r(c_1)
			
				centile Boot`s'_T`i'_T, centile(2.5)
				scalar `T`s'_25_`i''	=r(c_1)
				centile Boot`s'_T`i'_T, centile(97.5)
				scalar `T`s'_975_`i''	=r(c_1)
			}
		}
		forvalues s = 1/2 {
			forvalues i = 1/`=`max'-1' {
			tempname W`s'_`i' T`s'_`i' F`s'_`i' 
				matrix `W`s'_`i'' 		= (round(`d`s'w`i'',.01),round(`W`s'_25_`i'',.01),round(`W`s'_975_`i'',.01))
				matrix `T`s'_`i'' 		= (round(`d`s'tTotal`i'',.01),round(`T`s'_25_`i'',.01),round(`T`s'_975_`i'',.01))
				matrix `F`s'_`i'' 		= `W`s'_`i'' \ `T`s'_`i''

				matrix rownames `F`s'_`i'' = "Within" "Total"
				matrix colnames `F`s'_`i'' = "Estimate" "95% (BT)LB" "95% (BT)UB"
				}
			}
		forvalues i = 1/ `=`max'-1' {
			matrix `cond`i'' = `F1_`i'' 
			matrix `uncond`i'' = `F2_`i'' 
			}
		local m
		forvalues i = 1/`=`max'' {
			if "`=`refcat'+0'" != "``i''" {
			local m = `m' + 1
			rename (Boot1_T`m'_W Boot2_T`m'_W Boot1_T`m'_T Boot2_T`m'_T) (BootC_I``i''_W BootUnc_I``i''_W BootC_I``i''_T BootUnc_I``i''_T )
			}
		}
		keep BootC_I*_W BootC_I*_T BootUnc_I*_W BootUnc_I*_T
		tempfile crt2
		save `crt2'
		use `Original'
		merge 1:1 _n using `crt2', nogenerate
		tempfile Original
		save `Original'
		
		if "`showprogress'" != "" {
			noi di as txt ""
			}
		noi di as txt "  Bootstraps completed."
		} /*if nboot*/
	clear
	
			/*TABLES*/
	
	capture {
		noisily {
			return matrix Beta = `Beta'

			return matrix Cov = `Cov'

			return matrix SchEffects = `schRand'
		
			forvalues i = 1/`=`max'-1' {
		
				matrix list `cond`i''
				return matrix `cond`i'' = `cond`i''
		 
				matrix list `uncond`i''
				return matrix `uncond`i'' = `uncond`i''
			}
		}
	}
	use `Original'
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