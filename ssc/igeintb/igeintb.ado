*! igeintb v 9
*! Pablo Mitnik
*!
*! Set estimates IGEs with multiple sets of instruments, computes confidence intervals that are appropriate for partially 
*! identified IGEs estimated in intersection-bounds contexts, and optionally provides half-median unbiased (hmu) estimates of the upper bound
*!
*! Last updated Feb. 2019

program igeintb, eclass

	version 13
	syntax varlist (min=2 max=2) [if] [in] [fw pw iw], insts1(varlist) insts2(varlist) ige(string) [exvars(varlist) insts3(varlist) insts4(varlist) insts5(varlist) insts6(varlist) ///
	                insts7(varlist) insts8(varlist) insts9(varlist) insts10(varlist) hmu gmm Cluster(varlist) TECHnique(string) Level(cilevel) nsim(integer 10000) seed(integer 123456789) show ]
	                
	/*1. Process and check inputs*/
	
	local cvar : word 1 of `varlist'
	local pvar : word 2 of `varlist'
	
	if "`ige'" != "igeg" & "`ige'" != "igee" {
		di as error "ige option may only be igeg or igee"
		exit 198
	}
	
	local ninstsets = 0
	
	foreach cand of numlist 1/10 {
	
		if "`insts`cand''" != "" {
			local ninstsets = `ninstsets' + 1
		}
	}
	
	local startempty = `ninstsets' + 1
	
	if `startempty' < 10 {
		foreach instset of numlist `startempty'/10 {
			if "`insts`instset''"!="" {
				di as error "cannot specify set of instrumetns `instset' if any of the set of instruments 1 to `ninstsets' has not been specified"
				exit 198
			}
		}
	}

	if "`ige'"=="igeg" {
		if "`gmm'"=="" local est 2sls
		else if "`gmm'"!="" local est gmm
	}
	
	else if "`ige'"=="igee" local est gmm
	
	if `"`exp'"' != "" local wgt `"[`weight' `exp']"'
	else local wgt
	
	if "`ige'" == "igeg" local cmd regress
	else if "`ige'" == "igee" local cmd poisson
	
	if "`show'"=="" local mod qui
	else if "`show'"!="" local mod noi
	
	tempname current
	_estimates hold `current', restore nullok	
	preserve 

	/*2. Common sample*/
	
	marksample touse
	markout `touse' `cvar' `pvar' `exvars' `insts1' `insts2' `insts3' `insts4' `insts5' `insts6' `insts7' `insts8' `insts9' `insts10' `cluster'
		
	qui keep if `touse'
	qui gen __id =_n
	tempfile msamp
	qui save `msamp', replace
	
	/*3. Intrument-set-specific samples/variables*/

	foreach instset of numlist 1/`ninstsets' {  
	
		qui use `msamp', clear

		qui gen __one_`instset' = 1
		qui gen __pvar_`instset'= `pvar'

		foreach evar in `exvars' {
			qui gen __ex`evar'_`instset'=`evar'
		}

		foreach inst in `insts`instset'' {
			qui gen __ins`inst'_`instset' = `inst'
		}
		tempfile samp`instset'
		qui save `samp`instset'', replace
	}	

	/*4.Combine samples*/

	clear

	foreach instset of numlist 1/`ninstsets' {

		append using `samp`instset''
	}
	
	if "`exvars'"=="" local ex
	else local ex __ex*

	foreach var of varlist __one* __pvar* `ex' __ins* {

		qui replace `var'=0 if `var'==.
	}

	tempfile expmsamp
	qui save `expmsamp', replace

	/*5. Estimate upper bounds, and compute correlation matrices and contact set*/

	/*Joint estimation*/

	di ""
	di as result "Joint estimation of upper bounds of partially identified IGE. . ."
	di ""

	qui use `expmsamp', clear
	
	if "`cluster'" == "" local clu __id
	else if "`cluster'" != "" local clu `cluster'
	
	if "`ige'"=="igee" | ("`ige'"=="igeg" & "`est'"=="gmm") local wm wmatrix(robust)	
	else if "`ige'"=="igeg" & "`est'"=="2sls" local wm
			
	if "`technique'" != "" local tech technique(`technique')
	else if "`technique'" == "" {
		local tech
		if "`ige'"=="igee" local technique gn
	}
	
	if "`level'"=="" local lev
	else if "`level'"!="" local lev level(`level')
	
	`mod' iv`cmd' `est' `cvar' __one* `ex' (__pvar* = __ins*) `wgt', `wm' vce(cluster `clu') nocons `tech' `lev'
	
	tempname peub seub /*row vectors with point estimates and standard errors*/
	tempname minpeub   

	matrix `peub' = e(b)
	matrix `peub'=`peub'[1, 1..`ninstsets']
	mata: st_numscalar("`minpeub'", min(st_matrix("`peub'")))

	local insindex
	foreach index of numlist 1/`ninstsets' {	
		if `peub'[1,`index']==`minpeub' local insindex = `index'		
	}
	
	matrix `seub' = e(V)
	matrix `seub' = vecdiag(`seub')
	matrix `seub' = `seub'[1, 1..`ninstsets']
	foreach col of numlist 1/`ninstsets' {
		matrix `seub'[1, `col'] = (`seub'[1, `col'])^(1/2)
	}

	/*Overall correlation matrix*/

	tempname omega

	mat `omega'=e(V)
	mat `omega'=`omega'[1..`ninstsets', 1..`ninstsets']
	mat `omega' = corr(`omega')	

	/*Contact set*/
	
	if "`show'"!="" di ""
	di as result "Computing contact set using adaptive inequality selection . . ."
	di ""

	qui sum __id	
	local n = r(max)

	local omegaDim = colsof(`omega')

	tempname p_bar k_bar forUstar Ustar forContactset

	scalar `p_bar' = 1 - (1/(10 * ln(`n')))

	mata: st_numscalar("`k_bar'", genQuantP(st_matrix("`omega'"),`omegaDim',`nsim',`seed', st_numscalar("`p_bar'")))

	matrix `forUstar' = `peub' + `k_bar' * `seub'	
	scalar `Ustar' = . 	
	foreach col of numlist 1/`ninstsets' {	
		if `forUstar'[1,`col'] < `Ustar' scalar `Ustar'=`forUstar'[1,`col']
	}	

	matrix `forContactset' =  2 * `k_bar' * `seub'
	foreach col of numlist 1/`ninstsets' {
		mat `forContactset'[1, `col']= `forContactset'[1, `col'] + `Ustar'
	}

	local contact_set

	local cs_dim = 0 
	foreach col of numlist 1/`ninstsets' {
		if `peub'[1,`col'] <= `forContactset'[1,`col'] {
			local contact_set `contact_set' `col'
			local cs_dim = `cs_dim' + 1
		}   
	}

	/*Correlation matrix restricted to contact set*/

	local counter = 0 
	local contact_set_rows
	local contact_set_cols
	foreach item in `contact_set' { 
		local counter = `counter' + 1
		if `counter' == 1 {
			local contact_set_rows (`item' \
			local contact_set_cols (`item',			
		}
		else if `counter' > 1 & `counter' < `cs_dim' {
			local contact_set_rows `contact_set_rows' `item' \
			local contact_set_cols `contact_set_cols' `item',			
		}
		else if `counter' == `cs_dim' {
			local contact_set_rows `contact_set_rows' `item')
			local contact_set_cols `contact_set_cols' `item')			
		}
	}

	tempname omega_contact_set

	mata: st_matrix("`omega_contact_set'", st_matrix("`omega'")[`contact_set_rows', `contact_set_cols'])

	/*6. Estimate lower bound*/

	di as result "Estimation of lower bound of partially identified IGE. . ."
	di ""	

	qui use `msamp', clear
	
	if "`cluster'" == ""  `mod' `cmd' `cvar' `pvar' `exvars' `wgt', robust `lev'
	else if "`cluster'" != ""  `mod' `cmd' `cvar' `pvar' `exvars' `wgt', cluster(`cluster') `lev'

	tempname pelb selb 

	scalar `pelb' = _b[`pvar']
	scalar `selb' = _se[`pvar']
	
	local n = e(N)
	
	/*7. Compute half-median unbiased estimate of upper bound */
	
	if "`hmu'"!="" {
	
		di as result "Computing half-median unbiased estimate of the upper-bound . . ."
		di ""

		tempname kp_hmu for_minpeub_hmu minpeub_hmu

		mata: st_numscalar("`kp_hmu'", genQuantP(st_matrix("`omega_contact_set'"),`cs_dim',`nsim',`seed', 0.5))
		mat `for_minpeub_hmu' = `peub' + `kp_hmu' * `seub'
		mata: st_numscalar("`minpeub_hmu'", min(st_matrix("`for_minpeub_hmu'")))
	
		local insindex_hmu
		foreach index of numlist 1/`ninstsets' {	
			if `for_minpeub_hmu'[1,`index']==`minpeub_hmu' local insindex_hmu = `index'		
		}
	}
	
	/*8. Compute confidence interval*/

	di as result "Computing confidence interval for partially identified IGE . . ."
	di ""	

	tempname  deltan pn 	
	scalar `deltan' = `minpeub' - `pelb'
	scalar `pn' = 1 - normal(ln(`n') * `deltan') * (1 - (`level'/100))
	
	if "`hmu'"!="" {
		tempname  deltan_hmu pn_hmu	
		scalar `deltan_hmu' = `minpeub_hmu' - `pelb'
		scalar `pn_hmu' = 1 - normal(ln(`n') * `deltan_hmu') * (1 - (`level'/100))
	}
	
	/*upper ci*/

	tempname kpub for_ciub ciub
	if `cs_dim' == 1 scalar `kpub' = invnormal(`pn') 
	else if `cs_dim' > 1 mata: st_numscalar("`kpub'", genQuantP(st_matrix("`omega_contact_set'"),`cs_dim',`nsim',`seed',st_numscalar("`pn'")))
		
	matrix `for_ciub' = `peub' + `kpub' * `seub'
	mata: st_numscalar("`ciub'", min(st_matrix("`for_ciub'")))
	
	if "`hmu'"!="" {

		tempname kpub_hmu for_ciub_hmu ciub_hmu
		if `cs_dim' == 1 scalar `kpub_hmu' = invnormal(`pn_hmu') 
		else if `cs_dim' > 1 mata: st_numscalar("`kpub_hmu'", genQuantP(st_matrix("`omega_contact_set'"),`cs_dim',`nsim',`seed',st_numscalar("`pn_hmu'")))
		matrix `for_ciub_hmu' = `peub' + `kpub_hmu' * `seub'
		mata: st_numscalar("`ciub_hmu'", min(st_matrix("`for_ciub_hmu'")))	
	}

	/*lower ci*/
	tempname kplb cilb
	scalar `kplb' = invnormal(`pn') 
	scalar `cilb' = `pelb' - `kplb' * `selb'
	
	if "`hmu'"!="" {
		tempname kplb_hmu cilb_hmu
		scalar `kplb_hmu' = invnormal(`pn_hmu') 
		scalar `cilb_hmu' = `pelb' - `kplb_hmu' * `selb'
	}	
	

	/*9. Return and display results*/
	
	ereturn post

	if "`ige'"=="igeg" local rige IGE of geometric mean
	else if "`ige'"=="igee" local rige IGE of expectation
	
	ereturn scalar N = `n'
	ereturn scalar pe_lb = `pelb'
	ereturn scalar pe_ub = `minpeub'
	if "`hmu'"!="" ereturn scalar pe_ub_hmu = `minpeub_hmu'	
	ereturn scalar ci_lb = `cilb'
	ereturn scalar ci_ub = `ciub'
	if "`hmu'"!="" {
		ereturn scalar ci_lb_hmu = `cilb_hmu'
		ereturn scalar ci_ub_hmu = `ciub_hmu'
	}
	ereturn scalar k_lb = `kplb'	
	ereturn scalar k_ub = `kpub'
	if "`hmu'"!="" {
		ereturn scalar k_lb_hmu = `kplb_hmu'
		ereturn scalar k_ub_hmu = `kpub_hmu'
	}
	ereturn scalar confidence_level = `level'
	ereturn scalar nsim = `nsim'
	ereturn scalar seed = `seed'	
	
	ereturn scalar confidence_level = `level'	
	
	if "`technique'"!="" ereturn local technique "`technique'"
	if "`cluster'"!="" ereturn local clustvar "`cluster'"
	if "`wgt'"!="" {
		ereturn local wtype "`weight'"
		ereturn local wexp "`exp'"
	}
	
	ereturn local iv_estimator "`est'"
	if "`exvars'"!= "" ereturn local exvars "`exvars'"
	
	if "`hmu'"!="" ereturn local insts_ub_hmu "`insts`insindex_hmu''"
	ereturn local insts_ub "`insts`insindex''"	
	ereturn local pvar "`pvar'"
	ereturn local cvar "`cvar'"
	ereturn local ige "`ige'"
	ereturn local cmd "igeintb"
	
	di as txt "{hline 60}"
	di as text "{p 0 0 0 60}Partially identified `rige'{p_end}"
	di ""
	di as text _col(1) "Set estimate" _col(35) as res %6.5f `pelb' _col(43) as res "- " %6.5f `minpeub'
	di as text _col(1) "`level'% confidence interval" _col(35) as res %6.5f `cilb' _col(43) as res "- " %6.5f `ciub'
	if "`hmu'"!="" {
		di ""
		di as text _col(1) "Based on HMU estimate of upper bound"
		di as text _col(1) "Set estimate" _col(35) as res %6.5f `pelb' _col(43) as res "- " %6.5f `minpeub_hmu'
		di as text _col(1) "`level'% confidence interval" _col(35) as res %6.5f `cilb_hmu' _col(43) as res "- " %6.5f `ciub_hmu'
	}
	di as txt "{hline 60}"	
	di as txt "Note:"
	di as txt "{p 0 2 60}Upper-bound estimate obtained with these instruments:{p_end}"
	di as txt "{p 4 4 6 60}`insts`insindex''{p_end}"
	if "`hmu'"!="" {
		di as txt "{p 0 2 60}HMU upper-bound estimate obtained with these instruments:{p_end}"
		di as txt "{p 4 4 6 60}`insts`insindex_hmu''{p_end}"
	}
		
	restore
	_estimates unhold `current', not
	 
end

/* Mata function for generating quantile of maximum Zu (from program
   imperfectiv, by Benjamin Matta and Damian Clarke) */

cap mata: mata drop genQuantP()
mata:
    function genQuantP(OMEGA,dimOm,R,seed,p) {
        rseed(seed)
        Z  = cholesky(OMEGA)*rnormal(dimOm,R,0,1)
       pk = sort(colmax(Z)',1)[round(R*p),1]

       return(pk)
    }
end
