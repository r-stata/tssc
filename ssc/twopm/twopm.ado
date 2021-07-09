*! version 1.2.3 22apr2015 
*! authors Federico Belotti and Partha Deb
*! see end of file for version comments

program define twopm, eclass byable(onecall) sort prop(ml_score swml svyb svyj svyr mi)
	
    if _by() {
        local BY `"by `_byvars'`_byrc0':"'
    }
	
	local _vv: di "version `c(version_rng)', missing:"
	`_vv' `BY' _vce_parserun twopm, jkopts(eclass): `0'
	if "`s(exit)'" != "" {
		`_vv' ereturn local cmdline `"twopm `0'"'
		exit
	}
	
    if replay() {
		if "`e(cmd)'" ~= "twopm" error 301
		_twopm_display `0'
	}
	
	if _by() `BY' twopm_est `0'
	else twopm_est `0'
	
	twopm_clean
	
end


*** twopm command
program define twopm_est,  eclass byable(recall) sortpreserve
version 11

local vv: di "version `c(version_rng)', missing:"	

/* two syntax, handle one at a time (adapted from biprobit.ado) */

gettoken first : 0, match(paren)

if "`paren'" == "" {
	/* syntax 1, same regressors */
	
	syntax varlist(min=1 numeric fv) [if] [in] [iw aw pw], ///
				      Firstpart(string) Secondpart(string) ///
					  [ vce(passthru) Robust CLuster(string) /// vce options 
		 			   heteroskedastic(string) SUEST *]
	
	*** Tokenize varlist
	gettoken lhs rhs1: varlist
	local rhs2 `"`rhs1'"'
}
else {
	/* syntax 2, seemingly unrelated bivariate probit model */

	/* get first equation */
	gettoken first 0:0, parse(" ,[") match(paren)
	local left "`0'"
	local junk: subinstr local first ":" ":", count(local number)
	if "`number'" == "1" {
		gettoken lhs1n first: first, parse(":")
		gettoken junk first: first, parse(":")
	}
	local first : subinstr local first "=" " "
	gettoken lhs1 0: first, parse(" ,[") 
	if "`lhs1n'" != "" {
		di as error "Equation name cannot be specified."
		error 198
	}
	if "`lhs1n'" == "" {
		local lhs1n "`lhs1'"
	}
	syntax [varlist(min=1 numeric fv)]
	local rhs1 `varlist'

	/* get second equation */
	local 0 "`left'"
	gettoken second 0:0, parse(" ,[") match(paren)
	if "`paren'" != "(" {
		dis in red "two equations required"
		exit 110
	}
	local left "`0'"
	local junk : subinstr local second ":" ":", count(local number)
	if "`number'" == "1" {
		gettoken lhs2n second: second, parse(":")
		gettoken junk second: second, parse(":")
	}
	local second : subinstr local second "=" " "
	gettoken lhs2 0: second, parse(" ,[") 
	if "`lhs2n'" != "" {
		di as error "Equation name cannot be specified."
		error 198
	}
	if "`lhs2n'" == "" {
		local lhs2n "`lhs2'"
	}
	syntax [varlist(min=1 numeric fv)]
	local rhs2 `varlist'
	
	if "`lhs1'"!="`lhs2'" {
		dis in red "The dependent variable must be the same in both equations"
		exit 110
	}
	else local lhs `lhs1'
	
				/* remain options */
	local 0 "`left'"
	syntax [if] [in] [iw aw pw], ///
			Firstpart(string) Secondpart(string) ///
			[ vce(passthru) Robust CLuster(string) /// vce options 
		 	 heteroskedastic(string) SUEST *]
		
}

*** Drop _het structure
cap mata: mata drop _het

*** Parsing of display options
_get_diopts diopts options, `options'
* NOEMPTY as default
local diopts "noempty `diopts'"
local diopts: list uniq diopts

*** Marksample:
marksample touse

*** Tokenize options
gettoken first first_opt: firstpart, parse(",")
if "`first_opt'" != "" local first_opt = regexr("`first_opt'", "^," , "")
gettoken second second_opt: secondpart, parse(",")
if "`second_opt'" != "" local second_opt = regexr("`second_opt'", "^," , "")

*** Treat exp(b) display option for the first part
ParseOrf _for : `"`first_opt'"'
ParseOrs _sor : `"`second_opt'"'

*** Check models' options
local check_types = regexm("`firstpart'", "logit") + ///
					regexm("`firstpart'", "probit") + ///
					regexm("`secondpart'", "glm") + ///
					regexm("`secondpart'", "regress") 

if `check_types' != 2 {
	di as error "twopm allows only logit or probit as 1st part and glm or regress as 2nd part." 
	error 198
} 


local vce_parts "first_opt second_opt" 
foreach vcepart of local vce_parts {
	local check_vce = regexm("``vcepart''", "vce") + ///
		regexm("``vcepart''", "^r") + ///  
		regexm("``vcepart''", "^cl")       
	if `check_vce' >= 1 {
		di as error "robust, cluster() and vce() options must be specified using twopm syntax."
		error 198
	} 
}
if "`robust'" != "" {
	local vce vce(robust)
	}
if "`cluster'" != "" {
	local vce vce(cluster `cluster')
	}

*** vce parsing
if "`vce'"!="" & regexm("`vce'", "boot")==0 & regexm("`vce'", "jack")==0  {		
	`vv' _vce_parse, argopt(CLuster) opt(OIM OPG Robust) : [`weight'`exp'], `vce'
	
	if "`r(cluster)'" != "" {
			local clustvar `r(cluster)'
			local vce_est cluster `r(cluster)'
			local vcetype Robust
			local vce cluster
	}
	else if "`r(robust)'" != "" {
			local vce_est robust
			local vcetype Robust
			local vce robust
	}
	else if "`r(vce)'" != "" {
		local vce "`r(vce)'"
		local vce_est "`r(vce)'"
		if regexm("`vce'", "oim") local vcetype "OIM"
		if regexm("`vce'", "opg") local vcetype "OPG"
	}
}


*** Gen dummy variable for the first part
tempvar lhs_`first'
qui gen `lhs_`first''=(`lhs'>0) if `touse'
di _n as result "Fitting `first' regression for first part:" 
if "`first'" == "logit"  `vv' logit `lhs_`first'' `rhs1' [`weight' `exp'] ///
	if `touse', `first_opt' vce(`vce_est') nocoef 
if "`first'" == "probit" `vv' probit `lhs_`first'' `rhs1' [`weight' `exp'] ///
	if `touse', `first_opt' vce(`vce_est') nocoef

/// Suest estimation	
if "`suest'"!="" {
local vce_est 
local vcetype Robust
	if "$ChEcK_SvY_twopm___"=="" {
		tempname suest1
		est sto `suest1'
	}
}

if "$ChEcK_SvY_twopm___"!="" {
	
	if "`paren'" != "" {
		di as error "The two-equations syntax cannot be used when the -svy- prefix is specified." 
		error 198
	}
	
	*** Compute df_r for the first part if svyset 
	** this is needed for a correct CI display
	tempvar _group_`first' counter counter1 counter2
	tempname df_r_`first'
	local _svy_strata1: char _dta[_svy_strata1]
	local _svy_su1: char _dta[_svy_su1]
	
	cap confirm var `_svy_su1'
	local ___rcsu1 = _rc
	cap confirm var `_svy_strata1'
	local ___rcstrata1 = _rc
	
	if `___rcstrata1' == 0 {
			tempvar _svy_strata1_tmp
			qui gen `_svy_strata1_tmp' = `_svy_strata1' if `touse' & e(sample)==1
			qui bys `_svy_strata1_tmp': gen `counter'=1 if _n == _N
			qui count if `counter'==1
			local _N_Strata_`first' = r(N)
			if "`_svy_su1'" != "_n" & "`_svy_su1'" != ""  & `___rcsu1'==0 {
				qui egen `_group_`first'' = group(`_svy_strata1' `_svy_su1') if `touse' & e(sample)==1
				qui bys `_group_`first'': gen `counter1'=1 if _n == _N & `touse' & e(sample)==1
				qui count if `counter1'==1
				local _N_clust_`first' = r(N)
			}
			else {
				qui count if `touse' & e(sample)==1
				local _N_clust_`first' = r(N)
			}
			scalar `df_r_`first'' = `_N_clust_`first'' - `_N_Strata_`first''
	}
	else {
			local _N_Strata_`first' = 1
			if "`_svy_su1'" != "_n" & "`_svy_su1'" != ""  & `___rcsu1'==0 {
				qui egen `_group_`first'' = group(`_svy_su1') if `touse' & e(sample)==1
				qui bys `_group_`first'': gen `counter1'=1 if _n == _N & `touse' & e(sample)==1
				qui count if `counter1'==1
				local _N_clust_`first' = r(N)
			}
			else {
				qui count if `touse' & e(sample)==1
				local _N_clust_`first' = r(N)
			}
			scalar `df_r_`first'' = `_N_clust_`first'' - `_N_Strata_`first''
	}
}

*** get first part's results
tempname b1 names1
mat `b1' = e(b)
mata: v1 = st_matrix("e(V)")
mata: names1 = st_matrixcolstripe("e(b)")
mata: names1 = regexr(names1, "`lhs_`first''", "`first'")

*** Here, what we pass to ereturn from -first part-
local eret_scalar "N N_cds N_cdf k k_eq k_eq_model k_dv k_autoCns df_m r2_p ll ll_0 N_clust chi2 p rank ic rc converged"
foreach element of local eret_scalar {
	tempname `element'_`first'
	if "`e(`element')'" != "" scalar ``element'_`first'' = e(`element')
	local eret_scalar_fp "`eret_scalar_fp' `element'_`first'"
}

local eret_macros "offset chi2type opt which ml_method user technique singularHmethod crittype asbalanced asobserved"
foreach element of local eret_macros {
	if "`e(`element')'" != "" local `element'_`first' "`e(`element')'"
	local eret_macros_fp "`eret_macros_fp' `element'_`first'"
}     

*** This is necessary to get the likelihood even in the svy case
mata: _ilog_fp = st_matrix("e(ilog)")
mata: _ll_fp = select(_ilog_fp, _ilog_fp:!=0)
mata: _ll_fp = _ll_fp[1,cols(_ll_fp)]
mata: st_numscalar("`ll_`first''", _ll_fp)

*** Set esample and number of obs: we need "first part" e() results
tempvar esample
qui gen `esample' = e(sample) 
local obs = e(N)

if "`second'" == "regress" di _n "Fitting OLS regression for second part:"
else di _n "Fitting `second' regression for second part:"
if "`second'" == "regress" {
	local second_name "regress"
	tempvar reglhs
	qui gen `reglhs' = `lhs'
	if regexm("`second_opt'", "log") {
		qui replace `reglhs' = ln(`lhs') if `lhs'>0
		local second_opt = regexr("`second_opt'","log","")
		local second "regress_log"
	}
	if "$ChEcK_SvY_twopm___"!="" {
		local second_opt = regexr("`second_opt'","mse1","")
		local second_opt "`second_opt' mse1"
	}
	 
	`vv' regress `reglhs' `rhs2' [`weight' `exp'] ///
	if `touse' & `lhs'>0, `second_opt' vce(`vce_est') notable noheader
}

if "`second'" == "glm" {
	local second_name "glm"
	`vv' glm `lhs' `rhs2' [`weight' `exp'] ///
	if `touse' & `lhs'>0, `second_opt' vce(`vce_est') nodisplay  
	
	*** hold estimates to correctly compute scores using svy prefix
	est sto ___glm
	qui cap drop _est____glm 
}

if "`suest'"!="" & "$ChEcK_SvY_twopm___"=="" {
	tempname suest2
	est sto `suest2'
}

*** get second part's results
tempname b2 v2
mat `b2' = e(b)
mata: v2=st_matrix("e(V)")
mata: names2 = st_matrixcolstripe("e(b)")

*** Manages regress estimation 
if regexm("`second'", "regress") == 1 mata: names2[.,1]=J(rows(names2),1,"`second'")

*** Manages the IRLS estimation
if regexm("`second_opt'", "irls") == 1  mata: names2[.,1]=J(rows(names2),1,"`second'")
else mata: names2[.,1] = regexr(names2[.,1], "`lhs'", "`second'")

tempname b V
mata: V = blockdiag(v1,v2)
mata: st_matrix("`V'",V)
mat `b' = (`b1',`b2')

if "$ChEcK_SvY_twopm___"!="" {
	
	*** Compute df_r for the second part if svyset 
	** this is needed for a correct CI display
	tempvar _group_`second_name' 
	tempname df_r_`second_name'

	if `___rcstrata1' == 0 & "$ChEcK_SvY_twopm___"!="" {
			local  _N_Strata_`second_name' = `_N_Strata_`first''
			if "`_svy_su1'" != "_n" & "`_svy_su1'" != "" & `___rcsu1'==0 {
				qui egen `_group_`second_name'' = group(`_svy_strata1' `_svy_su1') if `touse' & e(sample)==1
				qui bys `_group_`second_name'': gen `counter2'=1 if _n == _N & `touse' & e(sample)==1
				qui count if `counter2'==1
				local _N_clust_`second_name' = r(N)
			}
			else {
				qui count if `touse' & e(sample)==1
				local _N_clust_`second_name' = r(N)
			}
			scalar `df_r_`second_name'' = `_N_clust_`second_name'' - `_N_Strata_`second_name'' 
	}
	else {
			local _N_Strata_`second_name' = 1
			if "`_svy_su1'" != "_n" & "`_svy_su1'" != "" & `___rcsu1'==0 {
				qui egen `_group_`second_name'' = group(`_svy_su1') if `touse' & e(sample)==1
				qui bys `_group_`second_name'': gen `counter2'=1 if _n == _N & `touse' & e(sample)==1
				qui count if `counter2'==1
				local _N_clust_`second_name' = r(N)
			}
			else {
				qui count if `touse' & e(sample)==1
				local _N_clust_`second_name' = r(N)
			}
			scalar `df_r_`second_name'' = `_N_clust_`second_name'' - `_N_Strata_`second_name'' 
	}
}
else {
	if "`second_name'" == "regress" local _dfr_ "df_r"
}

if "`second_name'" == "regress" {

	*** Here, what we pass to ereturn from regress
	local eret_scalar "df_m `_dfr_' F r2 rmse mss rss r2_a ll_0 ll N rank N_clust"
	local eret_macros "asbalanced asobserved"
	
	foreach element of local eret_scalar {
		tempname `element'_`second_name'
		if "`e(`element')'" != "" scalar ``element'_`second_name'' = e(`element')
		local eret_scalar_sp "`eret_scalar_sp' `element'_`second_name'"
	}
		
	foreach element of local eret_macros {
		if "`e(`element')'" != "" local `element'_`second_name' "`e(`element')'"
		local eret_macros_sp "`eret_macros_sp' `element'_`second_name'"
	}
	
}
else {

	*** Here, what we pass to ereturn from -glm- 	
	local eret_scalar "N k k_eq k_eq_model k_dv k_autoCns df_m df phi aic bic ll N_clust chi2 p deviance deviance_s deviance_p deviance_ps dispers dispers_s dispers_p dispers_ps nbml vf power rank ic rc converged"
	foreach element of local eret_scalar {
		tempname `element'_`second'
		if "`e(`element')'" != "" scalar ``element'_`second'' = e(`element')
		local eret_scalar_sp "`eret_scalar_sp' `element'_`second'"
	}

	local eret_macros "varfunc varfunct varfuncf link linkt linkf m offset chi2type cons hac_kernel hac_lag opt opt1 opt2 which ml_method user technique singularHmethod crittype properties predict asbalanced asobserved"	
	foreach element of local eret_macros {
		if "`e(`element')'" != "" local `element'_`second' "`e(`element')'"
		local eret_macros_sp "`eret_macros_sp' `element'_`second'"
	}
	
	if regexm("`second_opt'", "irls") == 0 {
		*** This is necessary to get the likelihood even in the svy case
		mata: _ilog_sp = st_matrix("e(ilog)")
		mata: _ll_sp = select(_ilog_sp, _ilog_sp:!=0)
		mata: _ll_sp = _ll_sp[1,cols(_ll_sp)]
		local second_name = trim(regexr("`second'", "_log", ""))
		mata: st_numscalar("`ll_`second_name''", _ll_sp)
	}
	
}

if "`suest'"!="" & "$ChEcK_SvY_twopm___"=="" {
	local __fix = colsof(`b')
	cap qui suest `suest1' `suest2'
	if _rc != 0 {
		di as error "Warning: suest estimation cannot be performed."
		exit 110
	}	
	mat `b' = e(b)
	mat `b' = `b'[1,1..`__fix']
	mat `V' = e(V)
	mat `V' = `V'[1..`__fix',1..`__fix']
}

*** Fix names of b and V in order to post to Stata
mata: st_matrixcolstripe("`b'", (names1 \ names2))
mata: st_matrixcolstripe("`V'", (names1 \ names2))
mata: st_matrixrowstripe("`V'", (names1 \ names2))

*** Post results to e()
* Common post
eret post `b' `V', e(`esample') dep(`lhs') o(`obs')
eret local cmd "twopm"
eret local predict "twopm_p"
if "`paren'" == "" eret local covariates "`rhs'"
else {
	eret local covariates_`first' "`rhs1'"
	eret local covariates_`second_name' "`rhs2'"
}
eret local eqnames "`first' `second'"
if "`vce'" != "" eret local vce "`vce'"
if "`vcetype'" != "" eret local vcetype "`vcetype'"
if "`clustvar'" != "" eret local clustvar "`clustvar'"
// amazing that this change fixes the normal problem
eret local marginsok "default normal duan"

*1st part
foreach name of local eret_scalar_fp {
	cap confirm scalar ``name''
 	if _rc==0 {
		eret scalar `name' = ``name''
	}
}
foreach name of local eret_macros_fp {
 	if "``name''"!="" {
		eret local `name' "``name''"
	}
}
if "`df_r_`first''"!="" eret scalar df_r_`first' = `df_r_`first''

*2nd part
foreach name of local eret_scalar_sp {
	cap confirm scalar ``name''
 	if _rc==0 {
		eret scalar `name' = ``name''
	}
}
foreach name of local eret_macros_sp {
 	if "``name''"!="" {
		eret local `name' "``name''"
	}
}

if "`df_r_`second_name''"!="" eret scalar df_r_`second_name' = `df_r_`second_name''

** twopm criterion function value
eret scalar ll = e(ll_`first') + e(ll_`second_name')

if "`second'" == "regress_log" {
	tempvar resid smear1 smear2 esample
	tempname b b_retransf
	qui gen `resid' = .
	mat `b' = e(b)
	mat `b_retransf' = `b'[1,"regress_log:"]
	mata: resid = _resid("`reglhs'", "`rhs2'", "`touse'", "`b_retransf'")
 	mata: esample = st_addvar("double", st_tempname())
	qui gen `esample' = (`touse'==1)           
	mata: st_view(esample, ., "`esample'")
	mata: rule = mm_which(esample)
	mata: st_store(rule,"`resid'", resid)
	
	if "`heteroskedastic'" != "" {
		mata: _het = J(1, 2, _hetero())
		
		qui egen double `smear1' = mean(`resid'^2), by(`heteroskedastic')
		mata: _het = _for_retransf("`smear1'", "`touse'", _het, 1)	
		
		qui egen double `smear2' = mean(exp(`resid')), by(`heteroskedastic')
		mata: _het = _for_retransf("`smear2'", "`touse'", _het, 2)
		
	}
	else {
		qui egen double `smear1' = mean(`resid'^2)
		sum `smear1', mean
		eret scalar sigma2 = `r(mean)'
		qui egen double `smear2' = mean(exp(`resid'))
		sum `smear2', mean
		eret scalar duan = `r(mean)'
	}
}

*** Display results ***
_twopm_display, level(`level') orf(`_for') ors(`_sor') `diopts'
***********************

end


//// Mata functions
/// FEDE: simple mataf for retransf

mata

struct _hetero {
	real vector sigma2, duan
}

struct _hetero vector _for_retransf(string scalar init_mat, string scalar touse, struct _hetero vector _het, real scalar i)
{		
	retransf = st_data(., tokens(init_mat), touse)	
	if (i==1) _het.sigma2 = retransf
	if (i==2) _het.duan = retransf
	return(_het)
}

real matrix _resid(string scalar reglhs, 
    			   string scalar rhs, 
    			   string scalar touse,
				   string scalar matname) 
{

real vector b, Y, resid, xb
real matrix X

// get data
Y = st_data(., tokens(reglhs), touse)	
X = st_data(., tokens(rhs), touse)
b = st_matrix(matname)

if (cols(b) > cols(X))  X = (X, J(rows(X),1,1))
xb = X * b'
resid = editvalue(Y, 0, .) - xb

return(resid)

}


// mm_which.mata
// version 1.0.2, Ben Jann, 17apr2007
// version 9.2
real matrix mm_which(real vector I)
{
        if (cols(I)!=1) return(select(1..cols(I), I))
        else return(select(1::rows(I), I))
}


end


*** Ancillary programs

prog define _twopm_display, eclass
syntax[, level(string) orf(integer 0) ors(integer 0) * ]

tempname tabdisp
.`tabdisp' = ._tab.new, col(1) lmargin(0)
.`tabdisp'.width 78

///////////////////////////
//////// FIRST PART //////
///////////////////////////

	#delimit ;
		di _n as result "Two-part model";
		.`tabdisp'.sep, top;
		if "`e(vcetype)'"=="OIM" | "`e(vcetype)'"=="OPG"	
		di _col(1) as text "Log likelihood" _col(16) "=" 
		_col(18) as result %10.0g `e(ll)' _col(51) as text "Number of obs" _col(67) "= " as result %10.0f `e(N)';
		else 
		di _col(1) as text "Log pseudolikelihood" _col(22) "=" 
		_col(24) as result %10.0g `e(ll)' _col(51) as text "Number of obs" _col(67) "= " as result %10.0f `e(N)';
		
		di _n as result "Part 1: `:word 1 of `e(eqnames)''";
		.`tabdisp'.sep, top;
		_twopm_coef_table_header, part(`:word 1 of `e(eqnames)'');
	#delimit cr

	///////////////////////////
	//////// SECOND PART //////
	///////////////////////////
	// FEDE: for regress header display
	if regexm("`:word 2 of `e(eqnames)''", "regress") {
		di _n as result "Part 2: `:word 2 of `e(eqnames)''"
		.`tabdisp'.sep, top
		local eq2_name = regexr("`:word 2 of `e(eqnames)''","_log","")
		_twopm_coef_table_header, part(`eq2_name')
	}
	else {
		di _n as result "Part 2: `:word 2 of `e(eqnames)''"
		.`tabdisp'.sep, top
		di _col(52) as text "Number of obs" _col(68) "=" _col(70) as result %9.0g `e(N_glm)'
			di as txt "Deviance" _col(18) "=" as res _col(20) %12.0g e(deviance_glm) /*
			*/ as txt _col(52) "(1/df) Deviance" /*
			*/ _col(68) "=" as res _col(70) %9.0g e(dispers_glm)
		di as txt "Pearson" _col(18) "=" as res _col(20) %12.0g e(deviance_p_glm) /*
			*/ as txt _col(52) "(1/df) Pearson" /*
			*/ _col(68) "=" as res _col(70) %9.0g e(dispers_p_glm)
	
		di
		di as txt "Variance function: " as res "V(u) = " /*
	                        */ as res _col(27) "`e(varfuncf_glm)'" /*
	                        */ _col(52) as txt "[" as res "`e(varfunct_glm)'" as txt "]"
	
		di as txt "Link function    : " as res "g(u) = " /*
			*/ as res _col(27) "`e(linkf_glm)'" /*
			*/ _col(52) as txt "[" as res "`e(linkt_glm)'" as txt "]"
	
		if "`e(ll_glm)'" != "" {
			local cr
			di
			local crtype = upper(substr(`"`e(crittype_glm)'"',1,1)) + ///
				substr(`"`e(crittype_glm)'"',2,.)
			local crlen = max(18,length(`"`crtype'"') + 2)
			di as txt _col(52) "{help j_glmic##|_new:AIC}" _col(68) "=" ///
				as res _col(70) %9.0g e(aic_glm)
			di as txt "`crtype'" _col(`crlen') "= " ///
				as res %12.0g e(ll_glm) _c
		}
		else if "`e(disp_glm)'" != "" & "`e(disp_glm)'" != "1" {
			local cr
			`di'
			di
			di as txt "Quasi-likelihood model with dispersion: " /*
				*/ as res `e(disp_glm)' _c
		}
		if "`e(ll_glm)'" != "" {
			di as txt `cr' _col(52) "{help j_glmic##|_new:BIC}" ///
				  _col(68) "=" as res _col(70) %9.0g e(bic_glm)
		}
		else {
			di as txt `cr' _col(52) "BIC" _col(68) "=" ///
				  as res _col(70) %9.0g e(bic_glm)
		}
	}
	
	*** Fix the "offset display" and the number of cluster (if robust) issues
	if regexm("`:word 2 of `e(eqnames)''", "regress") local eq2_name = regexr("`:word 2 of `e(eqnames)''","_log","")
	else local eq2_name "`:word 2 of `e(eqnames)''"
	if "`e(offset_`:word 1 of `e(eqnames)'')'"=="`e(offset_`eq2_name')'" eret local offset "`e(offset_`eq2_name')'"
	if "`e(clustvar)'"!="" & "`e(N_clust_`:word 1 of `e(eqnames)'')'"=="`e(N_clust_`eq2_name')'" eret scalar N_clust = `e(N_clust_`eq2_name')'
	

	if "`orf'"=="0" & "`ors'"=="0" _coef_table, `options'
	if "`orf'"=="1" & "`ors'"=="1" eret di, eform("exp(b)") `options'
	if "`orf'"=="1" & "`ors'"=="0" _coef_table, or `options' 
	if "`orf'"=="0" & "`ors'"=="1" {
		di in yel "Option -or- has been set for the first part too"
		eret di, eform("exp(b)") `options'	
	}
	if "`e(offset)'"=="" & "`e(offset_`:word 1 of `e(eqnames)'')'"!= "" di in gr "(offset_`:word 1 of `e(eqnames)'') = `e(offset_`:word 1 of `e(eqnames)'')'" 
	if "`e(offset)'"=="" & "`e(offset_`eq2_name')'"!= "" di in gr "(offset_`eq2_name') = `e(offset_`eq2_name')'" 
	if "`e(clustvar)'"!="" & "`e(N_clust)'"=="" & "`e(N_clust_`:word 1 of `e(eqnames)'')'"!="" di in gr "`e(N_clust_`:word 1 of `e(eqnames)'')' clusters in `e(clustvar)' for the first part" 
	if "`e(clustvar)'"!="" & "`e(N_clust)'"=="" & "`e(N_clust_`eq2_name')'"!="" di in gr "`e(N_clust_`eq2_name')' clusters in `e(clustvar)' for the second part"
		             
end



* version 1.3.3  12nov2011
program _twopm_coef_table_header
	version 9
	if !c(noisily) {
		exit
	}
	syntax [,			///
		part(string)    ///
		rclass			///
		noHeader		///
		noMODELtest		///
		TItle(string asis)	///
		nocluster		///
		noRULES			///
		noTVAR			///
	]

	if ("`header'" != "") exit

	tempname left right
	.`left' = {}
	.`right' = {}

	if "`rclass'" == "" {
		local e e
	}
	else	local e r


		local width 78
		local C1 _col(1)
		local c2 18
		local c3 51
		local c4 67
		local c2wfmt 10
		local c4wfmt 10
		local scheme ml


	local C2 _col(`c2')
	local C3 _col(`c3')
	local C4 _col(`c4')
	local max_len_title = `c3' - 2
	local sfmt %13s
	local ablen 14


	if "`rules'" == "" & "`e(rules)'" == "matrix" ///
	 & inlist("`e(cmd)'","logistic","logit","probit") {
		if el(e(rules),1,1) != 0 {
			tempname rules
			matrix `rules' = e(rules)
			di
			_binperfout `rules'
		}
	}

	// display title
	if `"`title'"' == "" {
		local title  `"``e'(title)'"'
		local title2 `"``e'(title2)'"'
	}

	// Right hand header ************************************************

	// display N obs
	.`right'.Arrpush					///
		`C3' "Number of obs" `C4' "= "			///
		as res %`c4wfmt'.0f `e'(N_`part')

	if `"`e(k_eq_model_`part')'"' == "0" {
		local modeltest nomodeltest
	}
	if "`modeltest'" == ""  & "`e'" == "e" & !missing(e(df_m_`part')) {
		// display a model test
		if `"`e(chi2_`part')'"' != "" | "`e(df_r_`part')'" == "" {
			Chi2test `right' `C3' `C4' `c4wfmt' `part'
		}
		else {
			Ftest `right' `C3' `C4' `c4wfmt' `part'
		}
	}

	if "`e'" == "e" {
		// display R-squared
		if !missing(`e'(r2_`part')) {
			.`right'.Arrpush			///
				`C3' "R-squared" `C4' "= "	///
				as res %`c4wfmt'.4f `e'(r2_`part')
		}
		if !missing(`e'(r2_p_`part')) {
			.`right'.Arrpush			///
				`C3' "Pseudo R2" `C4' "= "	///
				as res %`c4wfmt'.4f `e'(r2_p_`part')
		}
		if !missing(`e'(r2_a_`part')) {
			.`right'.Arrpush			///
				`C3' "Adj R-squared" `C4' "= "	///
				as res %`c4wfmt'.4f `e'(r2_a_`part')
		}
		if !missing(`e'(rmse_`part')) {
			.`right'.Arrpush			///
				`C3' "Root MSE" `C4' "= "	///
				as res %`c4wfmt'.4f `e'(rmse_`part')
		}
	}

	// number of elements in the left header
	local kl = `.`left'.arrnels'
	
	/* Just to do not show the title in the case of bootstrap vce estimation
	if `"`title'"' != "" & `kl' == 0 {
		// make title line part of the header if it fits
		local len_title : length local title
		if `"`title2'"' != "" {
			local len_title = ///
			max(`len_title',`:length local title2')
		}
		if `len_title' < `max_len_title' {
			.`left'.Arrpush `"`"`title'"'"'
			local title
			if `"`title2'"' != "" {
				.`left'.Arrpush `"`"`title2'"'"'
				local title2
			}
		}
	}
	*/
	
	// put log likelihood at the bottom of the left header
	if "`e'" == "e" & !missing("`e(ll_`part')'") /*& !missing(e(crittype_`part'))*/  {
		// number of elements in the right header
		local kr = `.`right'.arrnels'
		// number of elements in the left header
		local kl = `.`left'.arrnels'
		local space = `kr' - `kl' - 1
		forval i = 1/`space' {
			.`left'.Arrpush ""
		}
		if "`part'" != "regress" local crtype = upper(substr(`"`e(crittype_`part')'"',1,1)) + ///
			substr(`"`e(crittype_`part')'"',2,.)
		else local crtype = upper(substr(`"Log likelihood"',1,1)) + ///
				substr(`"Log likelihood"',2,.)
		.`left'.Arrpush `""`crtype' = " as res %10.0g e(ll_`part')"'
	}

	Display `left' `right' `"`title'"' `"`title2'"'

end

program Display
	args left right title title2

	local nl = `.`left'.arrnels'
	local nr = `.`right'.arrnels'
	local K = max(`nl',`nr')

	/*di
	if `"`title'"' != "" {
		di as txt `"`title'"'
		if `"`title2'"' != "" {
			di as txt `"`title2'"'
		}
		*di
	}
	*/
	
	local c _c
	forval i = 1/`K' {
		di as txt `.`left'[`i']' as txt `.`right'[`i']'
	}
end

program Ftest
	args right C3 C4 c4wfmt part

	local df = e(df_r_`part')
	
	if !missing(e(F_`part')) {
		.`right'.Arrpush				///
			 `C3' "F("				///
		   as res %4.0f e(df_m_`part')				///
		   as txt ","					///
		   as res %7.0f `df' as txt ")" `C4' "= "	///
		   as res %`c4wfmt'.2f e(F_`part')
		.`right'.Arrpush				///
			 `C3' "Prob > F" `C4' "= "		///
		   as res %`c4wfmt'.4f Ftail(e(df_m_`part'),`df',e(F_`part'))
	}
	else {
		local dfm_l : di %4.0f e(df_m_`part')
		local dfm_l2: di %7.0f `df'
		local j_robust "{help j_robustsingular##|_new:F(`dfm_l',`dfm_l2')}"
		.`right'.Arrpush				///
			  `C3' "`j_robust'"			///
		   as txt `C4' "= " as result %`c4wfmt's "."
		.`right'.Arrpush				///
			  `C3' "Prob > F" `C4' "= " as res %`c4wfmt's "."
	}
end

program Chi2test
	args right C3 C4 c4wfmt part

	local type `e(chi2type_`part')'
	if `"`type'"' == "" {
		local type Wald
	}
	if !missing(e(chi2_`part')) {
		.`right'.Arrpush				///
		          `C3' "`type' chi2("			///
		   as res e(df_m_`part')				///
		   as txt ")" `C4' "= "				///
		   as res %`c4wfmt'.2f e(chi2_`part')
		.`right'.Arrpush				///
		          `C3' "Prob > chi2" `C4' "= "		///
		   as res %`c4wfmt'.4f chi2tail(e(df_m_`part'),e(chi2_`part'))
	}
	else {
		local j_robust					///
		"{help j_robustsingular##|_new:`type' chi2(`e(df_m_`part')')}"
		.`right'.Arrpush				///
		          `C3' "`j_robust'"			///
		   as txt `C4' "= " as res %`c4wfmt's "."
		.`right'.Arrpush				///
		          `C3' "Prob > chi2" `C4' "= "		///
		   as res %`c4wfmt's "."
	}
end


program define ParseOrf
	args returmac colon _opt

	local 0 ", `_opt'"
	syntax [, OR * ]
	
	if ("`or'"!="") local _or 1
	else local _or 0
	c_local `returmac' `_or' 			

end

program define ParseOrs
	args returmac colon _opt

	local 0 ", `_opt'"
	syntax [, EFORM * ]
	
	if ("`eform'"!="") local _eform 1
	else local _eform 0
	c_local `returmac' `_eform' 			

end


prog define twopm_clean
syntax

*** Clear mata
capture mata: mata drop _ilog_fp _ll_fp v1 v2 rule esample names1 names2 resid V
capture macro drop ChEcK_SvY_twopm___

end



********************************** VERSION COMMENTS **********************************
* version 1.2.3 22apr2015  - fixed the issue that whenever there is a regressor in the second stage that is named like the outcome variable,
*								it is incorrecly renamed as "*regress" or "*glm"
* version 1.2.2 27nov2012  - fixed itrim(trim()) issue on rhs (no more than 255char in a trimmed local)
*							- correct CI display after svy estimation
*							- Robust as vcetype with -suest- opt 	
* version 1.2.1 16nov2012  - solved svy check problem adding twopm_svy_check.ado
*						- solved suest problem when dta is svyset
*						- solved mse1 option in reg when svy is used
*						- base factor vars cat are not displayed (never) if svy is used
* 						- by prefix fixed
* version 1.2  12nov2012   - display for the number of clusters  
*							- display of the eventual offset variable
*							- two syntax for model specification
* 							- all -glm- family and links are allowed now (in the twopm_p.ado too)
*							- display of exponentiated coefficients (when eform is specified only for the second part, it has been set for the first too)
* version 1.1.1  18oct2012 - tab removed due to "too many values" 
* version 1.1    4aug2012 - moremata mm_which inside twopm.ado. svy bugFix and option suest added
* version 1.0.5  23apr2012
* version 1.0.4  8nov2011
* version 1.0.3  8sep2011
* version 1.0.2  14nov2010
* version 1.0.1  09oct2010



