******************************************************************************
*** ---------------------------------------------------------------------- ***
*** POWER CALCULATIONS USING EXISTING DATASET, ARBITRARY OLS SPECIFICATION ***
*** ---------------------------------------------------------------------- ***
******************************************************************************

*! version 3.0 14apr2020

program define pc_simulate
version `=clip(`c(version)', 9.0, 13.1)'

syntax varname [if] [in], MODel(string) [i(varname) t(varname) p(numlist >0 <1 sort) ///
                          pre(numlist >=0 integer sort) post(numlist >=0 integer sort) n(numlist >0 integer sort) ///
                          mde(numlist sort) ALPha(numlist max=1 >0 <1) ONESIDed TStart(numlist max=2 sort) ///
                          STRATify(varlist) CONTrols(varlist) Absorb(varlist) ABSORBFactor(string) ///
                          vce(string) COLLapse nsim(numlist max=1 >0 integer) Weight(string) reghdfeoptions(string) ///
                          BOOTstrap OUTfile(string) append replace IDCLuster(varname) ///
                          SIZECLuster(numlist max=1 >0 integer) PCLuster(numlist >0 <=1 sort)] 

// 1. Grab file name and store master dataset
{
local master_fname = c(filename)
local tmpdir_pathname = substr("`c(tmpdir)'",1,length("`c(tmpdir)'")-1)
local tmpdir_pathname_len = length("`tmpdir_pathname'")
if substr("`master_fname'",1,`tmpdir_pathname_len')=="`tmpdir_pathname'" {
	local master_fname = ""
}

tempfile m_dta_before_sims
quietly save "`m_dta_before_sims'", replace
}

								
// 2. Fix option name locals
{								
display " "								
local y = subinstr("`1'",",","",1)
local model = upper("`model'")
if inlist("`model'","ONE","ONES","ONESH","ONESHO","ONE-SHOT","ONE SHOT") {
	local model = "ONESHOT"
}
else if inlist("`model'","PO","POS") {
	local model = "POST"
}
else if inlist("`model'","DID","DIFF","DIF","DIF IN DIF") {
	local model = "DD"
}
else if inlist("`model'","AN","ANC","ANCO","ANCOV") {
	local model = "ANCOVA"
}

local vce = lower("`vce'")
if inlist("`vce'","un","una","unad","unadj","unadju","unadjus","unadjust","unadjuste","ols") {
	local vce = "unadjusted"
}
else if inlist("`vce'","r","ro","rob","robu","robus") {
	local vce = "robust"
}
*else if inlist("`vce'","boot","boots","bootst","bootstr","bootstra") {
*	local vce = "bootstrap"
*}
*else if inlist("`vce'","jack","jackk","jackkn","jackkni","jackknif") {
*	local vce = "jackknife"
*}
else if inlist(word("`vce'",1),"cl","clu","clus","clust","cluste") {
	local vce = subinstr("`vce'",word("`vce'",1),"cluster",1)
}

}


// 3. Check for errors in options
{ 
capture confirm numeric variable `y' 
	local rc = _rc
	if `rc' {
		display "{err}Error: Outcome variable must be numeric"
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}
	
capture assert inlist("`model'","ONESHOT","POST","DD","ANCOVA")
	local rc = _rc
	if `rc' {
		display "{err}Error: Option model() must be specified as ONESHOT, POST, DD, or ANCOVA"
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}
	
if "`i'"!="" {	
	capture confirm numeric variable `i' 
		local rc = _rc
		if `rc' {
			display "{err}Error: Cross-sectional unit `i' must be numeric"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
}
else {
	capture tsset
		if !_rc {
			local i = r(panelvar)
			display "{text}Warning: {inp}Cross-sectional unit missing, assumed to be `i'" _n
		}
}

if "`t'"!="" {	
	capture confirm numeric variable `t' 
		local rc = _rc
		if `rc' {
			display "{err}Error: Time period variable `t' must be numeric"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
}
else {
	capture tsset
		if !_rc {
			local t = r(timevar)
			display "{text}Warning: {inp}Time period variable missing, assumed to be `t'" _n
		}
}

if inlist("`model'","POST","DD","ANCOVA") {
	capture assert "`i'"!="" & "`t'"!=""
		local rc = _rc
		if `rc' {
			display "{err}Error: Model `model' requires cross-sectional unit and time period variables to be defined"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
}
else {
	capture assert "`i'"!="" if "`t'"!=""
		local rc = _rc
		if `rc' {
			display "{err}Error: Must specify cross-sectional unit i() if time period unit t() is specified"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}	
}

if "`i'"!="" & "`t'"!="" {
	capture assert "`i'"!="`t'" 
	local rc = _rc
		if `rc' {
			display "{err}Error: Cross-sectional unit i() and time-period unit t() cannot be the same variable "
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
}

if "`p'"=="" { 
	local p = 0.5
	display "{text}Warning: {inp}Option p() missing; default treatment ratio of p=0.5 assumed" _n
}

if "`model'"=="ONESHOT" {
	capture assert ("`pre'"=="0" | "`pre'"=="") & ("`post'"=="1" | "`post'"=="") 
		local rc = _rc
		if `rc' {
			display "{err}Error: ONESHOT model cannot specify any number of periods " 
			display "{err}       other than 0 pre-treatment periods and 1 post-treatment period"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	local pre = ""
	local post = 1
}
else if "`model'"=="POST" {
	capture assert ("`pre'"=="0" | "`pre'"=="") 
		local rc = _rc
		if `rc' {
			display "{err}Error: POST model cannot specify any number of pre-treatment periods besides 0"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	local pre = ""
	capture assert word("`post'",1)!="0"  
		local rc = _rc
		if `rc' {
			display "{err}Error: POST model cannot specify 0 post-treatment periods"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	capture assert word("`post'",1)!="1"  
		local rc = _rc
		if `rc' {
			display "{err}Error: POST model must specify at least 2 post-treatment periods"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	if "`post'"=="" {
		local post = 2
		display "{text}Warning: {inp}Number of post-treatment periods not specified; default of 2 post-periods assumed" _n
	}
}
else {
	if "`pre'"=="" {
		local pre = 1
		display "{text}Warning: {inp}Number of pre-treatment periods not specified; default of 1 pre-period assumed" _n
		}	
	if "`post'"=="" {
		local post = 1
		display "{text}Warning: {inp}Number of post-treatment periods not specified; default of 1 post-period assumed" _n
		}
	capture assert word("`pre'",1)!="0"  
		local rc = _rc
		if `rc' {
			display "{err}Error: `model' model cannot specify 0 pre-treatment periods"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	capture assert word("`post'",1)!="0"  
		local rc = _rc
		if `rc' {
			display "{err}Error: `model' model cannot specify 0 post-treatment periods"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}	
}

capture assert "`mde'"!="" 
	local rc = _rc
	if `rc' {
		display "{err}Error: Must specify minimum detectable effect(s) as numlist in option mde()"
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}

if "`alpha'"=="" {
	local alpha = 0.05
	display "{text}Warning: {inp}Option alpha() not specified; default Type-I error rate of alpha=0.05 assumed" _n
}

if "`onesided'"=="onesided" {
	display "{text}Warning: {inp}One-sided hypothesis tests toggled, with direction determined by " 
	display "         the sign of each minimum detectable effect specified in option mde()" _n
}

capture assert "`t'"!="" if "`tstart'"!="" 
	local rc = _rc
	if `rc' {
		display "{err}Error: Must specify time period variable in order to use option tstart()" 
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}
if "`tstart'"!="" {
	quietly sum `t' `if' `in'
	capture assert real(word("`tstart'",1))>=r(min) & real(word("`tstart'",1))<=r(max)
		local rc = _rc
		if `rc' {
			display "{err}Error: Option tstart() must specify time periods within range of `t' included in dataset"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	if word("`tstart'",2)!="" {
		quietly sum `t' `if' `in'
		capture assert real(word("`tstart'",2))>=r(min) & real(word("`tstart'",2))<=r(max)
			local rc = _rc
			if `rc' {
				display "{err}Error: Option tstart() must specify time periods within range `t' included in dataset"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}		
	}
}

foreach v in `controls' {
	capture confirm numeric variable `v' 
		local rc = _rc
		if `rc' {
			display "{err}Error: Control variable `v' not numeric"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	capture assert "`v'"!="`y'" 
		local rc = _rc
		if `rc' {
			display "{err}Error: Cannot use outcome variable `y' as a control"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	capture assert "`v'"!="`i'" 
		local rc = _rc
		if `rc' {
			display "{err}Error: Cannot use cross-sectional unit variable `i' as a control"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
}

foreach v in `absorb' {
	capture confirm numeric variable `v' 
		local rc = _rc
		if `rc' {
			display "{err}Error: Fixed effect variable `v' not numeric"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	capture assert "`v'"!="`y'" 
		local rc = _rc
		if `rc' {
			display "{err}Error: Cannot use outcome variable `y' as a fixed effect"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	capture assert "`v'"!="`i'" if inlist("`model'","ONESHOT","POST","ANCOVA") 
			local rc = _rc
			if `rc' {
				display "{err}Error: `model' model cannot include cross-sectional unit fixed effects"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}
	if "`v'"=="`t'" & "`model'"=="ONESHOT" {
		display "{text}Warning: {inp}In `model' model, time period fixed effect is collinear with intercept" _n
	}
	else if "`v'"=="`t'" & inlist("`model'","POST","ANCOVA") & "`collapse'"=="collapse" {
		display "{text}Warning: {inp}In collapsed `model' model, time period fixed effect is collinear with intercept" _n
		local ABSORB_w_count = wordcount("`absorb'")
		forvalues w_count = 1/`ABSORB_w_count' {
			if word("`absorb'",`w_count')=="`t'" {
				if `w_count'==1 & `ABSORB_w_count'==1 {
					local absorb = subinstr("`absorb'","`t'","",1)
				}
				else if `w_count'==1 {
					local absorb = subinstr("`absorb'","`t' ","",1)
				}
				else if `w_count'>1 & `w_count'<`ABSORB_w_count' {
					local absorb = subinstr("`absorb'"," `t' "," ",1)
				}
				else if `w_count'==`ABSORB_w_count' {
					local absorb = subinstr("`absorb'"," `t'","",1)
				}
			}
		}		
	}
}

foreach v1 in `controls' {
	foreach v2 in `absorb' {
		capture assert "`v1'"!="`v2'"
			local rc = _rc
			if `rc' {
				display "{err}Error: Variable `v1' cannot be used as both a control and a fixed effect"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}	
	}
}

if "`absorb'"=="" & "`absorbfactor'"=="" {
	if "`idcluster'"=="" {
		if inlist("`model'","ONESHOT") | (inlist("`model'","POST","ANCOVA") & "`collapse'"=="collapse") {
			capture gen ones_fOr_aBsOrB = 1
			local absorb = "ones_fOr_aBsOrB"
		}
		else if inlist("`model'","POST","ANCOVA") {
			display "{text}Warning: {inp}No fixed effects included because option absorb() not specified" _n
			capture gen ones_fOr_aBsOrB = 1
			local absorb = "ones_fOr_aBsOrB"
		}
		else if inlist("`model'","DD") & "`collapse'"=="collapse" {
			display "{text}Warning: {inp}No fixed effects included because option absorb() not specified; "
			display "         collapsed DD model defaulted to fixed effects by cross-sectional "
			display "         unit `i' and post-period dummy " _n
			local absorb = "`i'"		
		}
		else if inlist("`model'","DD") & "`collapse'"=="" {
			display "{text}Warning: {inp}No fixed effects included because option absorb() not specified; " 
			display "         DD model defaulted to fixed effects by cross-sectional unit `i' "
			display "         and time-period `t' " _n
			local absorb = "`i' `t'"		
		}
	}
	else {
		if inlist("`model'","ONESHOT") | (inlist("`model'","POST","ANCOVA") & "`collapse'"=="collapse") {
			display "{text}Warning: {inp}No fixed effects included because option absorb() not specified " _n
			capture gen ones_fOr_aBsOrB = 1
			local absorb = "ones_fOr_aBsOrB"
		}
		else if inlist("`model'","POST","ANCOVA") {
			display "{text}Warning: {inp}No fixed effects included because option absorb() not specified" _n
			capture gen ones_fOr_aBsOrB = 1
			local absorb = "ones_fOr_aBsOrB"
		}
		else if inlist("`model'","DD") & "`collapse'"=="collapse" {
			display "{text}Warning: {inp}No fixed effects included because option absorb() not specified; " 
			display "         collapsed DD model defaulted to fixed effects by cluster-randomized " 
			display "         group unit `idcluster' and post-period dummy " _n
			local absorb = "`idcluster'"		
		}
		else if inlist("`model'","DD") & "`collapse'"=="" {
			display "{text}Warning: {inp}No fixed effects included because option absorb() not specified; " _n
			display "         DD model defaulted to fixed effects by cluster-randomized  " _n
			display "         group unit `idcluster' and time-period `t' " _n
			local absorb = "`idcluster' `t'"		
		}
	}
}	

if "`absorbfactor'"!="" {
	local abs_fvars = " `absorbfactor' "
	forvalues scount = 1/10 {
		local abs_fvars = subinstr("`abs_fvars'",substr("`abs_fvars'",strpos("`abs_fvars'",".")-1,2)," ",1)
	}
	local abs_fvars = trim(itrim(subinstr(subinstr(subinstr("`abs_fvars'","#"," ",.),"("," ",.),")"," ",.)))
	foreach v in `abs_fvars' {
		capture confirm variable `v' 
			local rc = _rc
			if `rc' {
				display "{err}Error: Fixed effect variable `v' not found"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}
		capture confirm numeric variable `v' 
			local rc = _rc
			if `rc' {
				display "{err}Error: Fixed effect variable `v' not numeric"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}
	}
}

if "`idcluster'"=="" {
	if "`vce'"=="" & "`model'"=="ONESHOT" {
		local vce = "unadjusted"
		display "{text}Warning: {inp}Option vce() not specified; assumed to be UNADJUSTED in ONESHOT model" _n
	}	
	else if "`vce'"=="" & "`model'"=="POST" & "`collapse'"=="" {
		local vce = "cluster `i'"
		display "{text}Warning: {inp}Option vce() not specified; assumed to be clustered by `i' "
		display "         in POST model with 2+ periods" _n
	}	
	else if "`vce'"=="" & "`model'"=="DD" & "`collapse'"=="" {
		if "`pre'"=="1" & "`post'"=="1" {
			local vce = "unadjusted"
			display "{text}Warning: {inp}Option vce() not specified; assumed to be UNADJUSTED in "
			display "         DD model with 2 periods" _n
		}
		else {
			local vce = "cluster `i'"
			display "{text}Warning: {inp}Option vce() not specified; assumed to be clustered by `i' "
			display "         in DD model with 3+ periods" _n
		}
	}	
	else if "`vce'"=="" & "`model'"=="ANCOVA" & "`collapse'"=="" {
		if "`post'"=="1" {
			local vce = "unadjusted"
			display "{text}Warning: {inp}Option vce() not specified; assumed to be UNADJUSTED in ANCOVA model "
			display "         with 1 post-treatment period" _n
		}
		else {
			local vce = "cluster `i'"
			display "{text}Warning: {inp}Option vce() not specified; assumed to be clustered by `i' " 
			display "         in ANCOVA model with 2+ post-treatment periods" _n
		}
	}	
	else if "`vce'"=="" & "`collapse'"=="collapse" {
		local vce = "unadjusted"
		display "{text}Warning: {inp}Option vce() not specified; assumed to be UNADJUSTED in collapsed `model' model" _n
	}	
}
else {
	if "`vce'"=="" & "`model'"=="ONESHOT" {
		local vce = "cluster `idcluster'"
		display "{text}Warning: {inp}Option vce() not specified; assumed to be cluster by `idcluster'"
		display "         in cluster-randomized ONESHOT model" _n
	}	
	else if "`vce'"=="" & "`model'"=="POST" {
		local vce = "cluster `idcluster'"
		display "{text}Warning: {inp}Option vce() not specified; assumed to be clustered by `idcluster' "
		display "         in cluser-randomized POST model with 2+ periods" _n
	}	
	else if "`vce'"=="" & "`model'"=="DD" {
		local vce = "cluster `idcluster'"
		display "{text}Warning: {inp}Option vce() not specified; assumed to be clustered by `idcluster' "
		display "         in cluster-randomized DD model" _n
	}	
	else if "`vce'"=="" & "`model'"=="ANCOVA" {
		local vce = "cluster `idcluster'"
		display "{text}Warning: {inp}Option vce() not specified; assumed to be clustered by `idcluster' "
		display "         in cluster-randomized ANCOVA model" _n
	}	
}
capture assert inlist("`vce'","ols","unadjusted","robust","bootstrap","jackknife","hc2","hc3") | word("`vce'",1)=="cluster"
	local rc = _rc
	if `rc' {
		display "{err}Error: Option vce(`vce') is not a valid vcetype"
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}
if trim("`vce'")=="cluster" {
	capture assert "`i'"!=""
		local rc = _rc 
		if `rc' {
			display "{err} Error: Cluster variable not specified"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
		else {
			if "`idcluster'"=="" {
				local vce = "cluster `i'"
				display "{text}Warning: {inp}Cluster variable not specified; assumed to be `i'" _n
			}	
			else {
				local vce = "cluster `idcluster'"
				display "{text}Warning: {inp}Cluster variable not specified; assumed to be `idcluster'" _n
			}	
		}
}
capture assert inlist("`vce'","bootstrap","jackknife","hc2","hc3")==0
	local rc = _rc
	if `rc' {
		display "{err}Error: Option vce(`vce') is not supported by reghdfe"
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}
	

if word("`vce'",1)=="cluster" {	
	local cl_varlist = subinstr("`vce'","cluster ","",1)
	foreach v of varlist `cl_varlist' {
		capture confirm numeric variable `v' 
			local rc = _rc
			if `rc' {
				display "{err}Error: Cluster variable `v' not numeric"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}
		capture assert "`v'"!="`y'" 
			local rc = _rc
			if `rc' {
				display "{err}Error: Cannot cluster by outcome variable `y'"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}
	}
}

foreach v in `stratify' {
	capture confirm numeric variable `v' 
		local rc = _rc
		if `rc' {
			display "{err}Error: Stratify variable `v' not numeric"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	capture assert "`v'"!="`y'" 
		local rc = _rc
		if `rc' {
			display "{err}Error: Cannot stratify by variable `y'"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	local strat_fe_cl	= "no"
	foreach v_c in `absorb' `cl_varlist' {
		if "`v'"=="`v_c'" {
			local strat_fe_cl = "yes"
		}
	}
	if "`strat_fe_cl'"=="no" {
		display "{text}Warning: {inp}To include `v' as a fixed effect in the regression, " 
		display "         it must also be specified using option absorb() or absorbfactor(). " _n
		display "{text}Warning: {inp}Note that for correct inference with stratified randomization, " 
		display "         the specification must either cluster by the stratification variable(s) " 
		display "         or include these variables as fixed effects " _n
	}
}
if "`stratify'"!="" {
	display "{text}Warning: {inp}Option stratify() specified; sample size option n() governs "
	display "         the number units included in EACH randomization cell" _n
}

capture assert (("`stratify'"!="") + ("`idcluster'"!=""_))<2
	local rc = _rc
	if `rc' {
		display "{err}Error: Program does not simultaneously support stratified randomization"
		display "{err}       and cluster randomization "
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}

if "`n'"=="" {
	if "`stratify'"=="" & "`idcluster'"=="" {
		if "`i'"!="" {
			capture unique `i' `if' `in'
				local rc = _rc
				if `rc' {
					display "{err}Error: Please ssc install unique, or specify option n()"
					use "`m_dta_before_sims'", clear	
					exit `rc'
				}
			local n = min(r(sum),r(unique))
			display "{text}Warning: {inp}Option n() not specified; sample size defaulted to `n' " 
			display "         (the number of `i' units in the dataset)" _n
		}
		else {
			quietly count `if' `in'
			local n = r(N)
			display "{text}Warning: {inp}Option n() not specified; sample size defaulted to `n' (the number " 
			display "         of observations in the dataset, which is the default unit of randomization)" _n
		}	
	}
	else if "`stratify'"!="" & "`idcluster'"=="" {	
		quietly egen tEMp_grpSTRAT = group(`stratify')
		quietly sum tEMp_grpSTRAT
		local tEMp_grpSTRAT_MAX = r(max)
		local obs_STRAT_min = _N
		if "`i'"!="" {
			forvalues tEMp_id = 1/`tEMp_grpSTRAT_MAX' {
				preserve
					quietly keep if tEMp_grpSTRAT==`tEMp_id'
					capture unique `i' `if' `in'
						local rc = _rc
						if `rc' {
							display "{err}Error: Please ssc install unique, or specify option n()"
							use "`m_dta_before_sims'", clear	
							exit `rc'
						}
					local obs_STRAT_min = min(`obs_STRAT_min',r(sum),r(unique))
				restore
			}
			local n = `obs_STRAT_min'
			display "{text}Warning: {inp}Option n() not specified; sample size defaulted to `n' " 
			display "         (the number of `i' units in the smallest randomzation cell)" _n
		}
		else {
			forvalues tEMp_id = 1/`tEMp_grpSTRAT_MAX' {
				preserve
					quietly keep if tEMp_grpSTRAT==`tEMp_id'
					quietly count `if' `in'
					local obs_STRAT_min = min(`obs_STRAT_min',r(N))
				restore
			}
			local n = `obs_STRAT_min'
			display "{text}Warning: {inp}Option n() not specified; sample size defaulted to `n' " 
			display "         (the number of observations in the smallest randomzation cell)" _n		
		}
		quietly drop tEMp_grpSTRAT
	}
}

foreach nLOOP in  `n' {	
	foreach pLOOP in `p' {
		local nLOOP_T = round(`nLOOP'*`pLOOP')
		capture assert `nLOOP_T'>0 & `nLOOP_T'<`nLOOP' 
			local rc = _rc
			if `rc' {
				display "{err}Error: Randomizing proportion p=`pLOOP' of n=`nLOOP' units results in "
				display "{err}       `nLOOP_T' out of `nLOOP' treated units; please increase n() "
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}
	}
}	
	
capture assert "`model'"!="ONESHOT" if "`collapse'"=="collapse"
	local rc = _rc
	if `rc' {
		display "{err}Error: ONESHOT model cannot be collapsed"
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}
capture assert "`collapse'"=="" if "`t'"==""
	local rc = _rc
	if `rc' {
		display "{err}Error: Time period variable must be specified to use collapse option"
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}
if inlist("`model'","POST","ANCOVA") & "`collapse'"=="collapse" {
	foreach v in `control' {
		if "`v'"=="`t'" {
				display "{text}Warning: {inp}In collapsed `model' model, time-period control is collinear with intercept"
				use "`m_dta_before_sims'", clear	
				exit `rc'
		}
	}
}	
else if inlist("`model'","DD") & "`collapse'"=="collapse" {
	local ABSORB_w_count = wordcount("`absorb'")
	forvalues w_count = 1/`ABSORB_w_count' {
		if word("`absorb'",`w_count')=="`t'" {
			if `w_count'==1 & `ABSORB_w_count'==1 {
				local absorb = subinstr("`absorb'","`t'","",1)
			}
			else if `w_count'==1 {
				local absorb = subinstr("`absorb'","`t' ","",1)
			}
			else if `w_count'>1 & `w_count'<`ABSORB_w_count' {
				local absorb = subinstr("`absorb'"," `t' "," ",1)
			}
			else if `w_count'==`ABSORB_w_count' {
				local absorb = subinstr("`absorb'"," `t'","",1)
			}
			display "{text}Warning: {inp}Collapsed `model' model cannot include time-period fixed effects; " 
			display "         collapsed specification will include a post-period fixed effect instead " _n
		}
	}
	foreach v in `control' {
		capture assert "`v'"!="`t'"
			local rc = _rc
			if `rc' {
				display "{err}Error: Collapsed `model' model cannot control for time-period"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}
	}
}	

if "`nsim'"=="" {
	local nsim = 500
	display "{text}Warning: {inp}Option nsim() not specified; number of simulations " 
	display "         defaulted to `nsim' for each set of parameter values" _n
}

capture assert substr("`weight'",1,2)!="iw"
	local rc = _rc
	if `rc' {
		display "{err}Error: Reghdfe does not allow iweight"
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}
capture assert regexm("`weight'","=") if "`weight'"!=""
	local rc = _rc
	if `rc' {
		display "{err}Error: Please use correct weight syntax (i.e. aw=weightvar)"
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}
if "`weight'"!="" {	
	local wtvar = substr("`weight'",strpos("`weight'","=")+1,length("`weight'"))
	capture confirm numeric variable `wtvar' 
		local rc = _rc
		if `rc' {
			display "{err}Error: Weight variable `wtvar' not numeric"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	capture assert "`wtvar'"!="`y'" 
		local rc = _rc
		if `rc' {
			display "{err}Error: Cannot weight by outcome variable `y'"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	capture assert "`wtvar'"!="`i'" & "`i'"!=""
		local rc = _rc
		if `rc' {
			display "{err}Error: Cannot weight by unit of randomization `i'"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}

}	
capture assert (regexm("`reghdfeoptions'","a[(]") + regexm("`reghdfeoptions'","ab[(]") + regexm("`reghdfeoptions'","abs[(]") + regexm("`reghdfeoptions'","absorb[(]"))==0
	local rc = _rc
	if `rc' {
		display "{err}Error: Reghdfe option absorb() redundant, please specify separately as "
		display "{err}       either option absorb() or option absorbfactor() "
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}
capture assert regexm("`reghdfeoptions'","vce[(]")==0
	local rc = _rc
	if `rc' {
		display "{err}Error: Reghdfe option vce() redundant, please specify separately as the option vce()"
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}	
	
if "`outfile'"=="" {
	if "`master_fname'"!="" {
		local outfile = subinstr("`master_fname'",".dta","",1) + "_power.csv"
		display "{text}Warning: {inp}Option outfile() not specified; program will outsheet results "
		display "         in the current directory, in the file `outfile' " _n
	}
	else {
		local outfile = "`c(pwd)'`c(dirsep)'pc_simulations_power.csv"
		display "{text}Warning: {inp}Option outfile() not specified; program will outsheet results in: "
		display "         `outfile' " _n
	}	
}
if regexm("`outfile'",".dta") {
	local outfile = subinstr("`outfile'",".dta",".csv",1)
	display "{text}Warning: {inp}Option outfile() changed to csv format: `outfile' " _n
}
else if regexm("`outfile'",".xlsx") {
	local outfile = subinstr("`outfile'",".xlsx",".csv",1)
	display "{text}Warning: {inp}Option outfile() changed to csv format: `outfile' " _n
}
else if regexm("`outfile'",".xls") {
	local outfile = subinstr("`outfile'",".xls",".csv",1)
	display "{text}Warning: {inp}Option outfile() changed to csv format: `outfile' " _n
}
else if regexm("`outfile'",".raw") {
	local outfile = subinstr("`outfile'",".raw",".csv",1)
	display "{text}Warning: {inp}Option outfile() changed to csv format: `outfile' " _n
}
else if regexm("`outfile'",".txt") {
	local outfile = subinstr("`outfile'",".txt",".csv",1)	
	display "{text}Warning: {inp}Option outfile() changed to csv format: `outfile' " _n
}
else if regexm(substr("`outfile'",-5,5),"[.]")==0 {
	local outfile = "`outfile'" + ".csv"
	display "{text}Warning: {inp}Option outfile() changed to csv format: `outfile' " _n
}	
capture assert substr("`outfile'",-4,4)==".csv"
	local rc = _rc
	if `rc' {
		display "{err}Error: Option outfile() must be in .csv format"
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}
	
capture confirm new file `outfile'	
	local rc = _rc
	if `rc' & "`replace'"=="" & "`append'"=="" { // if the file exists, you must have either append or replace
		display "{err}Error: Option append/replace not specified, cannot overwrite existing file `outfile' "
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}
	if `rc' & "`replace'"!="" & "`append'"!="" { // if the file exists, append supersedes replace
		local replace = ""
	}
	
capture confirm file `outfile'	// if the file doesn't exist, turn off append and replace options
	local rc = _rc
	if `rc' & "`append'"=="append" {
		local append = ""
		*display "{err}Error: Option append not allowed, as file `outfile' does not exist."
		*use "`m_dta_before_sims'", clear	
		*exit `rc'
	}
	if `rc' & "`replace'"=="replace" {
		local replace = ""
		*display "{err}Error: Option append not allowed, as file `outfile' does not exist."
		*use "`m_dta_before_sims'", clear	
		*exit `rc'
	}

capture ms_get_version reghdfe, min_version("5.0.0")
	local rc = _rc
	if `rc' {
		display "{err}Error: Please run \`ssc install reghdfe, replace' and \`ssc install ftools, replace' "
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}


if "`idcluster'"=="" {
	capture assert "`sizecluster'"=="" 
		local rc = _rc
		if `rc' {
			display "{err}Error: Cannot specify cluster randomization option sizecluster()"
			display "         without specify group identifier with idcluster()"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	capture assert "`pcluster'"=="" 
		local rc = _rc
		if `rc' {
			display "{err}Error: Cannot specify cluster randomization option pcluster()"
			display "         without specify group identifier with idcluster()"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
} 		
		
if "`idcluster'"!="" {
	capture confirm numeric variable `idcluster' 
		local rc = _rc
		if `rc' {
			display "{err}Error: Group identifier for cluster randomization must be numeric"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	capture assert "`idcluster'"!="`y'"
		local rc = _rc
		if `rc' {
			display "{err}Error: Group identifier for cluster randomization cannot be the same"
			display "         as dependent variable"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	capture assert "`idcluster'"!="`i'"
		local rc = _rc
		if `rc' {
			display "{err}Error: Group identifier for cluster randomization cannot be the same"
			display "         as cross-sectional unit"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	capture assert "`idcluster'"!="`t'"
		local rc = _rc
		if `rc' {
			display "{err}Error: Group identifier for cluster randomization cannot be the same"
			display "         as time-series unit"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	foreach v1 in `controls' {
		capture assert "`v1'"!="`idcluster'"
			local rc = _rc
			if `rc' {
				display "{err}Error: Variable `v1' cannot be used as both a control and as"
				display "         group identifier for cluster randomization"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}	
	}

	display "{text}Warning: {inp}Option idcluster() specified; sample size option n() governs "
	display "         the number of randomized clusters, while option sizecluster() governs "
	display "         the number of `i' units within each cluster " _n

	
	if "`n'"=="" {
		capture unique `idcluster' `if' `in'
			local rc = _rc
			if `rc' {
				display "{err}Error: Please ssc install unique, or specify option n()"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}
		local n = min(r(sum),r(unique))
		display "{text}Warning: {inp}Option n() not specified; sample size defaulted to `n' " 
		display "         (the number of `idcluster' clusters in the dataset)" _n
	}
	
	if "`i'"!="" {
		quietly egen tEMp_grpCLUST_MIN = min(`idcluster'), by(`i')
		quietly egen tEMp_grpCLUST_MAX = max(`idcluster'), by(`i')
		capture assert tEMp_grpCLUST_MIN==tEMp_grpCLUST_MAX 
			local rc = _rc
			if `rc' {
				display "{err}Error: Cross-sectional unit `i' must fully nest within group identifier"
				display "         `idcluster' used for cluster randomization"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}
		quietly drop tEMp_grpCLUST_MIN tEMp_grpCLUST_MAX

		if "`sizecluster'"=="" {
			display "{text}Warning: {inp}Option sizecluster() not specified. Simulations will default" 
			display "         to the size of each `idcluster' in the existing dataset. Different "
			display "         clusters may contain different numbers of `i' units. " _n
		}
		else {
			local sizecluster_max = 0
			quietly levelsof `idcluster', local(levs)
			foreach grpCLUST_LOOP in `levs' {
				quietly unique `i' if `idcluster'==`grpCLUST_LOOP'
				local sizecluster_max = max(min(r(sum),r(unique)),`sizecluster_max')
			}
			if `sizecluster_max'<`sizecluster' {
				display "{text}Warning: {inp}Option sizecluster() specifies clusters larger" 
				display "         than the largest `idcluster' cluster in the dataset. " _n
			}
		}
	}
	else {
		if "`sizecluster'"=="" {
			display "{text}Warning: {inp}Option sizecluster() not specified. Simulations will default" 
			display "         to the number of observations in each `idcluster' in the existing dataset. "
			display "         Different clusters may contain different numbers of units. " _n
		}
		else {
			local sizecluster_max = 0
			quietly levelsof `idcluster', local(levs)
			foreach grpCLUST_LOOP in `levs' {
				quietly count if `idcluster'==`grpCLUST_LOOP'
				local sizecluster_max = max(r(N),`sizecluster_max')
			}
			if `sizecluster_max'>`sizecluster' {
				display "{text}Warning: {inp}Option sizecluster() specifies clusters larger" 
				display "         than the largest `idcluster' cluster in the dataset. " _n
			}
		}	
	}
	
	if "`pcluster'"=="" {
		local pcluster = 1
		display "{text}Warning: {inp}Option pcluster() not specified; defaulted to 1. " 
		display "         Option p() sets the proportion of `idcluster' clusters randomized into treatment." 	
		display "         Within each treated cluster, the treatment intensity will be 1." _n		
	}
	else if "`pcluster'"!="" & wordcount("`pcluster'")==1 {
		display "{text}Warning: {inp}Option p() sets the proportion of `idcluster' clusters randomized into treatment." 	
		display "         The treatment intensity will be `pcluster' for all treated clusters." _n		
	}
	else if "`pcluster'"!="" & wordcount("`pcluster'")>1 {
		local pcluster_wordcount = wordcount("`pcluster'")
		display "{text}Warning: {inp}Option p() sets the proportion of `idcluster' clusters randomized into treatment." 	
		display "         Treated clusters will have heterogeneous treatment intensities of {`pcluster'},"
		display "         with equal proportions randomized into each intensity." _n		
	}
	
}	

}

	
// 4. Prep dataset
{	
if "`i'"=="" & "`model'"=="ONESHOT" {
	capture gen i_fOr_OneshOt = _n
	local i = "i_fOr_OneshOt"
}	
if "`t'"=="" & "`model'"=="ONESHOT" {
	capture gen t_fOr_OneshOt = 0
	local t = "t_fOr_OneshOt"
}	
assert "`i'"!="" & "`t'"!=""

capture keep `if'
		local rc = _rc
		if `rc' & "`if'"!="" {
			display "{err}Error: Option [if] not valid " _n
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
capture keep `in'
		local rc = _rc
		if `rc' & "`in'"!="" {
			display "{err}Error: Option [in] not valid " _n
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
		
quietly keep `y' `i' `t' `stratify' `controls' `absorb' `abs_fvars' `cl_varlist' `wtvar' `idcluster'
quietly count if mi(`y') | mi(`i') | mi(`t')
if r(N)>0 {
	display "{text}Warning: {inp}`r(N)' observations were dropped due to missing data, "
	display "         power calculation observation counts assume non-missing data. " _n
}
quietly drop if mi(`y') | mi(`i') | mi(`t')

capture assert _N>0
	local rc = _rc
	if `rc' {
		display "{err}Error: No nonmissing observations remain to conduct simulations "
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}	


capture unique `i' `t'
	local rc = _rc
	if `rc' {
		display "{err}Error: Please ssc install unique, or specify option n()"
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}


quietly unique `i' `t'
capture assert (r(sum)==r(N)) | (r(unique)==r(N))
	local rc = _rc
	if `rc' & "`i'"!="i_fOr_OneshOt" & "`t'"!="t_fOr_OneshOt" {
		display "{err}Error: Simulation dataset must be unique by `i' and `t' "
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}	
	else if `rc' & "`i'"=="i_fOr_OneshOt" & "`t'"!="t_fOr_OneshOt" {
		display "{err}Error: Simulation dataset cannot have multiple observations per time period"
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}	
	else if `rc' & "`i'"!="i_fOr_OneshOt" & "`t'"=="t_fOr_OneshOt" {
		display "{err}Error: Simulation dataset must be unique by `i' "
		use "`m_dta_before_sims'", clear	
		exit `rc'
	}	

local nMAX = real(word("`n'",wordcount("`n'")))
if "`bootstrap'"=="" {
	if "`stratify'"=="" & "`idcluster'"=="" {	
		quietly unique `i'
		capture assert `nMAX'<=r(sum) & `nMAX'<=r(unique)
			local rc = _rc
			if `rc' & "`i'"!="i_fOr_OneshOt" {
				display "{err}Error: Sample size too small to simulate experiment with `nMAX' unique `i' units" _n
				display "{err}Specify option bootstrap to sample units with replacement from existing dataset"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}
			else if `rc' & "`i'"=="i_fOr_OneshOt" {
				display "{err}Error: Sample size too small to simulate experiment with `nMAX' unique observations" _n
				display "{err}Specify option bootstrap to sample observations with replacement from existing dataset"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}	
	}
	else if "`stratify'"!="" {
		quietly egen tEMp_grpSTRAT = group(`stratify')
		quietly sum tEMp_grpSTRAT
		local levelsSTRAT = r(max)
		forvalues stratLOOP = 1/`levelsSTRAT' {
			quietly unique `i' if tEMp_grpSTRAT==`stratLOOP'
			capture assert `nMAX'<=r(sum) & `nMAX'<=r(unique)
				local rc = _rc
				if `rc' & "`i'"!="i_fOr_OneshOt" {
					display "{err}Error: Sample size too small to simulate experiment with `nMAX' unique `i' units"
					display "{err}       in each stratified randomizaton cell. " _n
					display "{err}Specify option bootstrap to sample units with replacement from "
					display "{err}existing dataset, for each stratified cell. "
					use "`m_dta_before_sims'", clear	
					exit `rc'
				}
				else if `rc' & "`i'"=="i_fOr_OneshOt" {
					display "{err}Error: Sample size too small to simulate experiment with `nMAX' unique observations"
					display "{err}       in each stratified randomizaton cell. " _n
					display "{err}Specify option bootstrap to sample observations with replacement from "
					display "{err}existing dataset, for each stratified cell. "
					use "`m_dta_before_sims'", clear	
					exit `rc'
				}	
		}
	}	
	else if "`idcluster'"!="" {
		quietly unique `idcluster' 
		capture assert `nMAX'<=r(sum) & `nMAX'<=r(unique)
			local rc = _rc
			if `rc' {
				display "{err}Error: Sample size too small to simulate experiment with `nMAX' unique `idcluster' clusters" _n
				display "{err}Specify option bootstrap to sample clusters with replacement from existing dataset"
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}		
		
		if "`sizecluster'"!="" {
			quietly gen tEMp_i_per_cluster = 0
			quietly levelsof `idcluster', local(levs)
			foreach grpCLUST_LOOP in `levs' {
				quietly unique `i' if `idcluster'==`grpCLUST_LOOP'
				local sizecluster_TEMp = min(r(sum),r(unique))
				quietly replace tEMp_i_per_cluster = `sizecluster_TEMp' if `idcluster'==`grpCLUST_LOOP'
			}
			quietly unique `idcluster' if tEMp_i_per_cluster>=`sizecluster'
			capture assert `nMAX'<=r(sum) & `nMAX'<=r(unique)
				local rc = _rc
				if `rc' & "`i'"!="i_fOr_OneshOt" {
					display "{err}Error: Sample size too small to simulate experiment with `nMAX' unique "
					display "{err}       randomized `idcluster' clusters of size `sizecluster'. " _n
					display "{err}Specify option bootstrap to sample `i' units with replacement from "
					display "{err}within each cluster. "
					use "`m_dta_before_sims'", clear	
					exit `rc'
				}
				else if `rc' & "`i'"=="i_fOr_OneshOt" {
					display "{err}Error: Sample size too small to simulate experiment with `nMAX' unique "
					display "{err}       randomized `idcluster' clusters of size `sizecluster'. " _n
					display "{err}Specify option bootstrap to sample `i' units with replacement from "
					display "{err}within each cluster. "
					use "`m_dta_before_sims'", clear	
					exit `rc'
				}	
		}
	}	
}
else {
	if "`stratify'"!="" {	
		quietly egen tEMp_grpSTRAT = group(`stratify')		
	}
}

if inlist("`model'","POST","DD","ANCOVA") {
	quietly sum `t'
	local t_min_TEST = r(min)
	local t_max_TEST = r(max)
	forvalues tLOOP_TEST = `t_min_TEST'/`t_max_TEST' {
		quietly count if `t'==`tLOOP_TEST'
		capture assert r(N)!=0
			local rc = _rc
			if `rc' {
				display "{err}Error: Program does not support non-consecutive time periods. Please (re)index time period"
				display "         unit `t' to consecutive integer values, with no always-missing time periods."
				use "`m_dta_before_sims'", clear	
				exit `rc'
			}
	}
}

if inlist("`model'","POST","DD","ANCOVA") {
	quietly egen temP_mIN = min(`t'), by(`i')	
	quietly egen temP_mAX = max(`t'), by(`i')
	quietly unique `i'
	local n_i_all_check = r(unique)
	quietly unique `i' if temP_mIN<temP_mAX
	local n_i_multi_t = r(unique)
	capture assert `n_i_multi_t'>0 & `n_i_multi_t'!=.
		local rc = _rc
		if `rc' {
			display "{err}Error: Dataset not compatible with `model' model, since no cross-sectional units"
			display "         (`i') have observations from multiple time periods."
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
		else if `n_i_multi_t'/`n_i_all_check'<0.5 {
			local n_i_single_t = `n_i_all_check' - `n_i_multi_t' 
			display "{text}Warning: `n_i_single_t' out of `n_i_all_check' cross-sectional units (`i')"
			display "         don't have observations from multiple time periods. These units"
			display "         will be dropped from all simulations, since the `model' model requires"
			display "         multiple time periods `t' for each unit `i'."
		}
	drop temP_mIN temP_mAX
}
	
if inlist("`model'","POST")  {
	local postMAX = real(word("`post'",wordcount("`post'")))
	if "`tstart'"!="" {
		quietly gen tEMp_enoughT = 0
		quietly replace tEMp_enoughT = 1 if `t'>=real(word("`tstart'",1)) & `t'<=real(word("`tstart'",2))+`postMAX'-1
	}
	else {
		quietly gen tEMp_enoughT = 1
	}
	quietly unique `t' if tEMp_enoughT==1
	capture assert `postMAX'<=r(sum) & `postMAX'<=r(unique)
		local rc = _rc
		if `rc' & "`tstart'"!="" {
			display "{err}Error: Dataset contains too few time periods to simulate experiment with "
			display "{err}       `postMAX' post-treatment periods (given tstart() option) " _n
			*display "{err}Use program ?????? HELP ????? to create dataset with sufficient number of units, "
			*display "{err}by drawing additional `i' units with replacement from existing dataset"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
		else if `rc' & "`tstart'"=="" {
			display "{err}Error: Dataset contains too few time periods to simulate experiment with "
			display "{err}       `postMAX' post-treatment periods " _n
			*display "{err}Use program ?????? HELP ????? to create dataset with sufficient number of units, "
			*display "{err}by drawing additional `i' units with replacement from existing dataset"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	quietly drop tEMp_enoughT
}
else if inlist("`model'","DD","ANCOVA")  {
	local preMAX = real(word("`pre'",wordcount("`pre'")))
	local postMAX = real(word("`post'",wordcount("`post'")))	
	if "`tstart'"!="" {
		quietly gen tEMp_enoughT = 0
		quietly replace tEMp_enoughT = 1 if `t'>=real(word("`tstart'",1)) & `t'<=real(word("`tstart'",2))+`preMAX'+`postMAX'-1
	}
	else {
		quietly gen tEMp_enoughT = 1
	}
	quietly unique `t' if tEMp_enoughT==1
	capture assert (`preMAX'+`postMAX'<=r(sum)) & (`preMAX'+`postMAX'<=r(unique))
		local rc = _rc
		if `rc' & "`tstart'"!="" {
			display "{err}Error: Dataset contains too few time periods to simulate experiment with "
			display "{err}       `preMAX' pre-treatment and `postMAX' post-treatment periods " 
			display "{err}       (given tstart() option) " _n
			*display "{err}Use program ?????? HELP ????? to create dataset with sufficient number of units, "
			*display "{err}by drawing additional `i' units with replacement from existing dataset"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
		else if `rc' & "`tstart'"=="" {
			display "{err}Error: Dataset contains too few time periods to simulate experiment with "
			display "{err}       `preMAX' pre-treatment and `postMAX' post-treatment periods " _n
			*display "{err}Use program ?????? HELP ????? to create dataset with sufficient number of units, "
			*display "{err}by drawing additional `i' units with replacement from existing dataset"
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
	quietly drop tEMp_enoughT
}

*di _n


	
}
				
// 5A. model == ONESHOT
if "`model'"=="ONESHOT" {
	quietly {
		
		* create locals for spacing of intermediate output
		foreach len_MAX in n p mde {
			local len_MAX_`len_MAX' = 1
			foreach len_MAX_loop in ``len_MAX''{
				local len_MAX_`len_MAX' = max(`len_MAX_`len_MAX'',length("`len_MAX_loop'"))
			}
		}
		
		* restrict time periods if option tstart() is toggled
		if "`tstart'"!="" {
			capture keep if `t'>=real(word("`tstart'",1))
			capture keep if `t'<=real(word("`tstart'",2))
		}

		* create enough observations to store all simulation results
		local newN = max(_N,`nsim')
		set obs `newN'

		* create variables to index simulations and store a rejection dummy
		gen SIMid = _n
		replace SIMid = . if SIMid>`nsim'
		gen SIMreject = .
		
		* create empty variables to store results
		gen double nOuT = .
		gen double pOuT = .
		gen double mdeOuT = .
		gen double powerOuT = .
		local indexOuT = 1

		* create temp file to store results
		tempfile m_dta_during_sims
		quietly save `m_dta_during_sims', replace
		
		* loop over `n', `p', and `mde', `nsim' times each
		foreach nLOOP in  `n' {	
			foreach pLOOP in `p' {
				local nLOOP_T = round(`nLOOP'*`pLOOP')
				foreach mdeLOOP in `mde' {
					forvalues nsimLOOP = 1/`nsim' {

						use `m_dta_during_sims', clear

						* randomly pick time period for ONESHOT RCT
						gen tEMp_rAndom1 = runiform() if `t'!=.
						sort tEMp_rAndom1
						keep if `t'==`t'[1]
					
						* if drawing units WITHOUT replacement (option bootstrap is not specified)
						if "`bootstrap'"=="" {
							* confirm that randomly selected time period has enough observations
							if "`stratify'"!="" & "`idcluster'"=="" {
								capture bysort tEMp_grpSTRAT: assert `nLOOP'<=_N
									local rc = _rc
									if `rc' {
										local t_in_lOOp = `t'[1]
										noisily display "{err}Error: Time period `t'=`t_in_lOOp' does not include enough `i' units "
										noisily display "{err}       to randomize across `nLOOP' units in each stratified randomization cell "
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}								
							}
							else if "`stratify'"=="" & "`idcluster'"=="" {
								capture assert `nLOOP'<=_N
									local rc = _rc
									if `rc' {
										local t_in_lOOp = `t'[1]
										noisily display "{err}Error: Time period `t'=`t_in_lOOp' does not include enough"
										noisily display "{err}       `i' units to randomize across `nLOOP' units "
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}								
							}
							else if "`stratify'"=="" & "`idcluster'"!="" {
								unique `idcluster'
								capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
									local rc = _rc
									if `rc' {
										local t_in_lOOp = `t'[1]
										noisily display "{err}Error: Time period `t'=`t_in_lOOp' does not include enough"
										noisily display "{err}       `idcluster' clusters to randomize across `nLOOP' clusters "
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}								
							}
												
							* randomly pick `nLOOP' units and assign treatment to `nLOOP_T' of them
							if "`stratify'"!="" & "`idcluster'"=="" {
								gen tEMp_rAndom2 = runiform()+tEMp_grpSTRAT
								by tEMp_grpSTRAT (tEMp_rAndom2), sort : gen tEMp_tREAt = 0 if _n<=`nLOOP'
								by tEMp_grpSTRAT (tEMp_rAndom2), sort : replace tEMp_tREAt = 1 if _n<=`nLOOP_T'
							}
							else if "`stratify'"=="" & "`idcluster'"=="" {
								gen tEMp_rAndom2 = runiform()
								sort tEMp_rAndom2
								gen tEMp_tREAt = 0 if _n<=`nLOOP'
								replace tEMp_tREAt = 1 if _n<=`nLOOP_T'
							}
							else if "`stratify'"=="" & "`idcluster'"!="" {
								
								* assign treatment at the cluster level
								egen tEMp_tag_CLUSTER = tag(`idcluster')
								gen tEMp_rAndom2 = runiform()
								gsort -tEMp_tag_CLUSTER tEMp_rAndom2
								gen tEMp_CLtREAt_temp = 0 if _n<=`nLOOP' & tEMp_tag_CLUSTER==1
								replace tEMp_CLtREAt_temp = 1 if _n<=`nLOOP_T' & tEMp_tag_CLUSTER==1
								egen tEMp_CLtREAt = mean(tEMp_CLtREAt_temp), by(`idcluster')
								keep if tEMp_CLtREAt!=.
							
								* assign cluster-specific treatment intensities
								egen tEMp_CLtREAt_P_temp1 = fill(`pcluster' `pcluster')
								replace tEMp_CLtREAt_P_temp1 = . if tEMp_tag_CLUSTER!=1
								egen tEMp_CLtREAt_P_temp2 = mean(tEMp_CLtREAt_P_temp1), by(`idcluster')
								gen tEMp_CLtREAt_P = tEMp_CLtREAt*tEMp_CLtREAt_P_temp2
								assert tEMp_CLtREAt_P==0 if tEMp_CLtREAt==0
								assert tEMp_CLtREAt_P>0 & tEMp_CLtREAt_P<=1 if tEMp_CLtREAt==1
							
								* set number of units in each cluster, confirm sufficient size
								if "`sizecluster'"!="" {
									levelsof `idcluster', local(levs)
									foreach grpCLUST_LOOP in `levs' {
										unique `i' if `idcluster'==`grpCLUST_LOOP'
										capture assert `sizecluster'<=r(sum) & `sizecluster'<=r(unique)
											local rc = _rc
											if `rc' {
												noisily display "{err}Error: Cluster `idcluster'=`grpCLUST_LOOP' does not include"
												noisily display "{err}       `sizecluster' units; use option bootstrap "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
									}
									gen tEMp_rAndom3 = runiform()
									by `idcluster' (tEMp_rAndom3), sort : gen tEMp_todrop = _n>`sizecluster'
									drop if tEMp_todrop==1
								}
								
								* randomize at the unit level, within clusters
								gen tEMp_rAndom4 = runiform()
								by `idcluster' (tEMp_rAndom4), sort : gen tEMp_uNIT_rank = _n
								egen tEMp_uNIT_rank_MAX = max(tEMp_uNIT_rank), by(`idcluster')
								gen tEMp_uNIT_rank_MAXT = tEMp_uNIT_rank_MAX*tEMp_CLtREAt_P
								gen tEMp_tREAt = tEMp_uNIT_rank<=round(tEMp_uNIT_rank_MAXT)
							}
							
							keep if tEMp_tREAt!=.
							assert tEMp_tREAt==0 | tEMp_tREAt==1
						}
						
						* if drawing units WITH replacement (option bootstrap is specified)
						if "`bootstrap'"!="" {
							if "`stratify'"!="" & "`idcluster'"=="" {

								* sample `nLOOP' units with replacement
								sum tEMp_grpSTRAT
								local levelsSTRAT = r(max)
								local expand_numb = 1
								forvalues stratLOOP = 1/`levelsSTRAT' {
									quietly unique `i' if tEMp_grpSTRAT==`stratLOOP'
									local expand_numb = max(`expand_numb',ceil(`nLOOP'/r(sum)),ceil(`nLOOP'/r(unique)))
								}
								expand `expand_numb'
								bsample `nLOOP', strata(tEMp_grpSTRAT)

								* randomly pick `nLOOP' units and assign treatment to `nLOOP_T' of them
								gen tEMp_rAndom2 = runiform()+tEMp_grpSTRAT
								sort tEMp_rAndom2
								by tEMp_grpSTRAT, sort : gen tEMp_tREAt = 0 if _n<=`nLOOP'
								by tEMp_grpSTRAT, sort : replace tEMp_tREAt = 1 if _n<=`nLOOP_T'
							}
							else if "`stratify'"=="" & "`idcluster'"=="" {

								* sample `nLOOP' units with replacement
								local expand_numb = ceil(`nLOOP'/_N)
								expand `expand_numb'
								bsample `nLOOP'

								* randomly pick `nLOOP' units and assign treatment to `nLOOP_T' of them
								gen tEMp_rAndom2 = runiform()
								sort tEMp_rAndom2
								gen tEMp_tREAt = 0 if _n<=`nLOOP'
								replace tEMp_tREAt = 1 if _n<=`nLOOP_T'
							}
							else if "`stratify'"=="" & "`idcluster'"!="" {

								* sample `nLOOP' clusters with replacement
								preserve
								keep `idcluster'
								duplicates drop
								local expand_numb = ceil(`nLOOP'/_N)
								expand `expand_numb'
								bsample `nLOOP'
								gen clID_bsample = _n
								tempfile bsample_output_clusters
								save "`bsample_output_clusters'"
								restore
								joinby `idcluster' using "`bsample_output_clusters'"
								drop `idcluster'
								rename clID_bsample `idcluster'
								
								* assign treatment at the cluster level
								egen tEMp_tag_CLUSTER = tag(`idcluster')
								gen tEMp_rAndom2 = runiform()
								gsort -tEMp_tag_CLUSTER tEMp_rAndom2
								gen tEMp_CLtREAt_temp = 0 if _n<=`nLOOP' & tEMp_tag_CLUSTER==1
								replace tEMp_CLtREAt_temp = 1 if _n<=`nLOOP_T' & tEMp_tag_CLUSTER==1
								egen tEMp_CLtREAt = mean(tEMp_CLtREAt_temp), by(`idcluster')
								keep if tEMp_CLtREAt!=.

								* assign cluster-specific treatment intensities
								egen tEMp_CLtREAt_P_temp1 = fill(`pcluster' `pcluster')
								replace tEMp_CLtREAt_P_temp1 = . if tEMp_tag_CLUSTER!=1
								egen tEMp_CLtREAt_P_temp2 = mean(tEMp_CLtREAt_P_temp1), by(`idcluster')
								gen tEMp_CLtREAt_P = tEMp_CLtREAt*tEMp_CLtREAt_P_temp2
								assert tEMp_CLtREAt_P==0 if tEMp_CLtREAt==0
								assert tEMp_CLtREAt_P>0 & tEMp_CLtREAt_P<=1 if tEMp_CLtREAt==1

								* sample `sizecluster' units with replacement, within each cluster
								if "`sizecluster'"!="" {
									by `idcluster', sort : gen tEMp_cl_size_preBS = _N
									gen tEMp_expand_numb = ceil(`sizecluster'/tEMp_cl_size_preBS)
									expand tEMp_expand_numb
									bsample `sizecluster', strata(`idcluster')
									by `idcluster', sort : gen tEMp_cl_size_postBS = _N
									assert tEMp_cl_size_postBS==`sizecluster'									
								}
								
								* randomize at the unit level, within clusters
								gen tEMp_rAndom3 = runiform()
								by `idcluster' (tEMp_rAndom3), sort : gen tEMp_uNIT_rank = _n
								egen tEMp_uNIT_rank_MAX = max(tEMp_uNIT_rank), by(`idcluster')
								gen tEMp_uNIT_rank_MAXT = tEMp_uNIT_rank_MAX*tEMp_CLtREAt_P
								gen tEMp_tREAt = tEMp_uNIT_rank<=round(tEMp_uNIT_rank_MAXT)
								
							}
							capture assert tEMp_tREAt!=.
								local rc = _rc
								if `rc' {
									noisily display "{err}Error: Option bootstrap causing bsample to break for some reason... "
									use "`m_dta_before_sims'", clear	
									exit `rc'
								}								
							assert tEMp_tREAt==0 | tEMp_tREAt==1
						}
						
						* add treatment effects of `mdeLOOP' for treated units only
						replace `y' = `y' + `mdeLOOP' if tEMp_tREAt==1

						* estimate regression
						if "`weight'"=="" {
							capture reghdfe `y' tEMp_tREAt `controls', absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'
								local rc = _rc
								if `rc' { 
									noisily display "{err}Error using reghdfe: "
									tempfile reghdfe_error
									save "`reghdfe_error'"
									use "`m_dta_before_sims'", clear
									preserve
									use "`reghdfe_error'", clear
									noisily reghdfe `y' tEMp_tREAt `controls', absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'
									restore
								}
						}
						else {
							capture reghdfe `y' tEMp_tREAt `controls' [`weight'], absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'								
								local rc = _rc
								if `rc' { 
									noisily display "{err}Error using reghdfe: "
									tempfile reghdfe_error
									save "`reghdfe_error'"
									use "`m_dta_before_sims'", clear
									preserve
									use "`reghdfe_error'", clear
									noisily reghdfe `y' tEMp_tREAt `controls' [`weight'], absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'								
									restore
								}
						}
			
						* break if treatment effect or outcome variable is collinear with controls or fixed effects
						capture assert (_se[tEMp_tREAt]==0)==0
							local rc = _rc
							if `rc' {
								noisily display "{err}Error: Treatment effect (or outcome variable) is collinear with either fixed effects "
								noisily display "{err}       or controls. ONESHOT model cannot include any fixed effects other than "
								noisily display "{err}       a cross-sectional group variable within which unit of treatment `i' is nested.  "
								use "`m_dta_before_sims'", clear	
								exit `rc'
							}
			
						* determine if null hypothesis was rejected
						if "`onesided'"=="" {
							local pvalLOOP = 2*ttail(e(df_r),abs(_b[tEMp_tREAt]/_se[tEMp_tREAt])) // <-- two-sided p-value 
						}
						else if "`onesided'"=="onesided" & sign(_b[tEMp_tREAt])==sign(`mdeLOOP') {
							local pvalLOOP = ttail(e(df_r),abs(_b[tEMp_tREAt]/_se[tEMp_tREAt]))    // <-- one-sided p-value 
						}
						else if "`onesided'"=="onesided" & sign(_b[tEMp_tREAt])!=sign(`mdeLOOP') {
							local pvalLOOP = 1  // <-- one-sided p-value (opposite sign, cannot reject H0)
						}
							
						use `m_dta_during_sims', clear

						* store whether null hypothesis was rejected for this simulation
						if `pvalLOOP'<=`alpha' {
							replace SIMreject = 1 if SIMid==`nsimLOOP'
						}
						else {
							replace SIMreject = 0 if SIMid==`nsimLOOP'
						}
						capture assert `pvalLOOP'>=0 & `pvalLOOP'<=1
							local rc = _rc
							if `rc' {
								noisily display "{err}Error: `pvalLOOP' not a valid p-value"
								use "`m_dta_before_sims'", clear	
								exit `rc'
							}
							
						save `m_dta_during_sims', replace
					
					}
					
					* store rejection rates for this set of parameters
					replace nOuT = `nLOOP' if SIMid==`indexOuT'
					replace pOuT = `pLOOP' if SIMid==`indexOuT'
					replace mdeOuT = `mdeLOOP' if SIMid==`indexOuT'
					sum SIMreject
					replace powerOuT = r(mean) if SIMid==`indexOuT'
					local tEMp_mEAn = string(`r(mean)',"%9.3f")
		
					* reset for next set of simulation 
					replace SIMreject = .
					local indexOuT = `indexOuT'+1
					save `m_dta_during_sims', replace
				
						* intermediate output
						foreach LOOP_var in n p mde {
							local `LOOP_var'LOOP_sp = `len_MAX_`LOOP_var'' - length("``LOOP_var'LOOP'")
							if ``LOOP_var'LOOP_sp'==0 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'"
							}
							else if ``LOOP_var'LOOP_sp'==1 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP' "
							}
							else if ``LOOP_var'LOOP_sp'==2 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'  "
							}
							else if ``LOOP_var'LOOP_sp'==3 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'   "
							}
							else if ``LOOP_var'LOOP_sp'==4 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'    "
							}
							else if ``LOOP_var'LOOP_sp'==5 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'     "
							}
							else if ``LOOP_var'LOOP_sp'==6 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'      "
							}
							else {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'       "
							}
						}
						
						noisily display "{inp}Completed:   n=`nLOOP_disp'   p=`pLOOP_disp'   mde=`mdeLOOP_disp'   power= `tEMp_mEAn'"
					
				}
			}
		}
	}
}


// 5B. model == POST
else if "`model'"=="POST" {
	quietly {
		
		* create locals for spacing of intermediate output
		foreach len_MAX in n p mde post {
			local len_MAX_`len_MAX' = 1
			foreach len_MAX_loop in ``len_MAX''{
				local len_MAX_`len_MAX' = max(`len_MAX_`len_MAX'',length("`len_MAX_loop'"))
			}
		}
		
		* restrict time periods if option tstart() is toggled
		if "`tstart'"!="" {
			capture keep if `t'>=real(word("`tstart'",1))
			capture keep if `t'<=real(word("`tstart'",2))+`postMAX'-1
		}
		sum `t'
		local tperiodMAX = r(max)

		* create enough observations to store all simulation results
		local newN = max(_N,`nsim')
		set obs `newN'

		* create variables to index simulations and store a rejection dummy
		gen SIMid = _n
		replace SIMid = . if SIMid>`nsim'
		gen SIMreject = .
		
		* create empty variables to store results
		gen double nOuT = .
		gen double pOuT = .
		gen double mdeOuT = .
		gen double postOuT = .
		gen double powerOuT = .
		local indexOuT = 1

		* create temp file to store results
		tempfile m_dta_during_sims
		quietly save `m_dta_during_sims', replace

		* loop over `n', `p', `mde', and `post', `nsim' times each
		foreach nLOOP in  `n' {	
			foreach pLOOP in `p' {
				local nLOOP_T = round(`nLOOP'*`pLOOP')
				foreach mdeLOOP in `mde' {
					foreach postLOOP in `post' {
						forvalues nsimLOOP = 1/`nsim' {

							use `m_dta_during_sims', clear

							* randomly pick time period to start POST RCT								
							gen tEMp_rAndom1 = runiform() if `t'+`postLOOP'-1<=`tperiodMAX' 
							sort tEMp_rAndom1
							local tSTART_LOOP =`t'[1]
							local tEND_LOOP = `tSTART_LOOP'+`postLOOP'-1
							keep if inrange(`t',`tSTART_LOOP',`tEND_LOOP') 

							* if drawing units WITHOUT replacement (option bootstrap is not specified)
							if "`bootstrap'"=="" {
								* confirm that randomly selected time periods have enough observations
								if "`stratify'"!="" & "`idcluster'"=="" {
									forvalues stratLOOP = 1/`levelsSTRAT' {
										unique `i' if tEMp_grpSTRAT==`stratLOOP'
										capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
											local rc = _rc
											if `rc' {
												noisily display "{err}Error: Time periods `t'=`tSTART_LOOP' thru `t'=`tEND_LOOP' do not include enough `i' units "
												noisily display "{err}       to randomize across `nLOOP' units in each stratified randomization cell "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
									}
								}
								else if "`stratify'"=="" & "`idcluster'"=="" {
									unique `i'
									capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
										local rc = _rc
										if `rc' {
											noisily display "{err}Error: Time periods `t'=`tSTART_LOOP' thru `t'=`tEND_LOOP' do not include "
											noisily display "{err}       enough `i' units to randomize across `nLOOP' units "
											use "`m_dta_before_sims'", clear	
											exit `rc'
										}								
								}
								else if "`stratify'"=="" & "`idcluster'"!="" {
									unique `idcluster'
									capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
										local rc = _rc
										if `rc' {
											noisily display "{err}Error: Time periods `t'=`tSTART_LOOP' thru `t'=`tEND_LOOP' do not include"
											noisily display "{err}       enough `idcluster' clusters to randomize across `nLOOP' clusters "
											use "`m_dta_before_sims'", clear	
											exit `rc'
										}								
								}
						
								* randomly pick `nLOOP' units and assign treatment to `nLOOP_T' of them
								if "`stratify'"!="" & "`idcluster'"=="" {
									egen tEMp_iUNIT_minT = min(`t'), by(`i')
									gen tEMp_rAndom2 = runiform()+tEMp_grpSTRAT if `t'==tEMp_iUNIT_minT
									by tEMp_grpSTRAT (tEMp_rAndom2), sort : gen tEMp_tREAt_tEMp = 0 if _n<=`nLOOP'				
									by tEMp_grpSTRAT (tEMp_rAndom2), sort : replace tEMp_tREAt_tEMp = 1 if _n<=`nLOOP_T'
									egen tEMp_tREAt = mean(tEMp_tREAt_tEMp), by(`i')
								}
								else if "`stratify'"=="" & "`idcluster'"=="" {
									egen tEMp_iUNIT_minT = min(`t'), by(`i')
									gen tEMp_rAndom2 = runiform() if `t'==tEMp_iUNIT_minT
									sort tEMp_rAndom2
									gen tEMp_tREAt_tEMp = 0 if _n<=`nLOOP'
									replace tEMp_tREAt_tEMp = 1 if _n<=`nLOOP_T'
									egen tEMp_tREAt = mean(tEMp_tREAt_tEMp), by(`i')
								}
								else if "`stratify'"=="" & "`idcluster'"!="" {
									
									* assign treatment at the cluster level
									egen tEMp_iCL_minT = min(`t'), by(`idcluster')
									egen tEMp_tag_CLUSTER = tag(`idcluster') if `t'==tEMp_iCL_minT
									gen tEMp_rAndom2 = runiform() 
									gsort -tEMp_tag_CLUSTER tEMp_rAndom2
									gen tEMp_CLtREAt_temp = 0 if _n<=`nLOOP' & tEMp_tag_CLUSTER==1
									replace tEMp_CLtREAt_temp = 1 if _n<=`nLOOP_T' & tEMp_tag_CLUSTER==1
									egen tEMp_CLtREAt = mean(tEMp_CLtREAt_temp), by(`idcluster')
									keep if tEMp_CLtREAt!=.
								
									* assign cluster-specific treatment intensities
									egen tEMp_CLtREAt_P_temp1 = fill(`pcluster' `pcluster')
									replace tEMp_CLtREAt_P_temp1 = . if tEMp_tag_CLUSTER!=1
									egen tEMp_CLtREAt_P_temp2 = mean(tEMp_CLtREAt_P_temp1), by(`idcluster')
									gen tEMp_CLtREAt_P = tEMp_CLtREAt*tEMp_CLtREAt_P_temp2
									assert tEMp_CLtREAt_P==0 if tEMp_CLtREAt==0
									assert tEMp_CLtREAt_P>0 & tEMp_CLtREAt_P<=1 if tEMp_CLtREAt==1
								
									* set number of units in each cluster, confirm sufficient size
									if "`sizecluster'"!="" {
										levelsof `idcluster', local(levs)
										foreach grpCLUST_LOOP in `levs' {
											unique `i' if `idcluster'==`grpCLUST_LOOP'
											capture assert `sizecluster'<=r(sum) & `sizecluster'<=r(unique)
												local rc = _rc
												if `rc' {
													noisily display "{err}Error: Cluster `idcluster'=`grpCLUST_LOOP' does not include"
													noisily display "{err}       `sizecluster' units; use option bootstrap "
													use "`m_dta_before_sims'", clear	
													exit `rc'
												}								
										}
										egen tEMp_iUNIT_minT = min(`t'), by(`i')
										gen tEMp_rAndom3 = runiform() if `t'==tEMp_iUNIT_minT
										by `idcluster' (tEMp_rAndom3), sort : gen tEMp_todrop1 = _n>`sizecluster' & `t'==tEMp_iUNIT_minT
										egen tEMp_todrop2 = max(tEMp_todrop1), by(`i')
										drop if tEMp_todrop2==1
									}
									
									* randomize at the unit level, within clusters
									egen tEMp_iUNIT_minT2 = min(`t'), by(`i')
									gen tEMp_rAndom4 = runiform() if `t'==tEMp_iUNIT_minT2
									by `idcluster' (tEMp_rAndom4), sort : gen tEMp_uNIT_rank = _n
									egen tEMp_uNIT_rank_MAX = max(tEMp_uNIT_rank) if `t'==tEMp_iUNIT_minT2, by(`idcluster')
									gen tEMp_uNIT_rank_MAXT = tEMp_uNIT_rank_MAX*tEMp_CLtREAt_P
									gen tEMp_tREAt_tEMp = tEMp_uNIT_rank<=round(tEMp_uNIT_rank_MAXT) & `t'==tEMp_iUNIT_minT2
									egen tEMp_tREAt = max(tEMp_tREAt_tEMp), by(`i')
								}
								
								keep if tEMp_tREAt!=.
								assert tEMp_tREAt==0 | tEMp_tREAt==1
							}
							
							* if drawing units WITH replacement (option bootstrap is specified)
							if "`bootstrap'"!="" {
								if "`stratify'"!="" & "`idcluster'"=="" {

									* sample `nLOOP' units with replacement
									sum tEMp_grpSTRAT
									local levelsSTRAT = r(max)
									local expand_numb = 1
									forvalues stratLOOP = 1/`levelsSTRAT' {
										quietly unique `i' if tEMp_grpSTRAT==`stratLOOP'
										local expand_numb = max(`expand_numb',ceil(`nLOOP'/r(sum)),ceil(`nLOOP'/r(unique)))
									}
									expand `expand_numb'
									bysort `i' `t' : gen tEMp_bSAMple_id1 = _n
									egen tEMp_bSAMple_id2 = group(`i' tEMp_bSAMple_id1)
									drop `i'
									bsample `nLOOP', strata(tEMp_grpSTRAT) cluster(tEMp_bSAMple_id2) idcluster(`i')

									* randomly pick `nLOOP' units and assign treatment to `nLOOP_T' of them
									egen tEMp_iUNIT_minT = min(`t'), by(`i')
									gen tEMp_rAndom2 = runiform()+tEMp_grpSTRAT if `t'==tEMp_iUNIT_minT
									by tEMp_grpSTRAT (tEMp_rAndom2), sort : gen tEMp_tREAt_tEMp = 0 if _n<=`nLOOP'				
									by tEMp_grpSTRAT (tEMp_rAndom2), sort : replace tEMp_tREAt_tEMp = 1 if _n<=`nLOOP_T'
									egen tEMp_tREAt = mean(tEMp_tREAt_tEMp), by(`i')
								}
								else if "`stratify'"=="" & "`idcluster'"=="" {

									* sample `nLOOP' units with replacement
									unique `i'
									local expand_numb = min(ceil(`nLOOP'/r(sum)),ceil(`nLOOP'/r(unique)))
									expand `expand_numb'
									bysort `i' `t' : gen tEMp_bSAMple_id1 = _n
									egen tEMp_bSAMple_id2 = group(`i' tEMp_bSAMple_id1)
									drop `i'
									bsample `nLOOP', cluster(tEMp_bSAMple_id2) idcluster(`i')

									* randomly pick `nLOOP' units and assign treatment to `nLOOP_T' of them
									egen tEMp_iUNIT_minT = min(`t'), by(`i')
									gen tEMp_rAndom2 = runiform() if `t'==tEMp_iUNIT_minT
									sort tEMp_rAndom2
									gen tEMp_tREAt_tEMp = 0 if _n<=`nLOOP'
									replace tEMp_tREAt_tEMp = 1 if _n<=`nLOOP_T'
									egen tEMp_tREAt = mean(tEMp_tREAt_tEMp), by(`i')
								}
								else if "`stratify'"=="" & "`idcluster'"!="" {
									
									* sample `nLOOP' clusters with replacement
									preserve
									keep `idcluster'
									duplicates drop
									local expand_numb = ceil(`nLOOP'/_N)
									expand `expand_numb'
									bsample `nLOOP'
									gen clID_bsample = _n
									tempfile bsample_output_clusters
									save "`bsample_output_clusters'"
									restore
									joinby `idcluster' using "`bsample_output_clusters'"
									drop `idcluster'
									rename clID_bsample `idcluster'

									* assign treatment at the cluster level
									egen tEMp_iCL_minT = min(`t'), by(`idcluster')
									egen tEMp_tag_CLUSTER = tag(`idcluster') if `t'==tEMp_iCL_minT
									gen tEMp_rAndom2 = runiform() 
									gsort -tEMp_tag_CLUSTER tEMp_rAndom2
									gen tEMp_CLtREAt_temp = 0 if _n<=`nLOOP' & tEMp_tag_CLUSTER==1
									replace tEMp_CLtREAt_temp = 1 if _n<=`nLOOP_T' & tEMp_tag_CLUSTER==1
									egen tEMp_CLtREAt = mean(tEMp_CLtREAt_temp), by(`idcluster')
									keep if tEMp_CLtREAt!=.
								
									* reindex unit identifiers
									egen tEMp_uNIT_id_NEW = group(`idcluster' `i')
									drop `i'
									rename tEMp_uNIT_id_NEW `i'
								
									* assign cluster-specific treatment intensities
									egen tEMp_CLtREAt_P_temp1 = fill(`pcluster' `pcluster')
									replace tEMp_CLtREAt_P_temp1 = . if tEMp_tag_CLUSTER!=1
									egen tEMp_CLtREAt_P_temp2 = mean(tEMp_CLtREAt_P_temp1), by(`idcluster')
									gen tEMp_CLtREAt_P = tEMp_CLtREAt*tEMp_CLtREAt_P_temp2
									assert tEMp_CLtREAt_P==0 if tEMp_CLtREAt==0
									assert tEMp_CLtREAt_P>0 & tEMp_CLtREAt_P<=1 if tEMp_CLtREAt==1
								
									* sample `sizecluster' units with replacement, within each cluster
									if "`sizecluster'"!="" {
										egen tEMp_iUNIT_minT = min(`t'), by(`i')
										gen tEMp_iUNIT_minT_temp = `t'==tEMp_iUNIT_minT
										by `idcluster' tEMp_iUNIT_minT_temp, sort : gen tEMp_cl_size_preBS_temp = _N
										replace tEMp_cl_size_preBS_temp = . if tEMp_iUNIT_minT_temp==0
										egen tEMp_cl_size_preBS = max(tEMp_cl_size_preBS_temp), by(`idcluster') 
										gen tEMp_expand_numb = ceil(`sizecluster'/tEMp_cl_size_preBS)
										expand tEMp_expand_numb
										bysort `idcluster' `i' `t' : gen tEMp_bSAMple_id1 = _n
										egen tEMp_bSAMple_id2 = group(`idcluster' `i' tEMp_bSAMple_id1)
										drop `i'
										bsample `sizecluster', strata(`idcluster') cluster(tEMp_bSAMple_id2) idcluster(`i')
										by `idcluster' tEMp_iUNIT_minT_temp, sort : gen tEMp_cl_size_postBS_temp = _N
										replace tEMp_cl_size_postBS_temp = . if tEMp_iUNIT_minT_temp==0
										egen tEMp_cl_size_postBS = max(tEMp_cl_size_postBS_temp), by(`idcluster') 
										assert tEMp_cl_size_postBS==`sizecluster'									
									}
									
									* randomize at the unit level, within clusters
									egen tEMp_iUNIT_minT2 = min(`t'), by(`i')
									gen tEMp_rAndom3 = runiform() if `t'==tEMp_iUNIT_minT2
									by `idcluster' (tEMp_rAndom3), sort : gen tEMp_uNIT_rank = _n
									egen tEMp_uNIT_rank_MAX = max(tEMp_uNIT_rank) if `t'==tEMp_iUNIT_minT2, by(`idcluster')
									gen tEMp_uNIT_rank_MAXT = tEMp_uNIT_rank_MAX*tEMp_CLtREAt_P
									gen tEMp_tREAt_tEMp = tEMp_uNIT_rank<=round(tEMp_uNIT_rank_MAXT) & `t'==tEMp_iUNIT_minT2
									egen tEMp_tREAt = max(tEMp_tREAt_tEMp), by(`i')
								}							
								capture assert tEMp_tREAt!=.
									local rc = _rc
									if `rc' {
										noisily display "{err}Error: Option bootstrap causing bsample to break for some reason... "
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}
								assert tEMp_tREAt==0 | tEMp_tREAt==1
							}

							* add treatment effects of `mdeLOOP' for treated units only
							replace `y' = `y' + `mdeLOOP' if tEMp_tREAt==1
							
							* collapse to cross-section if option collapse specified
							if "`collapse'"=="collapse" {
								collapse (mean) `y' tEMp_tREAt `controls' `wtvar', by(`i' `absorb' `abs_fvars' `cl_varlist') fast
								unique `i'
								capture assert (r(sum)==_N) | (r(unique)==_N)
									local rc = _rc
									if `rc' & "`absorb'"!="" { 
										noisily display "{err}Error: `i' not unique after collapsing data; to use collapse option, adjust "
										noisily display "{err}       absorb() option to include only fixed effects that are unique by `i' "
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}									
									else if `rc' & "`abs_fvars'"!="" { 
										noisily display "{err}Error: `i' not unique after collapsing data; to use collapse option, adjust "
										noisily display "{err}       absorbfactor() option to include only fixed effects that are unique by `i' "
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}									
									else if `rc' & "`cl_varlist'"!="" { 
										noisily display "{err}Error: `i' not unique after collapsing data; to use collapse option, adjust "
										noisily display "{err}       vce() option to cluster by variables that are unique by `i' "
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}									
									else if `rc' { 
										noisily display "{err}Error using collapse option: `i' not unique after collapsing data "
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}									
							}
							
							* estimate regression
							if "`weight'"=="" {
								capture reghdfe `y' tEMp_tREAt `controls', absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'
									local rc = _rc
									if `rc' { 
										noisily display "{err}Error using reghdfe: "
										tempfile reghdfe_error
										save "`reghdfe_error'"
										use "`m_dta_before_sims'", clear
										preserve
										use ""`reghdfe_error'"", clear
										noisily reghdfe `y' tEMp_tREAt `controls', absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'								
										restore
									}
							}
							else {
								capture reghdfe `y' tEMp_tREAt `controls' [`weight'], absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'								
									local rc = _rc
									if `rc' { 
										noisily display "{err}Error using reghdfe: "
										tempfile reghdfe_error
										save "`reghdfe_error'"
										use "`m_dta_before_sims'", clear
										preserve
										use "`reghdfe_error'", clear
										noisily reghdfe `y' tEMp_tREAt `controls' [`weight'], absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'								
										restore
									}
							}

							* break if treatment effect or outcome variable is collinear with controls or fixed effects
							capture assert (_se[tEMp_tREAt]==0)==0
								local rc = _rc
								if `rc' & "`collapse'"=="collapse" {
									noisily display "{err}Error: Treatment effect (or outcome variable) is collinear with either fixed effects "
									noisily display "{err}       or controls. Collapsed POST model cannot include any fixed effects other than "
									noisily display "{err}       a cross-sectional group variable within which unit of treatment `i' is nested.  "
									use "`m_dta_before_sims'", clear	
									exit `rc'
								}
								else if `rc' & "`collapse'"=="" {
									noisily display "{err}Error: Treatment effect (or outcome variable) is collinear with either fixed effects "
									noisily display "{err}       or controls. POST model cannot include any cross-sectional fixed effects "
									noisily display "{err}       other than a group variable within which the treatment unit (`i') is nested.  "						
									use "`m_dta_before_sims'", clear	
									exit `rc'
								}
			
							* determine if null hypothesis was rejected
							if "`onesided'"=="" {
								local pvalLOOP = 2*ttail(e(df_r),abs(_b[tEMp_tREAt]/_se[tEMp_tREAt])) // <-- two-sided p-value 
							}
							else if "`onesided'"=="onesided" & sign(_b[tEMp_tREAt])==sign(`mdeLOOP') {
								local pvalLOOP = ttail(e(df_r),abs(_b[tEMp_tREAt]/_se[tEMp_tREAt]))    // <-- one-sided p-value 
							}
							else if "`onesided'"=="onesided" & sign(_b[tEMp_tREAt])!=sign(`mdeLOOP') {
								local pvalLOOP = 1  // <-- one-sided p-value with opposite sign (cannot reject H0)
							}
							
							use `m_dta_during_sims', clear

							* store whether null hypothesis was rejected for this simulation
							if `pvalLOOP'<=`alpha' {
								replace SIMreject = 1 if SIMid==`nsimLOOP'
							}
							else {
								replace SIMreject = 0 if SIMid==`nsimLOOP'
							}
							capture assert `pvalLOOP'>=0 & `pvalLOOP'<=1
								local rc = _rc
								if `rc' {
									noisily display "{err}Error: `pvalLOOP' not a valid p-value"
									use "`m_dta_before_sims'", clear	
									exit `rc'
								}
							
							save `m_dta_during_sims', replace
						
						}
						
						* store rejection rates for this set of parameters
						replace nOuT = `nLOOP' if SIMid==`indexOuT'
						replace pOuT = `pLOOP' if SIMid==`indexOuT'
						replace mdeOuT = `mdeLOOP' if SIMid==`indexOuT'
						replace postOuT = `postLOOP' if SIMid==`indexOuT'
						sum SIMreject
						replace powerOuT = r(mean) if SIMid==`indexOuT'
						local tEMp_mEAn = string(`r(mean)',"%9.3f")
			
						* reset for next set of simulation 
						replace SIMreject = .
						local indexOuT = `indexOuT'+1
						save `m_dta_during_sims', replace

						* intermediate output
						foreach LOOP_var in n p mde post {
							local `LOOP_var'LOOP_sp = `len_MAX_`LOOP_var'' - length("``LOOP_var'LOOP'")
							if ``LOOP_var'LOOP_sp'==0 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'"
							}
							else if ``LOOP_var'LOOP_sp'==1 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP' "
							}
							else if ``LOOP_var'LOOP_sp'==2 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'  "
							}
							else if ``LOOP_var'LOOP_sp'==3 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'   "
							}
							else if ``LOOP_var'LOOP_sp'==4 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'    "
							}
							else if ``LOOP_var'LOOP_sp'==5 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'     "
							}
							else if ``LOOP_var'LOOP_sp'==6 {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'      "
							}
							else {
								local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'       "
							}
						}
						
						noisily display "{inp}Completed:   n=`nLOOP_disp'   p=`pLOOP_disp'   mde=`mdeLOOP_disp'   post=`postLOOP_disp'   power= `tEMp_mEAn'"
						
					}
				}					
			}
		}	
	}
}


// 5C. model == DD
else if "`model'"=="DD" {
	quietly {
		
		* create locals for spacing of intermediate output
		foreach len_MAX in n p mde post pre {
			local len_MAX_`len_MAX' = 1
			foreach len_MAX_loop in ``len_MAX''{
				local len_MAX_`len_MAX' = max(`len_MAX_`len_MAX'',length("`len_MAX_loop'"))
			}
		}
		
		* restrict time periods if option tstart() is toggled
		if "`tstart'"!="" {
			capture keep if `t'>=real(word("`tstart'",1))
			capture keep if `t'<=real(word("`tstart'",2))+`preMAX'+`postMAX'-1
		}
		sum `t'
		local tperiodMAX = r(max)

		* create enough observations to store all simulation results
		local newN = max(_N,`nsim')
		set obs `newN'

		* create variables to index simulations and store a rejection dummy
		gen SIMid = _n
		replace SIMid = . if SIMid>`nsim'
		gen SIMreject = .
		
		* create empty variables to store results
		gen double nOuT = .
		gen double pOuT = .
		gen double mdeOuT = .
		gen double preOuT = .
		gen double postOuT = .
		gen double powerOuT = .
		local indexOuT = 1

		* create temp file to store results
		tempfile m_dta_during_sims
		quietly save `m_dta_during_sims', replace

		* loop over `n', `p', `mde', `pre', and `post', `nsim' times each
		foreach nLOOP in  `n' {	
			foreach pLOOP in `p' {
				local nLOOP_T = round(`nLOOP'*`pLOOP')
				foreach mdeLOOP in `mde' {
					foreach preLOOP in `pre' {
						foreach postLOOP in `post' {
							forvalues nsimLOOP = 1/`nsim' {
								
								use `m_dta_during_sims', clear

								* randomly pick time period to start DD RCT								
								gen tEMp_rAndom1 = runiform() if `t'+`preLOOP'+`postLOOP'-1<=`tperiodMAX'
								sort tEMp_rAndom1
								local tSTART_LOOP =`t'[1]
								local tEND_LOOP = `tSTART_LOOP'+`preLOOP'+`postLOOP'-1
								keep if inrange(`t',`tSTART_LOOP',`tEND_LOOP') 

								* generate post-treatment indicator
								local preEND_LOOP = `tSTART_LOOP'+`preLOOP'-1
								local postSTART_LOOP = `preEND_LOOP'+1
								gen tEMp_pOSt = `t'>=`postSTART_LOOP'
								egen tEMp_pOSt_min = min(tEMp_pOSt), by(`i')
								egen tEMp_pOSt_max = max(tEMp_pOSt), by(`i')
								keep if tEMp_pOSt_max>tEMp_pOSt_min
								
								* if drawing units WITHOUT replacement (option bootstrap is not specified)
								if "`bootstrap'"=="" {
									* confirm that randomly selected time periods have enough observations
									if "`stratify'"!="" & "`idcluster'"=="" {
										forvalues stratLOOP = 1/`levelsSTRAT' {
											unique `i' if tEMp_grpSTRAT==`stratLOOP' & tEMp_pOSt==0
											capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
												local rc = _rc
												if `rc' & `preLOOP'>1 {
													noisily display "{err}Error: Time periods `t'=`tSTART_LOOP' thru `t'=`preEND_LOOP' do not include enough `i' units "
													noisily display "{err}       to randomize across `nLOOP' units in each stratified randomization cell "
													use "`m_dta_before_sims'", clear	
													exit `rc'
												}								
												else if `rc' {
													noisily display "{err}Error: Time period `t'=`preEND_LOOP' does not include enough `i' units "
													noisily display "{err}       to randomize across `nLOOP' units in each stratified randomization cell "
													use "`m_dta_before_sims'", clear	
													exit `rc'
												}								
											unique `i' if tEMp_grpSTRAT==`stratLOOP' & tEMp_pOSt==1
											capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
												local rc = _rc
												if `rc' & `postLOOP'>1 {
													noisily display "{err}Error: Time periods `t'=`postSTART_LOOP' thru `t'=`tEND_LOOP' do not include enough `i' units "
													noisily display "{err}       to randomize across `nLOOP' units in each stratified randomization cell "
													use "`m_dta_before_sims'", clear	
													exit `rc'
												}								
												else if `rc' {
													noisily display "{err}Error: Time period `t'=`postSTART_LOOP' does not include enough `i' units "
													noisily display "{err}       to randomize across `nLOOP' units in each stratified randomization cell "
													use "`m_dta_before_sims'", clear	
													exit `rc'
												}								
										}
									}
									else if "`stratify'"=="" & "`idcluster'"=="" {
										unique `i' if tEMp_pOSt==0
										capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
											local rc = _rc
											if `rc' & `preLOOP'>1 {
												noisily display "{err}Error: Time periods `t'=`tSTART_LOOP' thru `t'=`preEND_LOOP' do not include "
												noisily display "{err}       enough `i' units to randomize across `nLOOP' units "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
											else if `rc' {
												noisily display "{err}Error: Time period `t'=`preEND_LOOP' does not include "
												noisily display "{err}       enough `i' units to randomize across `nLOOP' units "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
										unique `i' if tEMp_pOSt==1
										capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
											local rc = _rc
											if `rc' & `postLOOP'>1 {
												noisily display "{err}Error: Time periods `t'=`postSTART_LOOP' thru `t'=`tEND_LOOP' do not include "
												noisily display "{err}       enough `i' units to randomize across `nLOOP' units "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
											else if `rc' {
												noisily display "{err}Error: Time period `t'=`postSTART_LOOP' does not include "
												noisily display "{err}       enough `i' units to randomize across `nLOOP' units "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
									}
									else if "`stratify'"=="" & "`idcluster'"!="" {
										unique `idcluster' if tEMp_pOSt==0
										capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
											local rc = _rc
											if `rc' & `preLOOP'>1 {
												noisily display "{err}Error: Time periods `t'=`tSTART_LOOP' thru `t'=`preEND_LOOP' do not include "
												noisily display "{err}       enough `idcluster' clusters to randomize across `nLOOP' clusters "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
											else if `rc' {
												noisily display "{err}Error: Time period `t'=`preEND_LOOP' does not include "
												noisily display "{err}       enough `idcluster' clusters to randomize across `nLOOP' clusters "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
										unique `idcluster' if tEMp_pOSt==1
										capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
											local rc = _rc
											if `rc' & `postLOOP'>1 {
												noisily display "{err}Error: Time periods `t'=`postSTART_LOOP' thru `t'=`tEND_LOOP' do not include "
												noisily display "{err}       enough `idcluster' clusters to randomize across `nLOOP' clusters "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
											else if `rc' {
												noisily display "{err}Error: Time period `t'=`postSTART_LOOP' does not include "
												noisily display "{err}       enough `idcluster' clusters to randomize across `nLOOP' clusters "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
									}

									* randomly pick `nLOOP' units and assign treatment to `nLOOP_T' of them
									if "`stratify'"!="" & "`idcluster'"=="" {
										egen tEMp_iUNIT_minT = min(`t') if tEMp_pOSt==1, by(`i')
										gen tEMp_rAndom2 = runiform()+tEMp_grpSTRAT if `t'==tEMp_iUNIT_minT
										by tEMp_grpSTRAT (tEMp_rAndom2), sort : gen tEMp_tREAt_tEMp = 0 if _n<=`nLOOP'				
										by tEMp_grpSTRAT (tEMp_rAndom2), sort : replace tEMp_tREAt_tEMp = 1 if _n<=`nLOOP_T'
										egen tEMp_tREAt = mean(tEMp_tREAt_tEMp), by(`i')
										replace tEMp_tREAt = 0 if tEMp_tREAt!=. & tEMp_pOSt==0
									}
									else if "`stratify'"=="" & "`idcluster'"==""  {
										egen tEMp_iUNIT_minT = min(`t') if tEMp_pOSt==1, by(`i')
										gen tEMp_rAndom2 = runiform() if `t'==tEMp_iUNIT_minT
										sort tEMp_rAndom2
										gen tEMp_tREAt_tEMp = 0 if _n<=`nLOOP'
										replace tEMp_tREAt_tEMp = 1 if _n<=`nLOOP_T'
										egen tEMp_tREAt = mean(tEMp_tREAt_tEMp), by(`i')
										replace tEMp_tREAt = 0 if tEMp_tREAt!=. & tEMp_pOSt==0
									}
									else if "`stratify'"=="" & "`idcluster'"!="" {
																				
										* assign treatment at the cluster level
										egen tEMp_iCL_minT = min(`t') if tEMp_pOSt==1, by(`idcluster')
										egen tEMp_tag_CLUSTER = tag(`idcluster') if `t'==tEMp_iCL_minT
										gen tEMp_rAndom2 = runiform() 
										gsort -tEMp_tag_CLUSTER tEMp_rAndom2
										gen tEMp_CLtREAt_temp = 0 if _n<=`nLOOP' & tEMp_tag_CLUSTER==1
										replace tEMp_CLtREAt_temp = 1 if _n<=`nLOOP_T' & tEMp_tag_CLUSTER==1
										egen tEMp_CLtREAt = mean(tEMp_CLtREAt_temp), by(`idcluster')
										keep if tEMp_CLtREAt!=.
									
										* assign cluster-specific treatment intensities
										egen tEMp_CLtREAt_P_temp1 = fill(`pcluster' `pcluster')
										replace tEMp_CLtREAt_P_temp1 = . if tEMp_tag_CLUSTER!=1
										egen tEMp_CLtREAt_P_temp2 = mean(tEMp_CLtREAt_P_temp1), by(`idcluster')
										gen tEMp_CLtREAt_P = tEMp_CLtREAt*tEMp_CLtREAt_P_temp2
										assert tEMp_CLtREAt_P==0 if tEMp_CLtREAt==0
										assert tEMp_CLtREAt_P>0 & tEMp_CLtREAt_P<=1 if tEMp_CLtREAt==1
									
										* set number of units in each cluster, confirm sufficient size
										if "`sizecluster'"!="" {
											levelsof `idcluster', local(levs)
											foreach grpCLUST_LOOP in `levs' {
												unique `i' if `idcluster'==`grpCLUST_LOOP'
												capture assert `sizecluster'<=r(sum) & `sizecluster'<=r(unique)
													local rc = _rc
													if `rc' {
														noisily display "{err}Error: Cluster `idcluster'=`grpCLUST_LOOP' does not include"
														noisily display "{err}       `sizecluster' units; use option bootstrap "
														use "`m_dta_before_sims'", clear	
														exit `rc'
													}								
											}
											egen tEMp_iUNIT_minT = min(`t') if tEMp_pOSt==1, by(`i')
											gen tEMp_rAndom3 = runiform() if `t'==tEMp_iUNIT_minT
											by `idcluster' (tEMp_rAndom3), sort : gen tEMp_todrop1 = _n>`sizecluster' & `t'==tEMp_iUNIT_minT
											egen tEMp_todrop2 = max(tEMp_todrop1), by(`i')
											drop if tEMp_todrop2==1
										}
										
										* randomize at the unit level, within clusters
										egen tEMp_iUNIT_minT2 = min(`t') if tEMp_pOSt==1, by(`i')
										gen tEMp_rAndom4 = runiform() if `t'==tEMp_iUNIT_minT2
										by `idcluster' (tEMp_rAndom4), sort : gen tEMp_uNIT_rank = _n
										egen tEMp_uNIT_rank_MAX = max(tEMp_uNIT_rank) if `t'==tEMp_iUNIT_minT2, by(`idcluster')
										gen tEMp_uNIT_rank_MAXT = tEMp_uNIT_rank_MAX*tEMp_CLtREAt_P
										gen tEMp_tREAt_tEMp = tEMp_uNIT_rank<=round(tEMp_uNIT_rank_MAXT) & `t'==tEMp_iUNIT_minT2
										egen tEMp_tREAt = max(tEMp_tREAt_tEMp), by(`i')
										replace tEMp_tREAt = 0 if tEMp_tREAt!=. & tEMp_pOSt==0
									}
									
									keep if tEMp_tREAt!=.
									assert tEMp_tREAt==0 | tEMp_tREAt==1
								}
								
								* if drawing units WITH replacement (option bootstrap is specified)
								if "`bootstrap'"!="" {
									if "`stratify'"!="" & "`idcluster'"=="" {
										* sample `nLOOP' units with replacement
										sum tEMp_grpSTRAT
										local levelsSTRAT = r(max)
										local expand_numb = 1
										forvalues stratLOOP = 1/`levelsSTRAT' {
											quietly unique `i' if tEMp_grpSTRAT==`stratLOOP'
											local expand_numb = max(`expand_numb',ceil(`nLOOP'/r(sum)),ceil(`nLOOP'/r(unique)))
										}
										expand `expand_numb'
										bysort `i' `t' : gen tEMp_bSAMple_id1 = _n
										egen tEMp_bSAMple_id2 = group(`i' tEMp_bSAMple_id1)
										drop `i'
										bsample `nLOOP', strata(tEMp_grpSTRAT) cluster(tEMp_bSAMple_id2) idcluster(`i')

										* randomly pick `nLOOP' units and assign treatment to `nLOOP_T' of them
										egen tEMp_iUNIT_minT = min(`t') if tEMp_pOSt==1, by(`i')
										gen tEMp_rAndom2 = runiform()+tEMp_grpSTRAT if `t'==tEMp_iUNIT_minT
										by tEMp_grpSTRAT (tEMp_rAndom2), sort : gen tEMp_tREAt_tEMp = 0 if _n<=`nLOOP'				
										by tEMp_grpSTRAT (tEMp_rAndom2), sort : replace tEMp_tREAt_tEMp = 1 if _n<=`nLOOP_T'
										egen tEMp_tREAt = mean(tEMp_tREAt_tEMp), by(`i')
										replace tEMp_tREAt = 0 if tEMp_tREAt!=. & tEMp_pOSt==0
									}
									else if "`stratify'"=="" & "`idcluster'"==""{
										* sample `nLOOP' units with replacement
										unique `i'
										local expand_numb = min(ceil(`nLOOP'/r(sum)),ceil(`nLOOP'/r(unique)))
										expand `expand_numb'
										bysort `i' `t' : gen tEMp_bSAMple_id1 = _n
										egen tEMp_bSAMple_id2 = group(`i' tEMp_bSAMple_id1)
										drop `i'
										bsample `nLOOP', cluster(tEMp_bSAMple_id2) idcluster(`i')

										* randomly pick `nLOOP' units and assign treatment to `nLOOP_T' of them
										egen tEMp_iUNIT_minT = min(`t') if tEMp_pOSt==1, by(`i')
										gen tEMp_rAndom2 = runiform() if `t'==tEMp_iUNIT_minT
										sort tEMp_rAndom2
										gen tEMp_tREAt_tEMp = 0 if _n<=`nLOOP'
										replace tEMp_tREAt_tEMp = 1 if _n<=`nLOOP_T'
										egen tEMp_tREAt = mean(tEMp_tREAt_tEMp), by(`i')
										replace tEMp_tREAt = 0 if tEMp_tREAt!=. & tEMp_pOSt==0
									}		
									else if "`stratify'"=="" & "`idcluster'"!="" {
									
										* sample `nLOOP' clusters with replacement
										preserve
										keep `idcluster'
										duplicates drop
										local expand_numb = ceil(`nLOOP'/_N)
										expand `expand_numb'
										bsample `nLOOP'
										gen clID_bsample = _n
										tempfile bsample_output_clusters
										save "`bsample_output_clusters'"
										restore
										joinby `idcluster' using "`bsample_output_clusters'"
										drop `idcluster'
										rename clID_bsample `idcluster'

										* assign treatment at the cluster level
										egen tEMp_iCL_minT = min(`t') if tEMp_pOSt==1, by(`idcluster')
										egen tEMp_tag_CLUSTER = tag(`idcluster') if `t'==tEMp_iCL_minT
										gen tEMp_rAndom2 = runiform() 
										gsort -tEMp_tag_CLUSTER tEMp_rAndom2
										gen tEMp_CLtREAt_temp = 0 if _n<=`nLOOP' & tEMp_tag_CLUSTER==1
										replace tEMp_CLtREAt_temp = 1 if _n<=`nLOOP_T' & tEMp_tag_CLUSTER==1
										egen tEMp_CLtREAt = mean(tEMp_CLtREAt_temp), by(`idcluster')
										keep if tEMp_CLtREAt!=.
										
										* reindex unit identifiers
										egen tEMp_uNIT_id_NEW = group(`idcluster' `i')
										drop `i'
										rename tEMp_uNIT_id_NEW `i'
								
										* assign cluster-specific treatment intensities
										egen tEMp_CLtREAt_P_temp1 = fill(`pcluster' `pcluster')
										replace tEMp_CLtREAt_P_temp1 = . if tEMp_tag_CLUSTER!=1
										egen tEMp_CLtREAt_P_temp2 = mean(tEMp_CLtREAt_P_temp1), by(`idcluster')
										gen tEMp_CLtREAt_P = tEMp_CLtREAt*tEMp_CLtREAt_P_temp2
										assert tEMp_CLtREAt_P==0 if tEMp_CLtREAt==0
										assert tEMp_CLtREAt_P>0 & tEMp_CLtREAt_P<=1 if tEMp_CLtREAt==1
									
										* sample `sizecluster' units with replacement, within each cluster
										if "`sizecluster'"!="" {
											egen tEMp_iUNIT_minT = min(`t') if tEMp_pOSt==1, by(`i')
											gen tEMp_iUNIT_minT_temp = `t'==tEMp_iUNIT_minT
											by `idcluster' tEMp_iUNIT_minT_temp, sort : gen tEMp_cl_size_preBS_temp = _N
											replace tEMp_cl_size_preBS_temp = . if tEMp_iUNIT_minT_temp==0
											egen tEMp_cl_size_preBS = max(tEMp_cl_size_preBS_temp), by(`idcluster') 
											gen tEMp_expand_numb = ceil(`sizecluster'/tEMp_cl_size_preBS)
											expand tEMp_expand_numb
											bysort `idcluster' `i' `t' : gen tEMp_bSAMple_id1 = _n
											egen tEMp_bSAMple_id2 = group(`idcluster' `i' tEMp_bSAMple_id1)
											drop `i'
											bsample `sizecluster', strata(`idcluster') cluster(tEMp_bSAMple_id2) idcluster(`i')
											by `idcluster' tEMp_iUNIT_minT_temp, sort : gen tEMp_cl_size_postBS_temp = _N
											replace tEMp_cl_size_postBS_temp = . if tEMp_iUNIT_minT_temp==0
											egen tEMp_cl_size_postBS = max(tEMp_cl_size_postBS_temp), by(`idcluster') 
											assert tEMp_cl_size_postBS==`sizecluster'									
										}
										
										* randomize at the cluster level
										egen tEMp_iUNIT_minT2 = min(`t') if tEMp_pOSt==1, by(`i')
										gen tEMp_rAndom3 = runiform() if `t'==tEMp_iUNIT_minT2
										by `idcluster' (tEMp_rAndom3), sort : gen tEMp_uNIT_rank = _n
										egen tEMp_uNIT_rank_MAX = max(tEMp_uNIT_rank) if `t'==tEMp_iUNIT_minT2, by(`idcluster')
										gen tEMp_uNIT_rank_MAXT = tEMp_uNIT_rank_MAX*tEMp_CLtREAt_P
										gen tEMp_tREAt_tEMp = tEMp_uNIT_rank<=round(tEMp_uNIT_rank_MAXT) & `t'==tEMp_iUNIT_minT2
										egen tEMp_tREAt = max(tEMp_tREAt_tEMp), by(`i')
										replace tEMp_tREAt = 0 if tEMp_tREAt!=. & tEMp_pOSt==0
									}
									capture assert tEMp_tREAt!=.
										local rc = _rc
										if `rc' {
											noisily display "{err}Error: Option bootstrap causing bsample to break for some reason... "
											use "`m_dta_before_sims'", clear	
											exit `rc'
										}
									assert tEMp_tREAt==0 | tEMp_tREAt==1
								}
									
								* add treatment effects of `mdeLOOP' for treated units only
								replace `y' = `y' + `mdeLOOP' if tEMp_tREAt==1
								sort `i'

								* collapse to cross-section if option collapse specified
								if "`collapse'"=="collapse" {
									collapse (mean) `y' tEMp_tREAt `controls' `wtvar', by(`i' tEMp_pOSt `absorb' `abs_fvars' `cl_varlist') fast
									unique `i' tEMp_pOSt
									capture assert (r(sum)==_N) | (r(unique)==_N)
										local rc = _rc
										if `rc' & "`absorb'"!="" { 
											noisily display "{err}Error: `i' and POST dummy not unique after collapsing data; to use collapse option, "
											noisily display "{err}       adjust absorb() option to include only fixed effects that are unique by `i' "
											use "`m_dta_before_sims'", clear	
											exit `rc'
										}									
										else if `rc' & "`abs_fvars'"!="" { 
											noisily display "{err}Error: `i' and POST dummy not unique after collapsing data; to use collapse option, "
											noisily display "{err}       adjust absorbfactor() option to include only fixed effects that are unique by `i' "
											use "`m_dta_before_sims'", clear	
											exit `rc'
										}									
										else if `rc' & "`cl_varlist'"!="" { 
											noisily display "{err}Error: `i' and POST dummy not unique after collapsing data; to use collapse option, "
											noisily display "{err}       adjust vce() option to cluster by variables that are unique by `i' "
											use "`m_dta_before_sims'", clear	
											exit `rc'
										}									
										else if `rc' { 
											noisily display "{err}Error using collapse option: `i' and POST dummy not unique after collapsing data "
											use "`m_dta_before_sims'", clear	
											exit `rc'
										}									
								}

								* estimate regression
								if "`weight'"=="" {
									capture reghdfe `y' tEMp_tREAt tEMp_pOSt `controls', absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'
										local rc = _rc
										if `rc' { 
											noisily display "{err}Error using reghdfe: "
											tempfile reghdfe_error
											save "`reghdfe_error'"
											use "`m_dta_before_sims'", clear
											preserve
											use "`reghdfe_error'", clear
											noisily reghdfe `y' tEMp_tREAt tEMp_pOSt `controls', absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'
											restore
										}
								}
								else {
									capture reghdfe `y' tEMp_tREAt tEMp_pOSt `controls' [`weight'], absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'								
										local rc = _rc
										if `rc' { 
											noisily display "{err}Error using reghdfe: "
											tempfile reghdfe_error
											save "`reghdfe_error'"
											use "`m_dta_before_sims'", clear
											preserve
											use "`reghdfe_error'", clear
											noisily reghdfe `y' tEMp_tREAt tEMp_pOSt `controls' [`weight'], absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'								
											restore
										}
								}
				
								* break if treatment effect or outcome variable is collinear with controls or fixed effects
								capture assert (_se[tEMp_tREAt]==0)==0
									local rc = _rc
									if `rc' & "`collapse'"=="collapse" {
										noisily display "{err}Error: Treatment effect (or outcome variable) is collinear with either fixed effects "
										noisily display "{err}       or controls. Collapsed DD model cannot include any cross-sectional fixed effects"
										noisily display "{err}       that are interacted with a time-varying component. "
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}
									else if `rc' & "`collapse'"=="" {
										noisily display "{err}Error: Treatment effect (or outcome variable) is collinear with either fixed effects "
										noisily display "{err}       or controls. DD model cannot include BOTH cross-sectional fixed effects "
										noisily display "{err}       interacted with a time-varying component AND time period fixed effects. "						
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}

								* determine if null hypothesis was rejected
								if "`onesided'"=="" {
									local pvalLOOP = 2*ttail(e(df_r),abs(_b[tEMp_tREAt]/_se[tEMp_tREAt])) // <-- two-sided p-value 
								}
								else if "`onesided'"=="onesided" & sign(_b[tEMp_tREAt])==sign(`mdeLOOP') {
									local pvalLOOP = ttail(e(df_r),abs(_b[tEMp_tREAt]/_se[tEMp_tREAt]))    // <-- one-sided p-value 
								}
								else if "`onesided'"=="onesided" & sign(_b[tEMp_tREAt])!=sign(`mdeLOOP') {
									local pvalLOOP = 1  // <-- one-sided p-value with opposite sign (cannot reject H0)
								}
								
								use `m_dta_during_sims', clear

								* store whether null hypothesis was rejected for this simulation
								if `pvalLOOP'<=`alpha' {
									replace SIMreject = 1 if SIMid==`nsimLOOP'
								}
								else {
									replace SIMreject = 0 if SIMid==`nsimLOOP'
								}
								capture assert `pvalLOOP'>=0 & `pvalLOOP'<=1
									local rc = _rc
									if `rc' {
										noisily display "{err}Error: `pvalLOOP' not a valid p-value"
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}

								save `m_dta_during_sims', replace

							}
							
							* store rejection rates for this set of parameters
							replace nOuT = `nLOOP' if SIMid==`indexOuT'
							replace pOuT = `pLOOP' if SIMid==`indexOuT'
							replace mdeOuT = `mdeLOOP' if SIMid==`indexOuT'
							replace preOuT = `preLOOP' if SIMid==`indexOuT'
							replace postOuT = `postLOOP' if SIMid==`indexOuT'
							sum SIMreject
							replace powerOuT = r(mean) if SIMid==`indexOuT'
							local tEMp_mEAn = string(`r(mean)',"%9.3f")
				
							* reset for next set of simulation 
							replace SIMreject = .
							local indexOuT = `indexOuT'+1
							save `m_dta_during_sims', replace
						
							* intermediate output
							foreach LOOP_var in n p mde post pre {
								local `LOOP_var'LOOP_sp = `len_MAX_`LOOP_var'' - length("``LOOP_var'LOOP'")
								if ``LOOP_var'LOOP_sp'==0 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'"
								}
								else if ``LOOP_var'LOOP_sp'==1 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP' "
								}
								else if ``LOOP_var'LOOP_sp'==2 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'  "
								}
								else if ``LOOP_var'LOOP_sp'==3 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'   "
								}
								else if ``LOOP_var'LOOP_sp'==4 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'    "
								}
								else if ``LOOP_var'LOOP_sp'==5 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'     "
								}
								else if ``LOOP_var'LOOP_sp'==6 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'      "
								}
								else {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'       "
								}
							}
							
							noisily display "{inp}Completed:   n=`nLOOP_disp'   p=`pLOOP_disp'   mde=`mdeLOOP_disp'   pre=`preLOOP_disp'   post=`postLOOP_disp'   power= `tEMp_mEAn'"
							
						}
					}	
				}					
			}
		}	
	}
}


// 5D. model == ANCOVA
else if "`model'"=="ANCOVA" {
	quietly {
		
		* create locals for spacing of intermediate output
		foreach len_MAX in n p mde post pre {
			local len_MAX_`len_MAX' = 1
			foreach len_MAX_loop in ``len_MAX''{
				local len_MAX_`len_MAX' = max(`len_MAX_`len_MAX'',length("`len_MAX_loop'"))
			}
		}
		
		* restrict time periods if option tstart() is toggled
		if "`tstart'"!="" {
			capture keep if `t'>=real(word("`tstart'",1))
			capture keep if `t'<=real(word("`tstart'",2))+`preMAX'+`postMAX'-1
		}
		sum `t'
		local tperiodMAX = r(max)

		* create enough observations to store all simulation results
		local newN = max(_N,`nsim')
		set obs `newN'

		* create variables to index simulations and store a rejection dummy
		gen SIMid = _n
		replace SIMid = . if SIMid>`nsim'
		gen SIMreject = .
		
		* create empty variables to store results
		gen double nOuT = .
		gen double pOuT = .
		gen double mdeOuT = .
		gen double preOuT = .
		gen double postOuT = .
		gen double powerOuT = .
		local indexOuT = 1

		* create temp file to store results
		tempfile m_dta_during_sims
		quietly save `m_dta_during_sims', replace

		* loop over `n', `p', `mde', `pre', and `post', `nsim' times each
		foreach nLOOP in  `n' {	
			foreach pLOOP in `p' {
				local nLOOP_T = round(`nLOOP'*`pLOOP')
				foreach mdeLOOP in `mde' {
					foreach preLOOP in `pre' {
						foreach postLOOP in `post' {
							forvalues nsimLOOP = 1/`nsim' {
								
								use `m_dta_during_sims', clear
							
								* randomly pick time period to start DD RCT								
								gen tEMp_rAndom1 = runiform() if `t'+`preLOOP'+`postLOOP'-1<=`tperiodMAX'
								sort tEMp_rAndom1
								local tSTART_LOOP =`t'[1]
								local tEND_LOOP = `tSTART_LOOP'+`preLOOP'+`postLOOP'-1
								keep if inrange(`t',`tSTART_LOOP',`tEND_LOOP') 

								* generate post-treatment indicator
								local preEND_LOOP = `tSTART_LOOP'+`preLOOP'-1
								local postSTART_LOOP = `preEND_LOOP'+1
								gen tEMp_pOSt = `t'>=`postSTART_LOOP'
								egen tEMp_pOSt_min = min(tEMp_pOSt), by(`i')
								egen tEMp_pOSt_max = max(tEMp_pOSt), by(`i')
								keep if tEMp_pOSt_max>tEMp_pOSt_min

								* if drawing units WITHOUT replacement (option bootstrap is not specified)
								if "`bootstrap'"=="" {
									* confirm that randomly selected time periods have enough observations
									if "`stratify'"!="" {
										forvalues stratLOOP = 1/`levelsSTRAT' {
											unique `i' if tEMp_grpSTRAT==`stratLOOP' & tEMp_pOSt==0
											capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
												local rc = _rc
												if `rc' & `preLOOP'>1 {
													noisily display "{err}Error: Time periods `t'=`tSTART_LOOP' thru `t'=`preEND_LOOP' do not include enough `i' units "
													noisily display "{err}       to randomize across `nLOOP' units in each stratified randomization cell "
													use "`m_dta_before_sims'", clear	
													exit `rc'
												}								
												else if `rc' {
													noisily display "{err}Error: Time period `t'=`preEND_LOOP' does not include enough `i' units "
													noisily display "{err}       to randomize across `nLOOP' units in each stratified randomization cell "
													use "`m_dta_before_sims'", clear	
													exit `rc'
												}								
											unique `i' if tEMp_grpSTRAT==`stratLOOP' & tEMp_pOSt==1
											capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
												local rc = _rc
												if `rc' & `postLOOP'>1 {
													noisily display "{err}Error: Time periods `t'=`postSTART_LOOP' thru `t'=`tEND_LOOP' do not include enough `i' units "
													noisily display "{err}       to randomize across `nLOOP' units in each stratified randomization cell "
													use "`m_dta_before_sims'", clear	
													exit `rc'
												}								
												else if `rc' {
													noisily display "{err}Error: Time period `t'=`postSTART_LOOP' does not include enough `i' units "
													noisily display "{err}       to randomize across `nLOOP' units in each stratified randomization cell "
													use "`m_dta_before_sims'", clear	
													exit `rc'
												}								
										}
									}
									else if "`stratify'"=="" & "`idcluster'"=="" {
										unique `i' if tEMp_pOSt==0
										capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
											local rc = _rc
											if `rc' & `preLOOP'>1 {
												noisily display "{err}Error: Time periods `t'=`tSTART_LOOP' thru `t'=`preEND_LOOP' do not include "
												noisily display "{err}       enough `i' units to randomize across `nLOOP' units "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
											else if `rc' {
												noisily display "{err}Error: Time period `t'=`preEND_LOOP' does not include "
												noisily display "{err}       enough `i' units to randomize across `nLOOP' units "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
										unique `i' if tEMp_pOSt==1
										capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
											local rc = _rc
											if `rc' & `postLOOP'>1 {
												noisily display "{err}Error: Time periods `t'=`postSTART_LOOP' thru `t'=`tEND_LOOP' do not include "
												noisily display "{err}       enough `i' units to randomize across `nLOOP' units "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
											else if `rc' {
												noisily display "{err}Error: Time period `t'=`postSTART_LOOP' does not include "
												noisily display "{err}       enough `i' units to randomize across `nLOOP' units "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
									}
									else if "`stratify'"=="" & "`idcluster'"!="" {
										unique `idcluster' if tEMp_pOSt==0
										capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
											local rc = _rc
											if `rc' & `preLOOP'>1 {
												noisily display "{err}Error: Time periods `t'=`tSTART_LOOP' thru `t'=`preEND_LOOP' do not include "
												noisily display "{err}       enough `idcluster' clusters to randomize across `nLOOP' clusters "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
											else if `rc' {
												noisily display "{err}Error: Time period `t'=`preEND_LOOP' does not include "
												noisily display "{err}       enough `idcluster' clusters to randomize across `nLOOP' clusters "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
										unique `idcluster' if tEMp_pOSt==1
										capture assert `nLOOP'<=r(sum) & `nLOOP'<=r(unique)
											local rc = _rc
											if `rc' & `postLOOP'>1 {
												noisily display "{err}Error: Time periods `t'=`postSTART_LOOP' thru `t'=`tEND_LOOP' do not include "
												noisily display "{err}       enough `idcluster' clusters to randomize across `nLOOP' clusters "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}								
											else if `rc' {
												noisily display "{err}Error: Time period `t'=`postSTART_LOOP' does not include "
												noisily display "{err}       enough `idcluster' clusters to randomize across `nLOOP' clusters "
												use "`m_dta_before_sims'", clear	
												exit `rc'
											}
									}

									* generate pre-treatment average, and drop pre-treatment periods
									egen tEMp_tEMp_pRE_AVG = mean(`y') if tEMp_pOSt==0, by(`i')
									egen tEMp_pRE_AVG = mean(tEMp_tEMp_pRE_AVG), by(`i')
									drop if tEMp_pOSt==0

									* randomly pick `nLOOP' units and assign treatment to `nLOOP_T' of them
									if "`stratify'"!="" & "`idcluster'"=="" {
										egen tEMp_iUNIT_minT = min(`t'), by(`i')
										gen tEMp_rAndom2 = runiform()+tEMp_grpSTRAT if `t'==tEMp_iUNIT_minT
										by tEMp_grpSTRAT (tEMp_rAndom2), sort : gen tEMp_tREAt_tEMp = 0 if _n<=`nLOOP'				
										by tEMp_grpSTRAT (tEMp_rAndom2), sort : replace tEMp_tREAt_tEMp = 1 if _n<=`nLOOP_T'
										egen tEMp_tREAt = mean(tEMp_tREAt_tEMp), by(`i')
									}
									else if "`stratify'"=="" & "`idcluster'"=="" {
										egen tEMp_iUNIT_minT = min(`t'), by(`i')
										gen tEMp_rAndom2 = runiform() if `t'==tEMp_iUNIT_minT
										sort tEMp_rAndom2
										gen tEMp_tREAt_tEMp = 0 if _n<=`nLOOP'
										replace tEMp_tREAt_tEMp = 1 if _n<=`nLOOP_T'
										egen tEMp_tREAt = mean(tEMp_tREAt_tEMp), by(`i')
									}
									else if "`stratify'"=="" & "`idcluster'"!="" {
									
										* assign treatment at the cluster level
										egen tEMp_iCL_minT = min(`t'), by(`idcluster')
										egen tEMp_tag_CLUSTER = tag(`idcluster') if `t'==tEMp_iCL_minT
										gen tEMp_rAndom2 = runiform() 
										gsort -tEMp_tag_CLUSTER tEMp_rAndom2
										gen tEMp_CLtREAt_temp = 0 if _n<=`nLOOP' & tEMp_tag_CLUSTER==1
										replace tEMp_CLtREAt_temp = 1 if _n<=`nLOOP_T' & tEMp_tag_CLUSTER==1
										egen tEMp_CLtREAt = mean(tEMp_CLtREAt_temp), by(`idcluster')
										keep if tEMp_CLtREAt!=.
									
										* assign cluster-specific treatment intensities
										egen tEMp_CLtREAt_P_temp1 = fill(`pcluster' `pcluster')
										replace tEMp_CLtREAt_P_temp1 = . if tEMp_tag_CLUSTER!=1
										egen tEMp_CLtREAt_P_temp2 = mean(tEMp_CLtREAt_P_temp1), by(`idcluster')
										gen tEMp_CLtREAt_P = tEMp_CLtREAt*tEMp_CLtREAt_P_temp2
										assert tEMp_CLtREAt_P==0 if tEMp_CLtREAt==0
										assert tEMp_CLtREAt_P>0 & tEMp_CLtREAt_P<=1 if tEMp_CLtREAt==1
									
										* set number of units in each cluster, confirm sufficient size
										if "`sizecluster'"!="" {
											levelsof `idcluster', local(levs)
											foreach grpCLUST_LOOP in `levs' {
												unique `i' if `idcluster'==`grpCLUST_LOOP'
												capture assert `sizecluster'<=r(sum) & `sizecluster'<=r(unique)
													local rc = _rc
													if `rc' {
														noisily display "{err}Error: Cluster `idcluster'=`grpCLUST_LOOP' does not include"
														noisily display "{err}       `sizecluster' units; use option bootstrap "
														use "`m_dta_before_sims'", clear	
														exit `rc'
													}								
											}
											egen tEMp_iUNIT_minT = min(`t'), by(`i')
											gen tEMp_rAndom3 = runiform() if `t'==tEMp_iUNIT_minT
											by `idcluster' (tEMp_rAndom3), sort : gen tEMp_todrop1 = _n>`sizecluster' & `t'==tEMp_iUNIT_minT
											egen tEMp_todrop2 = max(tEMp_todrop1), by(`i')
											drop if tEMp_todrop2==1
										}
										
										* randomize at the unit level, within clusters
										egen tEMp_iUNIT_minT2 = min(`t'), by(`i')
										gen tEMp_rAndom4 = runiform() if `t'==tEMp_iUNIT_minT2
										by `idcluster' (tEMp_rAndom4), sort : gen tEMp_uNIT_rank = _n
										egen tEMp_uNIT_rank_MAX = max(tEMp_uNIT_rank) if `t'==tEMp_iUNIT_minT2, by(`idcluster')
										gen tEMp_uNIT_rank_MAXT = tEMp_uNIT_rank_MAX*tEMp_CLtREAt_P
										gen tEMp_tREAt_tEMp = tEMp_uNIT_rank<=round(tEMp_uNIT_rank_MAXT) & `t'==tEMp_iUNIT_minT2
										egen tEMp_tREAt = max(tEMp_tREAt_tEMp), by(`i')
									}
									
									keep if tEMp_tREAt!=.
									assert tEMp_tREAt==0 | tEMp_tREAt==1
								}	

								* if drawing units WITH replacement (option bootstrap is specified)
								if "`bootstrap'"!="" {
								
									* generate pre-treatment average, and drop pre-treatment periods
									egen tEMp_tEMp_pRE_AVG = mean(`y') if tEMp_pOSt==0, by(`i')
									egen tEMp_pRE_AVG = mean(tEMp_tEMp_pRE_AVG), by(`i')
									drop if tEMp_pOSt==0

									if "`stratify'"!="" & "`idcluster'"=="" {
										* sample `nLOOP' units with replacement
										sum tEMp_grpSTRAT
										local levelsSTRAT = r(max)
										local expand_numb = 1
										forvalues stratLOOP = 1/`levelsSTRAT' {
											quietly unique `i' if tEMp_grpSTRAT==`stratLOOP'
											local expand_numb = max(`expand_numb',ceil(`nLOOP'/r(sum)),ceil(`nLOOP'/r(unique)))
										}
										expand `expand_numb'
										bysort `i' `t' : gen tEMp_bSAMple_id1 = _n
										egen tEMp_bSAMple_id2 = group(`i' tEMp_bSAMple_id1)
										drop `i'
										bsample `nLOOP', strata(tEMp_grpSTRAT) cluster(tEMp_bSAMple_id2) idcluster(`i')
										
										* randomly pick `nLOOP' units and assign treatment to `nLOOP_T' of them
										egen tEMp_iUNIT_minT = min(`t'), by(`i')
										gen tEMp_rAndom2 = runiform()+tEMp_grpSTRAT if `t'==tEMp_iUNIT_minT
										by tEMp_grpSTRAT (tEMp_rAndom2), sort : gen tEMp_tREAt_tEMp = 0 if _n<=`nLOOP'				
										by tEMp_grpSTRAT (tEMp_rAndom2), sort : replace tEMp_tREAt_tEMp = 1 if _n<=`nLOOP_T'
										egen tEMp_tREAt = mean(tEMp_tREAt_tEMp), by(`i')
									}
									else if "`stratify'"=="" & "`idcluster'"=="" {
										* sample `nLOOP' units with replacement
										unique `i'
										local expand_numb = min(ceil(`nLOOP'/r(sum)),ceil(`nLOOP'/r(unique)))
										expand `expand_numb'
										bysort `i' `t' : gen tEMp_bSAMple_id1 = _n
										egen tEMp_bSAMple_id2 = group(`i' tEMp_bSAMple_id1)
										drop `i'
										bsample `nLOOP', cluster(tEMp_bSAMple_id2) idcluster(`i')
										
										* randomly pick `nLOOP' units and assign treatment to `nLOOP_T' of them
										egen tEMp_iUNIT_minT = min(`t'), by(`i')
										gen tEMp_rAndom2 = runiform() if `t'==tEMp_iUNIT_minT
										sort tEMp_rAndom2
										gen tEMp_tREAt_tEMp = 0 if _n<=`nLOOP'
										replace tEMp_tREAt_tEMp = 1 if _n<=`nLOOP_T'
										egen tEMp_tREAt = mean(tEMp_tREAt_tEMp), by(`i')
									}
									else if "`stratify'"=="" & "`idcluster'"!="" {

										* sample `nLOOP' clusters with replacement
										preserve
										keep `idcluster'
										duplicates drop
										local expand_numb = ceil(`nLOOP'/_N)
										expand `expand_numb'
										bsample `nLOOP'
										gen clID_bsample = _n
										tempfile bsample_output_clusters
										save "`bsample_output_clusters'"
										restore
										joinby `idcluster' using "`bsample_output_clusters'"
										drop `idcluster'
										rename clID_bsample `idcluster'

										* assign treatment at the cluster level
										egen tEMp_iCL_minT = min(`t'), by(`idcluster')
										egen tEMp_tag_CLUSTER = tag(`idcluster') if `t'==tEMp_iCL_minT
										gen tEMp_rAndom2 = runiform() 
										gsort -tEMp_tag_CLUSTER tEMp_rAndom2
										gen tEMp_CLtREAt_temp = 0 if _n<=`nLOOP' & tEMp_tag_CLUSTER==1
										replace tEMp_CLtREAt_temp = 1 if _n<=`nLOOP_T' & tEMp_tag_CLUSTER==1
										egen tEMp_CLtREAt = mean(tEMp_CLtREAt_temp), by(`idcluster')
										keep if tEMp_CLtREAt!=.

										* reindex unit identifiers
										egen tEMp_uNIT_id_NEW = group(`idcluster' `i')
										drop `i'
										rename tEMp_uNIT_id_NEW `i'
									
										* assign cluster-specific treatment intensities
										egen tEMp_CLtREAt_P_temp1 = fill(`pcluster' `pcluster')
										replace tEMp_CLtREAt_P_temp1 = . if tEMp_tag_CLUSTER!=1
										egen tEMp_CLtREAt_P_temp2 = mean(tEMp_CLtREAt_P_temp1), by(`idcluster')
										gen tEMp_CLtREAt_P = tEMp_CLtREAt*tEMp_CLtREAt_P_temp2
										assert tEMp_CLtREAt_P==0 if tEMp_CLtREAt==0
										assert tEMp_CLtREAt_P>0 & tEMp_CLtREAt_P<=1 if tEMp_CLtREAt==1
									
										* sample `sizecluster' units with replacement, within each cluster
										if "`sizecluster'"!="" {
											egen tEMp_iUNIT_minT = min(`t'), by(`i')
											gen tEMp_iUNIT_minT_temp = `t'==tEMp_iUNIT_minT
											by `idcluster' tEMp_iUNIT_minT_temp, sort : gen tEMp_cl_size_preBS_temp = _N
											replace tEMp_cl_size_preBS_temp = . if tEMp_iUNIT_minT_temp==0
											egen tEMp_cl_size_preBS = max(tEMp_cl_size_preBS_temp), by(`idcluster') 
											gen tEMp_expand_numb = ceil(`sizecluster'/tEMp_cl_size_preBS)
											expand tEMp_expand_numb
											bysort `idcluster' `i' `t' : gen tEMp_bSAMple_id1 = _n
											egen tEMp_bSAMple_id2 = group(`idcluster' `i' tEMp_bSAMple_id1)
											drop `i'
											bsample `sizecluster', strata(`idcluster') cluster(tEMp_bSAMple_id2) idcluster(`i')
											by `idcluster' tEMp_iUNIT_minT_temp, sort : gen tEMp_cl_size_postBS_temp = _N
											replace tEMp_cl_size_postBS_temp = . if tEMp_iUNIT_minT_temp==0
											egen tEMp_cl_size_postBS = max(tEMp_cl_size_postBS_temp), by(`idcluster') 
											assert tEMp_cl_size_postBS==`sizecluster'									
										}
										
										* randomize at the unit level, within clusters
										egen tEMp_iUNIT_minT2 = min(`t'), by(`i')
										gen tEMp_rAndom3 = runiform() if `t'==tEMp_iUNIT_minT2
										by `idcluster' (tEMp_rAndom3), sort : gen tEMp_uNIT_rank = _n
										egen tEMp_uNIT_rank_MAX = max(tEMp_uNIT_rank) if `t'==tEMp_iUNIT_minT2, by(`idcluster')
										gen tEMp_uNIT_rank_MAXT = tEMp_uNIT_rank_MAX*tEMp_CLtREAt_P
										gen tEMp_tREAt_tEMp = tEMp_uNIT_rank<=round(tEMp_uNIT_rank_MAXT) & `t'==tEMp_iUNIT_minT2
										egen tEMp_tREAt = max(tEMp_tREAt_tEMp), by(`i')
									}
									capture assert tEMp_tREAt!=.
										local rc = _rc
										if `rc' {
											noisily display "{err}Error: Option bootstrap causing bsample to break for some reason... "
											use "`m_dta_before_sims'", clear	
											exit `rc'
										}								
									assert tEMp_tREAt==0 | tEMp_tREAt==1
								}

								* add treatment effects of `mdeLOOP' for treated units only
								replace `y' = `y' + `mdeLOOP' if tEMp_tREAt==1
								
								* collapse to cross-section if option collapse specified
								if "`collapse'"=="collapse" {
									collapse (mean) `y' tEMp_tREAt tEMp_pRE_AVG `controls' `wtvar', by(`i' `absorb' `abs_fvars' `cl_varlist') fast
									unique `i'
									capture assert (r(sum)==_N) | (r(unique)==_N)
										local rc = _rc
										if `rc' & "`absorb'"!="" { 
											noisily display "{err}Error: `i' not unique after collapsing data; to use collapse option, adjust "
											noisily display "{err}        absorb() option to include only fixed effects that are unique by `i' "
											use "`m_dta_before_sims'", clear	
											exit `rc'
										}									
										else if `rc' & "`abs_fvars'"!="" { 
											noisily display "{err}Error: `i' not unique after collapsing data; to use collapse option, adjust "
											noisily display "{err}        absorbfactor() option to include only fixed effects that are unique by `i' "
											use "`m_dta_before_sims'", clear	
											exit `rc'
										}									
										else if `rc' & "`cl_varlist'"!="" { 
											noisily display "{err}Error: `i' not unique after collapsing data; to use collapse option, "
											noisily display "{err}       adjust vce() option to cluster by variables that are unique by `i' "
											use "`m_dta_before_sims'", clear	
											exit `rc'
										}									
										else if `rc' { 
											noisily display "{err}Error using collapse option: `i' not unique after collapsing data "
											use "`m_dta_before_sims'", clear	
											exit `rc'
										}									
								}

								* estimate regression
								if "`weight'"=="" {
									capture reghdfe `y' tEMp_tREAt tEMp_pRE_AVG `controls', absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'
										local rc = _rc
										if `rc' { 
											noisily display "{err}Error using reghdfe: "
											tempfile reghdfe_error
											save "`reghdfe_error'"
											use "`m_dta_before_sims'", clear
											preserve
											use "`reghdfe_error'", clear
											noisily reghdfe `y' tEMp_tREAt tEMp_pRE_AVG `controls', absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'								
											restore
										}
								}
								else {
									capture reghdfe `y' tEMp_tREAt tEMp_pRE_AVG `controls' [`weight'], absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'								
										local rc = _rc
										if `rc' { 
											noisily display "{err}Error using reghdfe: "
											tempfile reghdfe_error
											save "`reghdfe_error'"
											use "`m_dta_before_sims'", clear
											preserve
											use "`reghdfe_error'", clear
											noisily reghdfe `y' tEMp_tREAt tEMp_pRE_AVG `controls' [`weight'], absorb(`absorb' `absorbfactor') vce(`vce') `reghdfeoptions'								
											restore
										}
								}

								* break if treatment effect or outcome variable is collinear with controls or fixed effects
								capture assert (_se[tEMp_tREAt]==0)==0
									local rc = _rc
									if `rc' & "`collapse'"=="collapse" {
										noisily display "{err}Error: Treatment effect (or outcome variable) is collinear with either fixed effects "
										noisily display "{err}       or controls. Collapsed ANCOVA model cannot include any fixed effects other than"
										noisily display "{err}       a cross-sectional group variable within which unit of treatment `i' is nested.  "
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}
									else if `rc' & "`collapse'"=="" {
										noisily display "{err}Error: Treatment effect (or outcome variable) is collinear with either fixed effects "
										noisily display "{err}       or controls. ANCOVA model cannot include any cross-sectional fixed effects "
										noisily display "{err}       other than a group variable within which the treatment unit (`i') is nested.  "						
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}

								* determine if null hypothesis was rejected
								if "`onesided'"=="" {
									local pvalLOOP = 2*ttail(e(df_r),abs(_b[tEMp_tREAt]/_se[tEMp_tREAt])) // <-- two-sided p-value 
								}
								else if "`onesided'"=="onesided" & sign(_b[tEMp_tREAt])==sign(`mdeLOOP') {
									local pvalLOOP = ttail(e(df_r),abs(_b[tEMp_tREAt]/_se[tEMp_tREAt]))    // <-- one-sided p-value 
								}
								else if "`onesided'"=="onesided" & sign(_b[tEMp_tREAt])!=sign(`mdeLOOP') {
									local pvalLOOP = 1  // <-- one-sided p-value with opposite sign (cannot reject H0)
								}
									
								use `m_dta_during_sims', clear

								* store whether null hypothesis was rejected for this simulation
								if `pvalLOOP'<=`alpha' {
									replace SIMreject = 1 if SIMid==`nsimLOOP'
								}
								else {
									replace SIMreject = 0 if SIMid==`nsimLOOP'
								}
								capture assert `pvalLOOP'>=0 & `pvalLOOP'<=1
									local rc = _rc
									if `rc' {
										noisily display "{err}Error: `pvalLOOP' not a valid p-value"
										use "`m_dta_before_sims'", clear	
										exit `rc'
									}
		
								save `m_dta_during_sims', replace
					
							}
							
							* store rejection rates for this set of parameters
							replace nOuT = `nLOOP' if SIMid==`indexOuT'
							replace pOuT = `pLOOP' if SIMid==`indexOuT'
							replace mdeOuT = `mdeLOOP' if SIMid==`indexOuT'
							replace preOuT = `preLOOP' if SIMid==`indexOuT'
							replace postOuT = `postLOOP' if SIMid==`indexOuT'
							sum SIMreject
							replace powerOuT = r(mean) if SIMid==`indexOuT'
							local tEMp_mEAn = string(`r(mean)',"%9.3f")
				
							* reset for next set of simulation 
							replace SIMreject = .
							local indexOuT = `indexOuT'+1
							save `m_dta_during_sims', replace
						
							* intermediate output
							foreach LOOP_var in n p mde post pre {
								local `LOOP_var'LOOP_sp = `len_MAX_`LOOP_var'' - length("``LOOP_var'LOOP'")
								if ``LOOP_var'LOOP_sp'==0 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'"
								}
								else if ``LOOP_var'LOOP_sp'==1 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP' "
								}
								else if ``LOOP_var'LOOP_sp'==2 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'  "
								}
								else if ``LOOP_var'LOOP_sp'==3 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'   "
								}
								else if ``LOOP_var'LOOP_sp'==4 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'    "
								}
								else if ``LOOP_var'LOOP_sp'==5 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'     "
								}
								else if ``LOOP_var'LOOP_sp'==6 {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'      "
								}
								else {
									local `LOOP_var'LOOP_disp = "``LOOP_var'LOOP'       "
								}
							}
							
							noisily display "{inp}Completed:   n=`nLOOP_disp'   p=`pLOOP_disp'   mde=`mdeLOOP_disp'   pre=`preLOOP_disp'   post=`postLOOP_disp'   power= `tEMp_mEAn'"
							
						}
					}	
				}					
			}
		}	
	}
}


// 6. Store outputs
{
quietly {
	keep if powerOuT!=.
	keep *OuT
	foreach v of varlist *OuT {
		local v_new_name = subinstr("`v'","OuT","",1)
		rename `v' `v_new_name'
	}

	capture gen pre = 0
	capture gen post = 1
	
	gen outcome = "`y'"
	gen model = "`model'"
	gen unit = "`i'"
	replace unit = "_n" if unit=="i_fOr_OneshOt"
	gen time = "`t'"
	replace time = "" if time=="t_fOr_OneshOt"
	gen stratify = "`stratify'"
	gen idcluster = "`idcluster'"
	if "`sizecluster'"!="" {
		gen sizecluster = `sizecluster'
	}
	gen pcluster = "`pcluster'"
	gen controls = "`controls'"
	gen fixed_effects = "`absorb' `absorbfactor'"
	replace fixed_effects = "none" if fixed_effects=="ones_fOr_aBsOrB"
	replace fixed_effects = trim(itrim(subinstr(fixed_effects,"ones_fOr_aBsOrB","",1)))
	gen alpha = `alpha'
	gen onesided = "`onesided'"
	gen tstart ="`tstart'"
	gen std_errors = "`vce'"
	gen collapse = "`collapse'"
	gen bootstrap = "`bootstrap'"
	gen nsim = `nsim'
	gen ifs = "`if'"
	gen ins = "`in'"
	gen weight = "`weight'"
	gen reghdfe_options = "`reghdfeoptions'"
	gen dataset = "`master_fname'"

	foreach v of varlist * {
		capture assert mi(`v')
			local rc = _rc
			if !`rc' {
				drop `v'
			}
	}
}


// outsheet results
if "`append'"=="append" {
	tempfile outsheet_temp
	quietly save `outsheet_temp', replace
	quietly insheet using "`outfile'", clear comma double names
	capture tostring pcluster, replace // could be either numeric (1 value) or string (2 values with a space)
	capture replace pcluster = "" if pcluster=="."
	capture tostring tstart, replace  // could be either numeric (1 value) or string (2 values with a space)
	capture replace tstart = "" if tstart=="."
	quietly append using `outsheet_temp', force
	foreach v in n p mde pre post power outcome model unit time stratify controls idcluster sizecluster pcluster fixed_effects alpha onesided tstart std_errors collapse bootstrap nsim ifs ins weight reghdfe_options dataset {
		capture order `v', last
	}
	capture outsheet using "`outfile'", replace comma names
		local rc = _rc
		if `rc' {
			display "{err}Error in writing results to file `outfile' "
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
}
else {
	foreach v in n p mde pre post power outcome model unit time stratify controls idcluster sizecluster pcluster fixed_effects alpha onesided tstart std_errors collapse bootstrap nsim ifs ins weight reghdfe_options dataset {
		capture order `v', last
	}
	capture outsheet using "`outfile'", `replace' comma names
		local rc = _rc
		if `rc' {
			display "{err}Error in writing results to file `outfile' "
			use "`m_dta_before_sims'", clear	
			exit `rc'
		}
}
}


// 7. Reload master dataset and display final output
{
use "`m_dta_before_sims'", clear	

if substr("`outfile'",1,length("`c(pwd)'`c(dirsep)'"))=="`c(pwd)'`c(dirsep)'" {
	local outfile_disp = "`outfile'"
}
else {
	local outfile_disp = "`c(pwd)'`c(dirsep)'`outfile'"
}
di _n _n "{inp}Simulations complete! Results stored in `outfile_disp' "
}


end

*******************************************************************************************
*******************************************************************************************
