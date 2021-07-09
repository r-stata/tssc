*! version 1.3.1  14apr2004
program define nnmatch, sortpreserve eclass
	version 8.0

	if ~replay() {
		nnmatch_w `0'
	}
	else {
		if "`e(cmd)'" ~= "nnmatch" {
			exit 301
		}
		else {
			loc y = e(depvar)
			loc t = e(match_ind)
			loc Xvars = e(match_vars)
			loc varlist `y' `t' `Xvars'	
			matr coeff = get(_b)
			loc T = coeff[1,1]
			loc se = e(se)
			loc n1 = e(N)
			loc m = e(m)
			loc h = e(h)
			if `h' == . {
				loc h = 0
			}
			loc stat = e(stat)
			if "`stat'" == "`c'ATE" {
				loc tc ate
			}
			if "`stat'" == "`c'ATT" {
				loc tc att
			}
			if "`stat'" == "`c'ATC" {
				loc tc atc
			}
			loc metric = e(metric)
			if "`metric'" == "inverse variance" {
				loc metric
			}
			if "`metric'" == "Maha" {
				loc metric maha
			}
			loc bias = e(bias)
			if "`bias'" == "none" {
				loc biasadj
			}
			else {
				loc biasadj `bias'
			}
			loc w = e(weight_var)
			if "`mw'" == "none" {
				loc weighting 
			}
			else {
				loc weighting `mw'
			}

			output `varlist', n1(`n1') te(`T') se(`se')	///
				m(`m') tc(`tc') met(`metric') 		///
				ex(`exact') bias(`biasadj') 		///
				pop(`population') rob(`h') wei(`exp') 	///
				lev(`level') per(`per')
		}
	}	
end

program define k1
	syntax varlist, id(string) ix(string) ix_t(string) di(string) 	///
		di_t(string) m(int) km(string) rob(string) w(string) 	///
		ti(string) 						///
		[ wei(string) tc(string) pop(string) ix_h(string) 	///
		ix_h_t(string) ] 

	gettoken y left: varlist
	gettoken t x: left
	loc N = _N

	tempvar z
	forval i = 1/`N' {
		if `rob' > 0 {
			qui ge `z' = abs(`x'[`i'] - `x') if `t' == `t'[`i'] 
			min, wei(`wei') w(`w') z(`z') ix(`ix_h') 	///
				ix_t(`ix_h_t') rob(`rob') id(`id') i(`i') 
			drop `z' `z'2		
		}
		if `t'[`i'] `ti' {
			qui ge `z' = abs(`x'[`i'] - `x') if `t' ~= `t'[`i']
			min, wei(`wei') w(`w') z(`z') ix(`ix') 		///
				ix_t(`ix_t') di(`di') di_t(`di_t') 	///
				m(`m') id(`id') i(`i') km(`km') pop(`pop') 
			drop `z' `z'2		
		}
	}
end

program define k2
	syntax varlist, id(string) ix(string) ix_t(string) di(string)	///
		di_t(string) m(int) km(string) rob(string) w(string) 	///
		ti(string) 						///
		[ wei(string) tc(string) pop(string) ix_h(string) 	///
		ix_h_t(string) ex(string) ] 
	gettoken y left: varlist
	gettoken t Xvars: left	
	loc N = _N	

	tempname Var VarE
	foreach x of loc Xvars {
		qui sum `x' [w = `w']
		scal `Var'`x' = r(Var)
	}	
	if "`ex'" ~= "" {
		foreach e of loc ex {
			qui sum `e' [w = `w']
			scal `VarE'`e' = r(Var)
		}
	}	

	tempvar z u
	forval i = 1/`N'	{			
		if `rob' > 0 {
			foreach x of loc Xvars {
				qui ge `u'`x'=((`x'[`i']-`x')^2) 	///
					/`Var'`x' if `t'==`t'[`i'] 
			}
			if "`ex'" ~= "" {
				foreach e of loc ex {
					qui ge `u'E`e'=			///
					(1000*((`e'[`i']-`e')^2))	///
					/`VarE'`e' if `t'==`t'[`i'] 
				}
			}
			qui egen `z' = rsum(`u'*) if `t'[`i']==`t'
			min, wei(`wei') w(`w') z(`z') ix(`ix_h') 	///
				ix_t(`ix_h_t') id(`id') i(`i') rob(`rob')  
			drop `z' `z'2		
			foreach x of loc Xvars  {
				drop `u'`x'
			}
			if "`ex'" ~="" {
				foreach e of loc ex {
					drop `u'E`e'
				}
			}
		}
		if `t'[`i'] `ti' {
			step `Xvars', t(`t') id(`id') ix(`ix') 		///
				ix_t(`ix_t') di(`di') di_t(`di_t') 	///
				m(`m') i(`i') km(`km') wei(`wei') 	///
				w(`w') ex(`ex') pop(`pop') 
		}
	}
end

pro def k2Met 
	syntax varlist, id(string) ix(string) ix_t(string) 		///
		di(string) di_t(string) m(int) met(string) 		///
		rob(string) km(string) w(string) ti(string) 		///
		[wei(string) tc(string) pop(string) ix_h(string) 	///
		ix_h_t(string) ex(string)] 

	gettoken y left: varlist
	gettoken t Xvars: left	
	loc k: word count `Xvars'
	loc N = _N

	tempname VarE
	if "`ex'" ~= "" {
		foreach e of loc ex {
			qui sum `e' [w = `w']
			scal `VarE'`e' = r(Var)
		}
	}	

	tempname L l norm
	if "`met'" == "maha" {
		foreach x of loc Xvars {
			qui sum `x' [w=`w']	
			ge double `x'`norm' = (`x' - r(mean))/r(sd)
			loc Xnorm "`Xnorm' `x'`norm'"
		}
		tempname Cov V 
		qui matr accum `Cov' = `Xnorm', noconstant
		matr `Cov' = `Cov'/(`N')
		matr `V' = syminv(`Cov')
		matr `L' = cholesky(`V')
	}
	else {
		matr `L' = cholesky(`met')
	}
	forval v = 1/`k' {
		loc j = `v'
		while `j' <= `k' {
			scal `l'`j'`v' = `L'[`j',`v']
			loc j = `j' + 1
		}
	}

	if "`met'" == "maha" {
		tokenize `Xnorm'
	}
	else {
		tokenize `Xvars'	
	}
	tempname _n step
	forval v = 1/`k' {
		loc j = `v'		
		while `j' <= `k' {
			qui ge double `step'`v'`j' = ``j''*scalar(`l'`j'`v')
			loc j = `j' + 1
		}
		qui egen double ``v''`_n' = rsum(`step'`v'*)
		loc Xvars_n "`Xvars_n' ``v''`_n'"
		qui drop `step'`v'*
	}

	tempname z u
	forval i = 1/`N' {
		if `rob' > 0 {
			foreach x of loc Xvars_n {
				qui gen double `u'`x'=(`x'[`i']-`x')^2 	///
					if `t' == `t'[`i'] 
			}
			if "`ex'" ~= "" {
				foreach e of loc ex {
					qui gen double `u'E`e'=		///
					(1000*((`e'[`i']-`e')^2))	///
					/`VarE'`e' if `t' == `t'[`i']
				}
			}
			qui egen double `z' = rsum(`u'*) if `t' == `t'[`i']
			min, wei(`wei') w(`w') z(`z') ix(`ix_h') 	///
				ix_t(`ix_h_t') rob(`rob') id(`id') i(`i') 
			drop `z' `z'2		
			foreach x of loc Xvars_n  {
				drop `u'`x'
			}			
			if "`ex'" ~= "" {
				foreach e of loc ex {
					drop `u'E`e'
				}	
			}
		}	

		if `t'[`i'] `ti' {
			step `Xvars_n', t(`t') wei(`wei') id(`id') 	///
				ix(`ix') ix_t(`ix_t') m(`m') i(`i') 	///
				di(`di') di_t(`di_t') km(`km') 		///
				met(`met') w(`w') ex(`ex') pop(`pop') 
		}			
	}
	foreach x of loc Xvars_n {
		drop `x'
	}
	foreach x of loc Xnorm {
		drop `x'
	}
end

pro def step
	syntax varlist, t(string) id(string) ix(string) 		///
		ix_t(string) di(string) di_t(string) m(int) 		///
		i(int) km(string) w(string) [ wei(string) 		///
		met(string) ex(string) pop(string) ]

	tempname Var VarE
	foreach x of loc varlist {
		if "`met'" == "" {
			qui sum `x' [w=`w']
			scal `Var'`x' = r(Var)
		}
		else {
			scal `Var'`x' = 1
		}							
	}
	if "`ex'" ~= "" {
		foreach e of loc ex {
			qui sum `e' [w=`w']
			scal `VarE'`e' = r(Var)
		}
	}

	tempname z u
	foreach x of loc varlist {
		qui ge double `u'`x'=((`x'[`i']-`x')^2)/`Var'`x' 	///
			if `t' ~= `t'[`i']
	}
	if "`ex'" ~= "" {
		foreach e of loc ex {
			qui ge double `u'E`e'=				///
				(1000*((`e'[`i']-`e')^2))/`VarE'`e' 	///
				if `t' ~= `t'[`i']
		}
	}		
	qui egen double `z' = rsum(`u'*) 	if `t'[`i']~=`t'


	min, wei(`wei') w(`w') z(`z') ix(`ix') ix_t(`ix_t') 		///
		di(`di') di_t(`di_t') m(`m') id(`id') i(`i') 		///
		km(`km') pop(`pop') 
	drop `z' `z'2		
	foreach x of loc Xvars_n {
		drop `u'`x'	
	}			
	if "`ex'" ~= "" {
		foreach e of loc ex {
			drop `u'E`e'
		}
	}
end	

program define TCvalue
	syntax, var(string) t(string) ix(string) a(string) 		///
		2(string) 1(string) 0(string)

	gen `var'`2' = `var'[`ix'`a'[_n]]
	gen `var'`1' = `var' 		if `t' == 1
	replace `var'`1' = `var'`2'	if `t' == 0
	gen `var'`0' = `var'		if `t' == 0
	replace `var'`0' = `var'`2'	if `t' == 1
end
 
pro def biasadj
	syntax varlist, t(string) w(string) y0(string) y1(string) ///
		mu_l0(string) mu_l1(string) mu_i0(string) mu_i1(string) ///
		coeff(string) con(varlist) tr(varlist) [tc(string)] 

// Eq 3.5, t=0
	if "`tc'" == "ate" | "`tc'" == "" {
		qui reg `y0' `con' [aw=`w'] if `t'==1
	}
	else {
		qui reg `y0' `con' [aw=`w']
	}			
	qui predict `mu_l0'
	mat `coeff ' = get(_b)
	mat colnames `coeff' = `varlist' _cons
	mat score `mu_i0' = `coeff'

// Eq 3.5, t=1
	if "`tc'" == "ate" | "`tc'" == "" {
		qui reg `y1' `tr' [aw=`w'] if `t'==0
	}
	else {
		qui reg `y1' `tr' [aw=`w'] 
	}
	qui predict `mu_l1'
	mat `coeff' = get(_b)
	mat coln `coeff' = `varlist' _cons
	mat score `mu_i1' = `coeff'

end

pro def min
	syntax, z(string) ix(string) ix_t(string) id(string) 	///
		i(string) w(string) [ wei(string) di(string) 	///
		di_t(string) m(string) km(string) 		///
		rob(string) pop(string)]

	qui sum `z'
	tempname sd
	sca `sd' = r(sd)
	qui capt ge double `z'2 = `z' / `sd'	
	if _rc > 0 {
		errormsg
	}	
		
	tempvar v idx k
	tempname z_m

	if "`km'" ~= "" {
		capt ge `k' = 0
		if _rc > 0 {
			errormsg
		}	
		if "`wei'" ~= "" {
			capt ge `k'1 = 0
			if _rc > 0 {
				errormsg
			}	
		}
		if "`pop'" ~= "" {
			capt ge `k'2 = 0
			if _rc > 0 {
				errormsg
			}	
		}
		loc p = `m'
	}
	else {
		loc p = `rob' + `w'[`i']
	}

	loc j = 0
	loc a1 = 1
	qui while `j' < `p' {
		capt ge `idx' = 1
		capt ge double `v' = `z'2[1]
		capt replace `v'=cond(`z'2 < `v'[_n-1], `z'2, 	///
			`v'[_n-1]) if _n>1

		if _rc > 0 {
			errormsg
		}	
		capt replace `idx' = cond(`z'2 < `v'[_n-1], `id', 	///
			`idx'[_n-1]) if _n>1
		if _rc > 0 {
			errormsg
		}		
		capt ge `ix'`a1' = .
		capt replace `ix'`a1' = `idx'[_N] if `id' == `i'
		if _rc > 0 {
			errormsg
		}	

		if "`km'" ~= "" {	
			capt ge `di'`a1' = .
			capt replace `di'`a1' = `v'[_N]*`sd' if `id' == `i'
			if _rc > 0 {
				errormsg
			}		
		}
		scal	`z_m' = `v'[_N]

		if "`wei'"~="" {
			tempvar w_m
			capt ge `w_m' = `w' if `z'2==`v' & 		///
				`z'2==`v'[_N] & `z'2~=`v'[_n-1]
			if _rc > 0 {
				errormsg
			}	
			replace `w_m' = sum(`w_m')				
			loc b = `w_m'[_N]
		}
		else {
			loc b = 1
		}

		replace `z'2=. if `z'2==`v' & `z'2==`v'[_N] & `z'2~=`v'[_n-1]
		drop `v' `idx'

		if "`km'" ~= "" {
			replace `k' = `w' if `id' == `ix'`a1'[`i']
			if "`wei'" ~= "" {
				replace `k'1 = `w'		///
					if `id' == `ix'`a1'[`i'] 
				replace `k'1 = `k'1*`w'[`i']	///
					if `id' == `ix'`a1'[`i'] 
				if "`pop'" ~= "" {
					replace `k'2 = `k'1*`w'	///
						if `id' == `ix'`a1'[`i'] 
				}
			}
		}
		loc j = `j' + `b'
		loc a1 = `a1' + 1
	}

	loc a2 = 1
	loc stop 0
	loc l 1
	qui while `stop' ==  0 {
		capt ge `idx' = 1
		capt ge double `v' = `z'2[1]
		capt replace `v'=cond(`z'2<`v'[_n-1],`z'2,`v'[_n-1]) if _n>1
		if _rc > 0 {
			errormsg
		}	
		if `v'[_N]-`z_m' > 0.000000001 {
			local stop 1
		}
		else {
			capt replace `idx'=cond(`z'2<`v'[_n-1],`id',	///
				`idx'[_n-1]) if _n>1
			if _rc > 0 {
				errormsg
			}		
			capt ge `ix_t'`a2' = .
			capt replace `ix_t'`a2' = `idx'[_N] if `id' == `i'
			if _rc > 0 {
				errormsg
			}	

			if "`km'" ~= "" {	
				capt ge `di_t'`a2' = .
				capt replace `di_t'`a2' = `v'[_N]*`sd' 	///
					if `id' == `i'
				if _rc > 0 {
					errormsg
				}	
			}	
			replace `z'2=. if `z'2==`v' & `z'2==`v'[_N] ///
				& `z'2 ~= `v'[_n-1]
			drop `v' `idx'

			if "`km'" ~= "" {
				replace `k' = `w' 			///
					if `id' == `ix_t'`a2'[`i']
				if "`wei'"~="" {
					replace `k'1 = 1*`w' 		///
						if `id' == `ix_t'`a2'[`i']
					replace `k'1 = `k'1*`w'[`i'] 	///
						if `id' == `ix_t'`a2'[`i']
					if "`pop'" ~= "" {
						replace `k'2 = `k'1*`w'	///
							if `id' ==	///
							`ix_t'`a2'[`i']
					}
				}
			}	
			loc a2 = `a2' + 1
		}		
	}

// Eq 2.1: km 
	qui if "`km'" ~= "" {
		tempvar Jm
		qui capt egen `Jm' = sum(`k')
			if _rc > 0 {
				errormsg
			}	
		if "`wei'"~="" {
			replace `k'1 = `k'1/`Jm'
			replace `km' = `km' + `k'1
			if "`pop'" ~= "" {
				replace `k'2 = `k'2/((`Jm')^2)
				replace `km'2 = `km'2 + `k'2		
			}
		}
		else {		
			capt ge `k'i = `k'/`Jm'
				if _rc > 0 {
					errormsg
				}	
			replace `km' = `km' + `k'i
			if "`pop'" ~= "" {
				replace `k'2 = `k'/((`Jm')^2)
				replace `km'2 = `km'2 + `k'2
			}
		}
		drop `k'*
	}	
end

pro def output
	syntax varlist, n1(string) te(string) se(string) [m(string) 	///
		tc(string) met(string) bias(string) pop(string) 	///
		rob(string) wei(string) lev(string) ex(string) per(string)] 

	gettoken y left: varlist
	gettoken t Xvars: left	
	loc k: word count `Xvars'
	loc abname = abbrev("`y'", 12)

	loc test = `te'/`se'	
	loc prob = norm(`test')

	if "`lev'" == "" {
		loc CI 95
	}
	else {
		loc CI `lev'
	}

	tempname h
	scal `h' = `rob'

	loc SE "Std. Err."

	if `h' > 0 {
		loc rob ", with robust standard errors"
	}

	if "`pop'" == "" {
		loc c S
	}
	else {
		loc c P
	}

	if "`pop'" ~= "" {
		local Pp Population
	}
	if "`tc'" == "" | "`tc'" == "ate" {
		loc TE "`c'ATE"
	}
	if "`tc'" == "att" {
		loc tc "for the Treated"
		loc TE "`c'ATT"
	}
	if "`tc'" == "atc" {
		loc tc "for the Controls"
		loc TE "`c'ATC"
	}

	if "`wei'" ~= "" {
		loc wvtxt "Weight variable: `wei'"
		loc space "  "
	}
	di
	di as text "Matching estimator: `Pp' Average Treatment Effect `tc'"

	di

	if `k' > 1 {
		if "`met'" == "" {
			loc wmtxt "Weighting matrix`space': inverse variance"
		}
		if "`met'" == "maha" {
			loc wmtxt "Weighting matrix`space': Mahalanobis"
		}
		if "`met'" ~= "maha" & "`met'" ~= "" {
			loc wmtxt "Weighting matrix`space': `met'"
		}
	}
	di as text "`wmtxt' {col 45}Number of obs {col 68}=" as res %10.0f `n1'
	di as text "`wvtxt' {col 45}Number of matches  (m) = " as res %9.0f `m'
	if `h' > 0 {
		di as text _col(45) "Number of matches, "
		di as text _col(47) "robust std. err. (h) = " as res %9.0f `h'
	}
	di
	ereturn display, level(`CI')
	di as text "{p 0 8 4}Matching variables: `Xvars'{p_end}"
	if "`bias'" ~= "" {
		if "`bias'" == "bias" {
			di as text "{p 0 8 4}Bias-adj variables: " 	///
				"`Xvars'{p_end}"
		}
		else {
			di as text "{p 0 8 4}Bias-adj variables: " 	///
				"`bias'{p_end}"
		}
	}	
	if "`ex'" ~= "" {
		di as text "{p 0 8 4}Exact matching variables: " 	///
			"`ex'{p_end}" 
		di as text "{p 3 8 4}(Percent of exact matches: " 	///
			as result `per' as text ")"
	}
end

pro def errormsg
	di as error "Insufficient memory to create more variables:"
	di as error "Either increase memory or decrease m"
	exit 1
end

program define nnmatch_w , sortpreserve eclass

	syntax varlist(min=3 num) [if] [in] [pw/] 	///
		[, 					///
		m(int 1) 				///
		tc(string) 				///
		METric(string) 				///
		BIASadj(string) 			///
		EXact(string) 				///
		Population 				///
		ROBust(int 0) 				///
		LEvel(int 95) 				///
		Keep(string) 				///
		replace					///
		]

	gettoken y left: varlist
	gettoken t Xvars: left	
	loc k: word count `Xvars'
  	preserve

	if "`in'" ~= "" {
		qui keep `in'
	}
	if "`if'" ~= "" {
		qui keep `if' 
	}

	tempvar w
	if "`weight'" ~= "" {
		qui ge `w' = `exp'
		local wmac " [ pw = `w' ] "
	}		
	else {
		qui ge `w' = 1 
	}

	marksample touse
	qui {
		tempname n0 n1 drop
		count
		scal def `n0' = r(N)
		keep if `touse' 
		qui drop if `w' == .
		if "`biasadj'" ~= "" & "`biasadj'" ~= "bias" {
			foreach x of loc biasadj {
				cap confirm var `x'
				if _rc > 0 {
					di as err "Bias-adjust "	///
						"variable `x' not found"
					exit 111
				}
				cap confirm numeric var `x' 
				if _rc > 0 {
di as err "String variable `x' found where numeric variable expected"
exit 7
				}
				qui drop if `x' == .
			}
		}

		if "`exact'" ~="" {
			foreach e of loc exact {
				cap confirm var `e'
				if _rc > 0 {
					di as err "Exact match "	///
						"variable `e' not found"
						exit 111
				}
				cap confirm numeric var `e' 
				if _rc > 0 {
di as err "String variable `e' found where numeric variable expected"
exit 7
				}
				qui drop if `e' == .
			}
		}
		count
		scalar `n1' = r(N)
		scalar `drop' = `n0' - `n1'
		if `drop' > 0 {
			noi di as text `drop' " observations dropped " 	///
				"due to treatment variable missing "
		}		
	}	

// CHECKS: 
// X:
		_rmcoll `Xvars' `wmac'
		local Xvars "`r(varlist)'"

// Exact:
		if "`exact'" ~= "" {


			qui _rmcoll `exact' `wmac'
			local exact2 "`r(varlist)'"
			local edropped : list exact - exact2
			foreach dvar of local edropped {
				di as txt "note: `dvar' dropped from "	///
					"{cmd:exact()} varlist due to "	///
					"collinearity"
			}
			local exact `exact2'
		}

// T/C var:
	cap ass `t' == 0 | `t' ==1					
	if _rc > 0 {
		di as err "treatment variable must be 0 or 1"
		exit 498	
	}

// TC:
	cap ass "`tc'" == "" | "`tc'" == "atc" | "`tc'" == "att" |	///
		"`tc'" == "ate"
	if _rc > 0 {
		di as err "tc(`tc') invalid option"
		exit 198
	}

// m 
	cap ass `m' > 0
	if _rc > 0 {
		di as err "m must be greater than zero"
		exit 498
	}
	tempname n_0 n_1				
	qui count if `t'==0
	scalar `n_0' = r(N)
	qui count if `t'==1
	scalar `n_1' = r(N)
	if "`tc'" == "att" | "`tc'" == "" | "`tc'" == "ate" {
		cap ass `m' <= `n_0'			
		if _rc > 0 {
			di as err ///
				"m must be an integer less than or " 	///
				"equal to the number of control observations"
			exit 498
		}
	}
	if "`tc'" == "atc" | "`tc'" == "" | "`tc'" == "ate" {
		cap ass `m' <= `n_1'
		if _rc > 0 {
			di as err ///
				"m must be an integer less than or " ///
				"equal to the number of treatment observations"
			exit 498
		}
	}

// Metric:		
	if "`metric'" ~= "" {
		if `k' == 1 {
			di as err "Note: With only 1 covariate,  "	///
				"weighting matrix not used"
		}
	}

	if "`metric'" ~= "maha" & "`metric'" ~= "" {
		tempname mat2 test k2 X v
		cap scal `mat2' = rowsof(`metric') 
		if _rc > 0 {
			di as err "Weighting matrix `metric' not found"
			exit 111
		}
		scalar `test' = issym(`metric')
		if `test' != 1 {
			di as err "Weighting matrix `metric' must be symmetric"
			exit 505 
		}
		scal `k2' = colsof(`metric')	
		if `k2' != `k' {		
			di as err ///
				"Weighting matrix `metric' not square"
			exit 498
		}
		matr symeigen `X' `v' = `metric'
		forval j = 1/`k' {
	 		tempname eig`j'
   			scal `eig`j'' = `v'[1,`j']
   			if `eig`j''<= 1e-15 { 
				di as err "Weighting matrix `metric' " ///
					"not positive semidefinite"
				exit 498
			}
		}
	}					

// Robust:
	tempname h
	scal `h' = `robust'

	if `h' < 0 {
		di as err "robust(`robust') invalid"
		di as err "Number of matches must be an integer "	///
			"greater than or equal to 1"
		exit 498 
	}


// Keep:
	cap confirm file `keep'.dta
	if _rc == 0 {
		if "`replace'" == "" {
			di as err "file `keep'.dta already exists"
			exit 602
		}
	}

// GEN MATCHING VARS: 
	loc N = _N
	tempvar id ix ix_t km di di_t ix_h ix_h_t
	ge `id' = _n				
	ge `km' = 0
	if "`population'" ~= "" {
		ge `km'2 = 0
	}

	if "`tc'" == "" | "`tc'" == "ate" {
		loc ti "~=."
	}
	if "`tc'" == "att" {
		loc ti "==1"
	}
	if "`tc'" == "atc" {
		loc ti "==0"
	}

	if `k' == 1 & "`exact'"=="" {
		k1 `varlist', wei(`weight') w(`w') id(`id') ix(`ix') 	///
			ix_t(`ix_t') di(`di') di_t(`di_t') ix_h(`ix_h')	///
			ix_h_t(`ix_h_t') m(`m') tc(`tc') 		///
			pop(`population') rob(`h') km(`km') ti(`ti')
	}
	else {
		if "`metric'" == "" {
			k2 `varlist', wei(`weight') w(`w') id(`id') 	///
				ix(`ix') ix_t(`ix_t') di(`di') 		///
				di_t(`di_t') ix_h(`ix_h') 		///
				ix_h_t(`ix_h_t') m(`m') tc(`tc') 	///
				pop(`population') rob(`h') 		///
				km(`km') ex(`exact') ti(`ti')
		}
		else {
			k2Met `varlist', wei(`weight') w(`w') 		///
				id(`id') ix (`ix') ix_t(`ix_t') 	///
				di(`di') di_t(`di_t') ix_h(`ix_h') 	///
				ix_h_t(`ix_h_t') m(`m') tc(`tc') 	///
				met(`metric') pop(`population') 	///
				rob(`h') km(`km') ex(`exact') ti(`ti')
		}
	}
	tempfile olddata newdata newdata_m
	qui sa `olddata'	

// NEWDATA:
	tempname 0a 0b 0c 1a 1b 1c 2a 2b 2c
	foreach x of loc Xvars {
		loc con "`con' `x'`0a'"
		loc tr "`tr' `x'`1a'"
	}
	if "`biasadj'"~="" & "`biasadj'" ~="bias" {
		foreach b of loc biasadj {
			loc b_con "`b_con' `b'`0b'"
			loc b_tr "`b_tr' `b'`1b'"
		}
	}	
	if "`exact'"~="" {
		foreach e of loc exact {
			loc e_con "`e_con' `e'`0c'"
			loc e_tr "`e_tr' `e'`1c'"
		}
	}	

	loc stop 0
	loc a1 1
	qui while `stop' == 0 {
		cap confi var `ix'`a1'
		qui if _rc == 0 {
			ge `w'`2' = `w'[`ix'`a1'[_n]]
			TCvalue, var(`y') t(`t') ix(`ix') a(`a1') 	///
				2(`2a') 1(`1a') 0(`0a')
			foreach x of loc Xvars {
				TCvalue, var(`x') t(`t') ix(`ix') 	///
					a(`a1') 2(`2a') 1(`1a') 0(`0a')
			}
			if "`biasadj'"~="" & "`biasadj'"~="bias" {
				foreach b of loc biasadj {
					TCvalue, var(`b') t(`t') 	///
						ix(`ix') a(`a1') 	///
						2(`2b') 1(`1b') 0(`0b')
				}
			}
			if "`exact'"~="" {
				foreach e of loc exact{
					TCvalue, var(`e') t(`t') 	///
						ix(`ix') a(`a1') 	///
						2(`2c') 1(`1c') 0(`0c')
				}
			}
			if "`biasadj'"~="" & "`biasadj'"~="bias" {
				keep `id' `t' `y' `Xvars' `biasadj' 	///
					`ix'`a1' `di'`a1' `y'`0a' 	///
					`y'`1a' `con' `tr' `b_con' 	///
					`b_tr' `e_con' `e_tr' `w' 	///
					`w'`2' `km'* `exact' 
			}
			else {
				keep `id' `t' `y' `Xvars' `ix'`a1' 	///
					`di'`a1' `y'`0a' `y'`1a' 	///
					`con' `tr' `e_con' `e_tr' `w' 	///
					`w'`2' `km'* `exact' 
			}

			if "`tc'" =="att" {
				qui keep if `t' == 1
			}
			if "`tc'" =="atc" {
				qui keep if `t' == 0
			}

			ren `ix'`a1' `ix'
			ren `di'`a1' `di'
			qui drop if `ix' == .
			cap app using `newdata'
			qui sa `newdata', replace
			us `olddata'
			loc a1 = `a1' + 1
		}
		else {
			loc stop 1 
		}
	}

// Ties:
	loc stop_tie 0
	loc a2 1
	qui while `stop_tie' == 0 {
		cap confi var `ix_t'`a2'
		qui if _rc == 0 {
			ge `w'`2' = `w'[`ix_t'`a2'[_n]]
			TCvalue, var(`y') t(`t') ix(`ix_t') 		///
				a(`a2') 2(`2a') 1(`1a') 0(`0a')
			foreach x of loc Xvars {
				TCvalue, var(`x') t(`t') 		///
					ix(`ix_t') a(`a2') 2(`2a') 	///
					1(`1a') 0(`0a')
			}
			if "`biasadj'"~="" & "`biasadj'"~="bias" {
				foreach b of loc biasadj {
					TCvalue, var(`b') t(`t') 	///
					ix(`ix_t') a(`a2') 2(`2b') 	///
					1(`1b') 0(`0b')
				}
			}
			if "`exact'"~="" {
				foreach e of loc exact{
					TCvalue, var(`e') t(`t') 	///
					ix(`ix_t') a(`a2') 2(`2c') 	///
					1(`1c') 0(`0c')
				}
			}
			if "`biasadj'"~="" & "`biasadj'"~="bias" {
				keep `id' `t' `y' `Xvars' `biasadj' 	///
					`ix_t'`a2' `di_t'`a2' `y'`0a' 	///
					`y'`1a' `con' `tr' `b_con' 	///
					`b_tr' `e_con' `e_tr' `w' 	///
					`w'`2' `km'* `exact' 
			}
			else {
				keep `id' `t' `y' `Xvars' `ix_t'`a2' 	///
					`di_t'`a2' `y'`0a' `y'`1a' 	///
					`con' `tr' `e_con' `e_tr' `w' 	///
					`w'`2' `km'* `exact' 
			}

			if "`tc'" =="att" {
				qui keep if `t' == 1
			}
			if "`tc'" =="atc" {
				qui keep if `t' == 0
			}
			ren `ix_t'`a2' `ix'
			ren `di_t'`a2' `di'
			qui drop if `ix' == .
			app using `newdata'
			qui sa `newdata', replace
			us `olddata'
			loc a2 = `a2' + 1
		}
		else {
			loc stop_tie 1 
		}
	}			

	us `newdata'
	qui compress
	tempvar mw
	sort `id'
	by `id': egen `mw'2 = sum(`w'`2')
	ge `mw' = `w'`2'/`mw'2
	drop `mw'2
	qui sa `newdata', replace

	if "`keep'" ~= "" {
		order `t' `y' `Xvars' `id' `km'* `ix' `di' `w' `w'`2' ///
			`y'`0a' `y'`1a' `con' `tr' `b_con' `b_tr' `e_con' `e_tr' 
		ren `id' id
		ren `ix' index
		ren `di' dist		
		ren `y'`0a' `y'_0
		ren `y'`1a' `y'_1
		ren `km' km
		if "`population'" ~= "" {
			ren `km' km_prime
		}
		foreach x of loc Xvars {
			ren `x'`0a' `x'_0m
			ren `x'`1a' `x'_1m
			lab var `x'_0 "matching variable: `x' control"
			lab var `x'_1 "matching variable: `x' treatment"
		}
		if "`biasadj'"~="" & "`biasadj'"~="bias" {
			foreach b of loc biasadj {
				ren `b'`0b' `b'_0b
				ren `b'`1b' `b'_1b
				lab var `b'_0b "bias adjustment variable: `b' control"
				lab var `b'_1b "bias adjustment variable: `b' treatment"
			}
		}		
		if "`exact'"~="" {
			foreach e of loc exact {
				ren `e'`0c' `e'_0e
				ren `e'`1c' `e'_1e
				lab var `e'_0e "exact matching variable: `e' control"
				lab var `e'_1e "exact matching variable: `e' treatment"
			}
		}		
		lab var `t' "grouping variable"
		lab var `y' "Yi: outcome variable for observation number id"
		lab var id "observation number"
		lab var index "observation number for match"
		lab var dist "distance to match"
		lab var `y'_0 "Yi0: outcome control"
		lab var `y'_1 "Yi1: outcome treatment"
		if "`weight'" == "" {
			drop `w' `w'`2' 
		}
		else {
			ren `w' w_id
			ren `w'`2' w_index
			lab var w_id "weight of id (i)"
			lab var w_index "weight of index (match)"
		}
		drop `mw'
		sa `keep', `replace'
		us `newdata'
	}

// Percent Exact Matched:
	if "`exact'" ~= "" {
		tempname ex 
		qui {
			foreach e of loc exact {
				sum `e' [w=`w']
				ge `ex'`e'`0c' = `e'`0c'/r(Var)
				ge `ex'`e'`1c' = `e'`1c'/r(Var)
			}		
			egen `ex'2`0c' = rsum(`ex'*`0c')
			egen `ex'2`1c' = rsum(`ex'*`1c')
			ge `ex'2 = (abs(`ex'2`0c' - `ex'2`1c') < 0.000000001)
			egen `ex'2_per = mean(`ex'2)
			loc per = 100*`ex'2_per[1]
		}
	}

// CALCS WITHIN `newdata': T
	tempvar Ti
	tempname hat coeff b V
	qui replace `mw' = `mw'*`w'

// Simple Estimator
	if "`biasadj'"=="" {
		qui ge `Ti' = `y'`1a' - `y'`0a'
	}

*Bias Corrected
	if "`biasadj'"~="" {
		tempvar mu_l0 mu_l1 mu_i0 mu_i1 
		if "`biasadj'" == "bias" {
			biasadj `Xvars', t(`t') tc(`tc') w(`mw') 	///
				y0(`y'`0a') y1(`y'`1a') mu_l0(`mu_l0')	///
				mu_l1(`mu_l1') mu_i0(`mu_i0') 		///
				mu_i1(`mu_i1') con(`con') tr(`tr') 	///
				coeff(`coeff')
		}
		if "`biasadj'" ~= "bias" {
			biasadj `biasadj', t(`t') tc(`tc') w(`mw') 	///
				y0(`y'`0a') y1(`y'`1a') mu_l0(`mu_l0') 	///
				mu_l1(`mu_l1') mu_i0(`mu_i0') 		///
				mu_i1(`mu_i1') con(`b_con') tr(`b_tr') 	///
				coeff(`coeff')
		}

// Eq 3.6/9
		ge `y'`0a'i = `y'`0a' + `mu_i0' - `mu_l0'
// Eq 3.7
		ge `y'`1a'i = `y'`1a' + `mu_i1' - `mu_l1'
		ge `Ti' = `y'`1a'i - `y'`0a'i
	}	

// Eq 3.2-4, 3.8/10
	qui reg `Ti' [aw=`mw']
	loc T = _b[_cons]	
	mat `b' = `T'

	if "`population'" == "" {
		loc c S
	}
	else {
		loc c P
	}

	if "`tc'" == "" | "`tc'" == "ate" {
		mat coln `b' = "`c'ATE"
	}
	else {
		if "`tc'" == "att" {
			mat coln `b' = "`c'ATT"
		}
		else {
			mat coln `b' = "`c'ATC"
		}
	}
	qui sa `newdata', replace

	if "`population'" ~= "" {
		qui {
			if "`biasadj'"~="" {
				by `id', sort: egen `y'`hat'0 = 	///
					sum(`y'`0a'i*`mw')
				by `id': egen `y'`hat'1 = sum(`y'`1a'i*`mw')
			}
			else {	
				by `id', sort: egen `y'`hat'0 = 	///
					sum(`y'`0a'*`mw')
				by `id': egen `y'`hat'1 = sum(`y'`1a'*`mw')
			}
			by `id': egen `mw'`hat' = sum(`mw')
			replace `y'`hat'0 = `y'`hat'0/`mw'`hat'
			replace `y'`hat'1 = `y'`hat'1/`mw'`hat'
			keep `id' `y'`hat'1 `y'`hat'0
			by `id':  keep if _n==1
			qui sa `newdata_m'
			us `olddata'
			sort `id'
			merge `id' using `newdata_m'
			drop _merge
			replace `y'`hat'0  = 0 if `y'`hat'0 ==.
			replace `y'`hat'1  = 0 if `y'`hat'1 ==.
			qui sa `olddata', replace
		}
	}			

// SE: 
	if `h' > 0 {
		us `olddata'
		tempfile hetdata
		tempname h2

		loc stop 0
		loc a1 1
		while `stop' == 0 {
			cap confi var `ix_h'`a1'
			qui if _rc==0 {
				ge `y'`h2'=`y'[`ix_h'`a1'[_n]]
				ge `w'`2' = `w'[`ix_h'`a1'[_n]]
				keep `id' `t' `Xvars' `ix_h'`a1' `y'	///
					`y'`h2' `w' `w'`2'
				rename `ix_h'`a1' `ix_h'
				cap app using `hetdata'
				qui sa `hetdata', replace
				us `olddata'
				loc a1 = `a1' + 1 
			}
			else {
				loc stop 1
			}
		}
		
	*Ties:
		loc stop_tie 0
		loc a2 1
		qui while `stop_tie' == 0 {
			cap confi var `ix_h_t'`a2'
			qui if _rc == 0 {
				ge `y'`h2' = `y'[`ix_h_t'`a2'[_n]]
				ge `w'`2' = `w'[`ix_h_t'`a2'[_n]]
				keep `id' `Xvars' `t' `ix_h_t'`a2' 	///
					`y' `y'`h2' `w' `w'`2'
				rename `ix_h_t'`a2' `ix_h'
				qui drop if `ix_h' == .
				app using `hetdata'
				sa `hetdata', replace
				us `olddata'
				loc a2 = `a2' + 1
			}
			if _rc > 0 {
				loc stop_tie 1 
			}
		}			
	}

// Homosked:
	us `newdata'
	if `h' == 0 {
// Eq 4.14
		tempvar eps
		qui ge `eps'2 = (`Ti' - `T')^2
		qui reg `eps'2 [aw=`mw']
		loc s2 = (_b[_cons])*0.5
		loc s = (`s2')^0.5
		us `olddata'
	}

// Hetero:
	if `h' > 0 {
		us `hetdata'
		tempvar Ybar_Ji denom diff2 sumdiff s2 s
// Eq 4.16
		qui {
			ge `y'`h2'_w = `y'`h2'*`w'`2'
			by `id', sort: egen `Ybar_Ji' = sum(`y'`h2'_w)
			by `id': egen `denom' = sum(`w'`2')
			replace `Ybar_Ji' = `Ybar_Ji'/`denom' 
			qui ge `diff2' = `w'`2'*(`y'`h2' - `Ybar_Ji')^2
			by `id': egen `sumdiff' = sum(`diff2')
			by `id': ge `s2' = (1/(`denom'-1))*`sumdiff'
			by `id': keep if _n == 1
		}	
		qui sa `hetdata', replace
		us `olddata'
		sort `id'
		merge `id' using `hetdata'
		qui sa `olddata', replace
	}

	tempvar weight2 w2 
	if "`tc'" == "" | "`tc'" == "ate" {
		if "`population'" == "" {
// Eq 4.11, pt1
			qui ge `km's2 = ((1*`w' + `km')^2)*`s2'
		}
		else {
			qui ge `km's2 = ((`km')^2 + 2*`km' - `km'2)*`s2'			
			qui replace `km's2 = `w'*(`y'`hat'1 - 		///
				`y'`hat'0 - `T')^2 + `km's2
		}
		qui egen `weight2' = sum(`w') 
		scal `w2' = `weight2'[1]
	}
	if "`tc'" == "att" {
		if "`population'" == "" {
// Eq 4.12, pt1
			qui ge `km's2 = ((`t'*`w' + (1-`t')*`km')^2)*`s2'
		}
		else {
			qui ge `km's2 = (1-`t')*(`km'^2 - `km'2)*`s2' 			
			qui replace `km's2 = `km's2 + `w'*`t'*(		///
				(`y'`hat'1 - `y'`hat'0 - `T')^2) 
		}			
		qui egen `weight2' = sum(`w') if `t' == 1
		qui egen `weight2'2 = mean(`weight2')
		scal `w2' = `weight2'2[1]
	}
	if "`tc'" == "atc" {
		if "`population'" == "" {
// Eq 4.13, pt1
			qui ge `km's2 = (((1-`t')*`w' + `t'*`km')^2)*`s2'
		}
		else {
			qui ge `km's2 = `t'*(`km'^2 - `km'2)*`s2'			
			qui replace `km's2 = `w'*(1-`t')*(`y'`hat'1 	///
				- `y'`hat'0 - `T')^2 + `km's2
		}	
		qui egen `weight2' = sum(`w') if `t' == 0
		qui egen `weight2'2 = mean(`weight2')
		scal `w2' = `weight2'2[1]
	}

// Note: if "`weight'" == "": 
//  ate: `w2' = N
//  att: `w2' = n1
//  atc: `w2' = n0

// Eq 4.11-13, pt2
	tempvar V1 V2 V
	egen `V1' = sum(`km's2)
	scal `V2' = ((1/`w2')^2)*`V1'[1]
	loc se = (`V2')^0.5
	matr `V' = `V2'

	if "`tc'" == "" | "`tc'" == "ate" {
		mat coln `V' = "`c'ATE"
		mat rown `V' = "`c'ATE"
	}
	else {
		if "`tc'" == "att" {
			mat coln `V' = "`c'ATT"
			mat rown `V' = "`c'ATT"
		}
		else {
			mat coln `V' = "`c'ATC"
			mat rown `V' = "`c'ATC"
		}
	}

	ereturn post `b' `V', esample(`touse') depname(`y') 
	eret loc depvar "`y'"
	eret loc match_ind "`t'"
	eret loc match_vars "`Xvars'"
	if "`weight'" ~= "" {
		eret loc wtype "`weight'"
		eret loc wexp "`exp'"
	}
	eret scal N = `N'
	eret scal m = `m'
	eret scal se = `se'
	if "`tc'" == "" | "`tc'" == "ate" {
		eret loc stat `c'ATE
	}
	else {
		if "`tc'" == "att" {			
			eret loc stat `c'ATT
		}
		else {
			eret loc stat `c'ATC
		}
	}

	if "`metric'" ~= "" & "`metric'" ~= "maha" {
		tempname metric2
		matr `metric2' = `metric'
		eret matr metric `metric2'
	}

	if `h' == 0 {
		eret scal sigma2 = `s2'
	}
	if `h' > 0 {
		eret scal h = `h'
	}

	if "`keep'" ~= "" {
		eret loc newdata "`keep'.dta"
	}
	
	if "`biasadj'" == "" {
		eret loc bias "none"
	}
	else {
		eret loc bias "`biasadj'"
	}

	if `k' > 0 {
		if "`metric'" == "" {
			eret loc metric "default"
		}
		if "`metric'" == "maha" {
			eret loc metric "Maha"
		}
		if "`metric'" ~= "" & "`metric'" ~= "maha" {
			eret loc metric "`metric'"
		}
	}
	output `varlist', n1(`n1') te(`T') se(`se') m(`m') 		///
		tc(`tc') met(`metric') ex(`exact') bias(`biasadj') 	///
		pop(`population') rob(`h') wei(`exp') lev(`level') 	///
		per(`per')
	eret loc cmd "nnmatch"

end
