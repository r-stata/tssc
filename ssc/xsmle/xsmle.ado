* version 1.4.5 5jun2017
*! authors Federico Belotti, Gordon Hughes, Andrea Piano Mortari
*! see end of file for version comments

/***************************************************************************
** Stata program for ML estimation of balanced (and unbalanced through the prefix command -mi-) panel data spatial models
**
** Programmed by: Gordon Hughes, Department of Economics, University of Edinburgh, E-mail: g.a.hughes@ed.ac.uk
** 				  Federico Belotti, Centre for Economics and International Studies, University of Rome Tor Vergata, E-mail: f.belotti@gmail.com	
**				  Andrea Piano Mortari, Centre for Economics and International Studies, University of Rome Tor Vergata, E-mail: andreapm@gmail.com

** The likelihood mata functions are based upon Matlab code originally written by J Paul Elhorst and J.P. LeSage
** See: J.P. Elhorst (2009) 'Spatial panel data models' in M.M. Fischer & A.Getis (Eds),
** Handbook of Applied Spatial Analysis, pp. 377-407.

**************************************************************************/

program define xsmle, eclass prop(xt swml mi) sortpreserve byable(recall)
version 10

local vvcheck = max(10,c(stata_version))
if `vvcheck' < 11 local __fv
else local __fv "fv"

syntax varlist(numeric min=2 `__fv') [if] [in] [aweight iweight/] ///
										[, WMATrix(string) EMATrix(string) DMATrix(string) ///
							 			FE RE MODel(string) TYPE(string) EFFects VCEEffects(string) ///
										NOCONStant VCE(passthru) ROBust CLuster(passthru) Level(cilevel) ///
										CONSTRaints(numlist min=1) DLAG(string) HAUSMAN ///
										LNDETapprox LNDETITerations(integer 0) LNDETORDer(integer 0) /// This line not yet documented
										TECHnique(string) ITERate(integer 100) NOWARNing DIFFICULT NOLOG ///
				                        TRace GRADient SHOWSTEP HESSian SHOWTOLerance TOLerance(real 1e-6) ///
				                        LTOLerance(real 1e-7) NRTOLerance(real 1e-5) NONRTOLerance POSTSCORE POSTHESSian ///
							 			DURBIN(varlist numeric min=1 `__fv') FROM(string) ERRor(integer 1) *] 


local vvcheck = max(10,c(stata_version))
local vv : di "version " string(max(10,c(stata_version))) ", missing:"								
local _cmd_line "`0'"

*** First varlist parsing
	gettoken lhs rhs: varlist 
	local lhs_name "`lhs'"
	
if "`dlag'"!="" {
	local dlag_type `dlag'
	local dlag dlag
}
else local dlag_type 0


if "`effects'"!= "" local d_i_t_effects d_i_t_effects
else local d_i_t_effects

*** Parsing of spatial weight matrices 
ParseSpatMat, cwmat(`wmatrix') cemat(`ematrix') cdmat(`dmatrix')
if "`r(wmatrix)'"!="" {
	local wmatrix "`r(wmatrix)'"
	local _wmatspmatobj 0
}
else {
	local wmatrix "`r(o_wmatrix)'"
	local _wmatspmatobj "`r(_wmatspmatobj)'"
}

if "`r(ematrix)'"!="" {
	local ematrix "`r(ematrix)'"
	local _ematspmatobj 0
}
else {
	local ematrix "`r(o_ematrix)'"
	local _ematspmatobj "`r(_ematspmatobj)'"
}

if "`r(dmatrix)'"!="" {
	local dmatrix "`r(dmatrix)'"
	local _dmatspmatobj 0
}
else {
	local dmatrix "`r(o_dmatrix)'"
	local _dmatspmatobj "`r(_dmatspmatobj)'"
}

	

*** Default RE
if ("`fe'" == "" | "`re'" != "") local re "re"
if "`fe'" != "" {
	local effects 1
	if "`noconstant'"!="" {
    	display in yel "Warning: option -noconstant- is redundant in fixed-effects models"
  	}
	else local noconstant "noconstant"
}
if "`re'" != "" local effects 2
local lytransf=0
	
*** Parsing model
ParseMod modtype : `"`model'"'
if `effects'==1 {
	*** Parsing type
	if "`type'" != "" {
		gettoken type _leeyu: type, parse(",")
		ParseLY leeyu : `"`=regexr("`_leeyu'",",","")'"'
		*** Lee and Yu (2010) data transf?
		if "`leeyu'" != "" local lytransf=1
	}
}
else {
  	*** Parsing type
	if "`type'" != "" {
		gettoken type _leeyu: type, parse(",")
		if  "`_leeyu'" !="" {
			di as error "Lee and Yu (2010) transformation not allowed in random-effects models"
    		error 198 
		}
	}
}
ParseType efftype : `"`type'"'

*** lndet approximation (Pace and Barry, 1999)
if "`lndetapprox'"!= "" {
	
	local lndet 1
	
	if "`lndetiterations'"!="0" scalar lndetit = `lndetiterations'
	else scalar lndetit = 30
	
	if "`lndetorder'"!="0" scalar lndetor = `lndetorder'
	else scalar lndetor = 50

}
else local lndet 0


*** Hausman parsing
if "`hausman'"!="" {
	local postscore postscore
	local posthessian posthessian
	if `effects' == 1 local _tobeestimated 2
	else local _tobeestimated 1
	if `modtype'==4 | `modtype'==5 {
		di as err "-hausman- option is not allowed if model(`model')"
		error 198
	}
}

*** Mark sample
marksample touse

*** Lagged dependent var?
if "`dlag'" != "" local lagdep=1
else local lagdep=0

*** Nsim for effects s.e. cannot be 1
if "`nsim'"=="1" {
	di in yel "Number of simulations cannot be equal to 1. nsim() has been set to 2"
	di in yel "Use option vceeffects(none) to suppress the computation of effects' standard errors."
	local nsim 2
}


	
***********************************************************************************
******* Define macros to correctly create _InIt_OpTiMiZaTiOn() structure **********
***********************************************************************************

if "`difficult'"!="" local difficult "hybrid"
else local difficult "m-marquardt"
if "`nowarning'"!="" local nowarning "on"
else local nowarning "off"
if "`technique'"!="" local technique "`technique'"
else local technique "nr"
if "`nolog'"!="" local nolog "none"
else local nolog "value"
if "`trace'"!="" local trace "on"
else local trace "off"
if "`gradient'"!="" local gradient "on"
else local gradient "off"
if "`showstep'"!="" local showstep "on"
else local showstep "off"
if "`hessian'"!="" local hessian "on"
else local hessian "off"
if "`showtolerance'"!="" local showtolerance "on"
else local showtolerance "off"
if "`constraints'" != "" local constrained_est "on"
else local constrained_est "off"
if "`nonrtolerance'" != "" local nonrtolerance "on"
else local nonrtolerance "off"

*** L and NR tol to ensure converg in sac model with time or both fixed-effects
if `modtype'==4 & (`efftype'==2 | `efftype'==3) {
	local ltolerance 1e-4 
	local nrtolerance 1e-2
}
*** Scalars
scalar TOLerance = `tolerance'
scalar LTOLerance = `ltolerance'
scalar NRTOLerance = `nrtolerance'
scalar MaXiterate = `iterate'
scalar CILEVEL = `level'

/// Parsing of display options
_get_diopts diopts options, `options'

/// ERRORS
	
	if (`modtype' == 3 | `modtype' == 5) & "`d_i_t_effects'"!="" {
    	display in yel "Warning: Option -effects- is redundant"
		local d_i_t_effects 
  	}
	if regexm("`options'","dlag")==1 {
		di as error "-dlag- option incorrectly specified. Use dlag(#) where # indicates a specific dynamic model"
    	error 198 
	}
  	if (`modtype'==1 & "`ematrix'"!="") {
    	display as error "Specify wmatrix() option with SAR model"
    	error 198
  	}
  	if (`modtype'==3 & "`wmatrix'"!="") {
    	display as error "Specify ematrix() option with SEM model"
    	error 198
  	}
  	if (`modtype'==2 & "`ematrix'"!="" & "`wmatrix'"=="") {
    	display as error "Specify wmatrix() option with SDM model"
    	error 198
  	}
  	if (`modtype'==2 & "`ematrix'"!="" & "`wmatrix'"=="" & "`dmatrix'"!="") {
    	display as error "Specify wmatrix() option with SDM model"
    	error 198
  	}
  	if (`modtype'==4 & ("`wmatrix'"=="" | "`ematrix'"=="")) {
    	display as error "Both wmatrix() and ematrix() must be specified with SAC model"
    	error 198
  	}
  	
  	if ("`fe'"!="" & "`re'"!="") {
    	display as error "Both -fe- and -re- specified - specify one or the other"
    	error 198
  	}
  	if (`modtype'==4 & "`re'"!="") {
    	display as error "SAC model can only be estimated using the -fe- option"
    	error 198
  	}
  	if (`modtype'==5 & "`fe'"!="") {
    	display as error "GSPRE model can only be estimated using the -re- option"
    	error 198
  	}
  	if (`modtype'==5 &  (`error'==1 | `error'==4) & ("`wmatrix'"=="" | "`ematrix'"=="")) {
    	display as error "Both wmatrix() and ematrix() must be specified in GSPRE model with error(`error')"
    	error 198
  	}
  	if (`modtype'==5 &  `error'==2  & "`ematrix'"!="" & "`wmatrix'"=="") {
    	display as error "Specify wmatrix() option in GSPRE model with error(`error')"
    	error 198
  	}
  	if (`modtype'==5 &  `error'==2  & "`ematrix'"!="" & "`wmatrix'"!="") {
    	display as error "Specify only wmatrix() option in GSPRE model with error(`error')"
    	error 198
  	}
  	if (`modtype'==5 &  `error'==3  & "`wmatrix'"!="" & "`ematrix'"=="" ) {
    	display as error "Specify ematrix() option in GSPRE model with error(`error')"
    	error 198
  	}
  	if (`modtype'==5 &  `error'==3  & "`wmatrix'"!="" & "`ematrix'"!="" ) {
    	display as error "Specify only ematrix() option in GSPRE model with error(`error')"
    	error 198
  	}
  	if ((`lagdep' > 0) & (`modtype' >= 3)) {
    	display as error "A dynamic specification is available only for SAR and SDM models"
    	error 198
  	}
	if ((`lagdep' > 0) & (`effects'==2)) {
    	display as error "Dynamic random-effects model is not allowed"
    	error 198
  	}
  	if (`lagdep' == 1 & `lytransf' == 1 & `effects'==1) {
    	display as error "Lee and Yu (2010) transformation not allowed in dynamic models"
    	error 198 
  	}
  	if ((`modtype' != 2) & ("`durbin'" != "")) {
    	display as error "durbin() option only allowed with model(sdm)"
    	error 198
  	}
	if (`effects'==2 & "`type'"!="") {
		di in yel "Warning: Option type(`type') will be ignored"
	}
	if (`lytransf'==1 & "`type'"!="ind") {
		di in yel "Warning: Suboption -`type'- will be replaced with -ind-"
		di in yel "Lee and Yu (2010) spatial fixed-effects transformation will be applied"
		local efftype 1
		local type "ind"
	}
	
*** CONSTANT?
  	if "`noconstant'" != "" local noconst=1
  	else local noconst=0
	if (`effects'==1 & `lagdep'==1) local noconst=1

*** Durbin parsing
	if `modtype'==2 {
		if "`durbin'" == "" {
			local durbin "`rhs'"
			di in yel "Warning: All regressors will be spatially lagged", _n
		}
	}

**************************************************************************************************************
**************** Check for panel setup and perform checks necessary for weighted estimation ******************
**************************************************************************************************************
     
    *** Check for panel setup                
	_xt, trequired 
	local id: char _dta[_TSpanel]
	local time: char _dta[_TStvar]
	tempvar temp_id temp_t Ti
	qui egen `temp_id'=group(`id') 
	sort `temp_id' `time'
	qui by `temp_id': g `temp_t' = _n if `touse'==1
	qui replace `temp_id' = . if `temp_t'== .
	sort `temp_id' `time'
	
	*** Count panels and original panel length (before any transformation of the data) 
	qui by `temp_id': gen long `Ti' = _N if _n==_N & `touse'==1
	qui summ `Ti' if `touse'==1, mean
	local t_orig = r(max)
	qui count if `Ti'<.
	local N_g = r(N)
	
	*** Set up weights
	tempvar wtval
	gen `wtval'=1
	if "`weight'" != "" {
	    quietly replace `wtval'=`exp'
		local __equal "="
		loc weight4post "`weight'"
		loc exp4post "`exp'"
	}
	local wtvar "`wtval'"




	
***********************************************************************
*** Get temporary variable names and perform Factor Variables check ***
***********************************************************************
*** (Note: Also remove base collinear variables if fv are specified)

	local fvops = "`s(fvops)'" == "true" 
	if `fvops' {
		if _caller() >= 11 {
			
	    	local vv_fv : di "version " string(max(11,_caller())) ", missing:"
	    	
			********* Factor Variables parsing ****
			`vv_fv' _fv_check_depvar `lhs'
			
			local fvars "rhs durbin"
			foreach l of local fvars {
				if "`l'"=="rhs" local fv_nocons "`nocons'"
				fvexpand ``l''
				local _n_vars: word count `r(varlist)'
				local rvarlist "`r(varlist)'"
				fvrevar `rvarlist'
				local _`l'_temp "`r(varlist)'"
				forvalues _var=1/`_n_vars'  {
					_ms_parse_parts `:word `_var' of `rvarlist''
					*** Get temporary names here
					if "`r(type)'"=="variable" {
						local _`l'_tempnames "`_`l'_tempnames' `r(name)'"
						local _`l'_ntemp "`_`l'_ntemp' `:word `_var' of `_`l'_temp''"
					}
					if "`r(type)'"=="factor" & `r(omit)'==0 {
						local _`l'_tempnames "`_`l'_tempnames' `r(op)'.`r(name)'"
						local _`l'_ntemp "`_`l'_ntemp' `:word `_var' of `_`l'_temp''"
					}
					if ("`r(type)'"=="interaction" | "`r(type)'"=="product") & `r(omit)'==0 {
						local _inter
						forvalues lev=1/`r(k_names)' {
							if `lev'!=`r(k_names)' local _inter "`_inter'`r(op`lev')'.`r(name`lev')'#"
							else local _inter "`_inter'`r(op`lev')'.`r(name`lev')'"
						}
						local _`l'_tempnames "`_`l'_tempnames' `_inter'"
						local _`l'_ntemp "`_`l'_ntemp' `:word `_var' of `_`l'_temp''"						
					}
				}
				*** Remove duplicate names (Notice that collinear regressor other than fv base levels are removed later)
				local _`l'_names: list uniq _`l'_tempnames
				*** Update fvars components after fv parsing
				local `l' "`_`l'_ntemp'"
			}
		}	
	}
	
	if `fvops' & "`d_i_t_effects'"!="" {
		local d_i_t_effects 
		di in yel "Warning: direct and indirect effects cannot be computed if factor variables are specified"	
		di in yel "         option -effects- ignored. Notice that total effects can be obtained using -margins-"	
	}
	
	
*** Test for missing values in dependent and independent variables
	local __check_missing "`lhs' `rhs' `durbin'"
  	egen _xsmle_missing_obs=rowmiss(`__check_missing')
  	quietly sum _xsmle_missing_obs
  	drop _xsmle_missing_obs
  	local nobs=r(N)
  	local nmissval=r(sum)
  	if `nmissval' > 0 {
    	display as error "Error - the panel data must be strongly balanced with no missing values"
    	error 198
  	}

*** Parsing vce options

	local crittype "Log-likelihood"
	
	cap _vce_parse, argopt(CLuster) opt(OIM OPG Robust) old	///
	: [`weight' `__equal' `exp'], `vce' `robust' `cluster'
	
	if _rc == 0 {
		local vce "`r(vce)'"
		if "`vce'" == "" local vce "oim"
		if "`vce'"=="cluster" {
			local vcetype "Robust"
			local clustervar "`r(cluster)'"
			local crittype "Log-pseudolikelihood"
		}
		if "`vce'"=="robust" {
			local vce "cluster"
			local vcetype "Robust"
			local clustervar "`id'"
			local crittype "Log-pseudolikelihood"
		}
		if "`vce'"=="opg" local vcetype "OPG"	
	}
	else {
		local vce = regexr("`vce'","vce\(","")
		local vce = regexr("`vce'","\)","")
		
		gettoken vcetocheck _sub_vcetocheck: vce
		local _sub_vcetocheck = subinstr("`_sub_vcetocheck'"," ","",.)
		ParseOTHvce vce : `"`vcetocheck'"'
		
		if "`vce'" == "dkraay" {
			if "`_sub_vcetocheck'"=="" local roblag = floor(4*(`t_orig'/100)^(2/9))
			else {
				cap confirm n `_sub_vcetocheck'
				if _rc {
					dis as error "The lag in vce(dkraay `_sub_vcetocheck') must be an integer number"
					error 198
				}
				if regexm("`_sub_vcetocheck'","[0-9][0-9]*") local roblag = regexs(0)					
				if `roblag'>=`t_orig' {
					di as error "The lag for vce(dkraay) is too large"
					error 198
				}
			}
			local vcetype "Robust"
			local crittype "Log-pseudolikelihood"
			scalar roblag = `roblag'
		}
		if "`vce'" == "srobust" {
			*** Parsing of the spatial contiguity matrix for two-way clustering
			Parse2waycsSpatMat, csmat(`_sub_vcetocheck')
			if "`r(_smatspmatobj)'"!="" {
				mat `smatrix' = r(_smatspmatobj)
				local _smatspmatobj 1
			}
			else local smatrix "`r(smatrix)'"
			local vcetype "Robust"
			local crittype "Log-pseudolikelihood"			
		}
	}


*** Remove collinearity
_rmcollright `rhs' if `touse' [`weight' `__equal' `exp'], `noconstant' 		
local rhs "`r(varblocklist)'"
if `modtype'==2 {
	_rmcollright `durbin' if `touse' [`weight' `__equal' `exp'], `noconstant' 			
	local durbin "`r(varblocklist)'"
}

if `fvops'==0 {
	local _rhs_names "`rhs'"
	local _durbin_names "`durbin'"
}

local _k_final: word count `_rhs_names'
local _rhsvar "`_rhs_names'"
local _kd_final: word count `_durbin_names'
local _durb_rhsvar "`_durbin_names'"

****************************************************************************
// Names for display

if `effects' == 1 local _rhs_names "`_rhs_names'"
if `dlag_type' == 1 local _rhs_names "l.`lhs_name' `_rhs_names'"
if `dlag_type' == 2 local _rhs_names "l.W`lhs_name' `_rhs_names'"
if `dlag_type' == 3 local _rhs_names "l.`lhs_name' l.W`lhs_name' `_rhs_names'"

if `effects'==2 {
	if `noconst' == 0 local _rhs_names "`_rhs_names' _cons"
	local pname_theta "sigma_a"
	if `lagdep'==0 & (`modtype'==1 | `modtype'==2) local pname_theta "lgt_theta"
	if `modtype'==3 local pname_theta "ln_phi"
	local cname_theta "Variance"
}

foreach name of local _rhs_names {
	local _colnames "`_colnames' Main"
}

if `modtype' == 1 {
	/*if `effects'==1 local sigma2e_name "sigma2_e"
	else local sigma2e_name "sigma_e"*/
	local sigma2e_name "sigma2_e"
	
	local _regr_names "`_rhs_names' rho `pname_theta' `sigma2e_name'"
	local __colnames "`_colnames' Spatial `cname_theta' Variance"
	local _k_exp = 2 + `:word count `pname_theta''
}
if `modtype' == 2 {
	/*
	if `effects'==1  local sigma2e_name "sigma2_e"
	else local sigma2e_name "sigma_e"
	*/
	local sigma2e_name "sigma2_e"
	
	foreach name of local _durbin_names {
		local _colnames_durb "`_colnames_durb' Wx"
	}
	local _regr_names "`_rhs_names' `_durbin_names' rho `pname_theta' `sigma2e_name'"
	local __colnames "`_colnames' `_colnames_durb' Spatial `cname_theta' Variance"
	local _k_exp = 2 + `:word count `pname_theta''
}
if `modtype' == 3 {
	local _regr_names "`_rhs_names' lambda `pname_theta' sigma2_e"
	local __colnames "`_colnames' Spatial `cname_theta' Variance"
	local _k_exp = 2 + `:word count `pname_theta''
}
if `modtype' == 4 {
	local _regr_names "`_rhs_names' rho lambda sigma2_e"
	local __colnames "`_colnames' Spatial Spatial Variance"
	local _k_exp = 3 
}

if `modtype' == 5 {
	if `error'==1 {
		local _regr_names "`_rhs_names' phi lambda sigma_mu sigma_e"
		local __colnames "`_colnames' Spatial Spatial Variance Variance"
		local _k_exp = 4
	}
	if `error'==2 {
		local _regr_names "`_rhs_names' phi sigma_mu sigma_e"
		local __colnames "`_colnames' Spatial Variance Variance"
		local _k_exp = 3
	}
	if `error'==3 {
		local _regr_names "`_rhs_names' lambda sigma_mu sigma_e"
		local __colnames "`_colnames' Spatial Variance Variance"
		local _k_exp = 3
	}
	if `error'==4 {
		local _regr_names "`_rhs_names' phi sigma_mu sigma_e"
		local __colnames "`_colnames' Spatial Variance Variance"
		local _k_exp = 3
	}
}

/// Assign names (just for starting values and constraints)
tempname init_b
mat `init_b'= J(1,`: word count `_regr_names'',.)
`vv' mat colnames `init_b' = `_regr_names' 
`vv' mat coleq `init_b' = `__colnames'

if "`from'" != "" {
	/*local _colfullnames: colfullnames `init_b'
	tempname mat_from*/	
	local arg `from'
	`vv' _mkvec `init_b', from(`arg') /*colnames(`_colfullnames')*/ update error("from()")
	
	if `s(k_fill)'==0 & regexm("`vv'", "10") {
		di in yel "Warning: from() option failed to properly set starting values."
		di in yel " from() must be a properly labeled vector or have equation and colnames fully"
		di in yel " specified via the" in gr " eqname:name=# " in yel "syntax."
	}
}

*** Parsing of constraints (if defined)
if "`constraints'"!="" {
	local contraintsy 1
	tempname _vinit_b
	mat `_vinit_b' = J(1,`: word count `_regr_names'',0)
	mat colnames `_vinit_b' = `_regr_names'
	mat coleq `_vinit_b' = `__colnames'
	_parse_constraints, constraintslist(`constraints') estparams(`_vinit_b')
}

** Parsing of effects and vceeffects() options
local 0 `vceeffects'
syntax [anything], [NSIM(integer 500)]
if "`anything'" == "" local se_effects_meth "sim"
else local se_effects_meth "`anything'"
if inlist("`se_effects_meth'","dm","sim","none")==0 {
	di as error "vceeffects() option incorrectly specified."
	error 198
}
*** No S.E. from vceeffects() option
if "`se_effects_meth'"=="none" {
	local nsim 1
}

********************** Display info ********************** 
cap qui tab `temp_t' if `touse'==1
local t_max = r(r)
local nobs = r(N)
**********************************************************
 
/* Check if weight is constant within panel.
   Note: weight variable is normalized in _xsmle_est()
   since we need the right e(sample), i.e after any data transf */

sort `temp_id'
tempvar _xsmle_weight_sd
qui by `temp_id': egen `_xsmle_weight_sd'=sd(`wtvar')
sum `_xsmle_weight_sd', mean
local panel_sd_max=r(max)
if `panel_sd_max' > 0 & `panel_sd_max'!=. {
	display as error "Weights must be constant within panels"
	error 198
}
if `panel_sd_max' == . {
	display as error "The dataset in memory is not a panel dataset."
	error 198		
}

*** Sort data for the estimation of spatial panel data models
sort `temp_t' `temp_id' 

*********************************************************************
********************* Model estimation ******************************
*********************************************************************

*** Collect init optimization options
mata: _InIt = _InIt_OpTiMiZaTiOn_xsmle()
*** The following to check the content of the structure ** Just for debugging
*mata: liststruct(_InIt)


#delimit ;
mata: _xsmle_est(`N_g', `t_max', "`touse'", "`temp_id'", "`temp_t'",  
				 "`lhs'", "`rhs'", "`durbin'", `noconst', 
				 "`wmatrix'", "`ematrix'", "`dmatrix'", "`smatrix'", "`wtvar'", "`weight'",
				 `modtype', `effects', `efftype', `lytransf', `lagdep', `dlag_type', `error', `lndet',
				  _InIt, _FrOm_SpMaT_oBj, &_xsmle_sv(), "`init_b'", &_xsmle_diagn());
#delimit cr

/// Collect the original touse to fix the dlag issue in performing the hausman test
if "`hausman'"!="" marksample htouse

if `lytransf'==1 | `lagdep'==1 {
	/* Fix estimation sample for lytransf */
	tempname rulez
	qui gen `rulez' = 1
	qui replace `rulez' = . if `temp_t'==`t_max' & `lytransf'==1
	qui replace `rulez' = . if `temp_t'==1 & `lagdep'==1
	markout `touse' `rulez'
	qui tab `temp_t' if `touse'
	local t_max = r(r)
	qui count if `touse'
	local nobs = r(N)
}

/// Assign names
`vv' mat colnames __b = `_regr_names' 
`vv' mat coleq __b = `__colnames'
`vv' mat colnames _V = `_regr_names'
`vv' mat rownames _V = `_regr_names' 
`vv' mat coleq _V = `__colnames'
`vv' mat roweq _V = `__colnames'



if "`d_i_t_effects'" != "" tempname _oVc _bbeta _ttheta _tau _psi _dir _indir _tot _vdir _vindir _vtot _dir2 _indir2 _tot2 _vdir2 _vindir2 _vtot2	 	

if "`d_i_t_effects'" != "" & ("`se_effects_meth'"=="sim" | "`se_effects_meth'"=="none") {
	if `modtype' == 1 | `modtype' == 2 | `modtype' == 4 { 
				
		cap mat `_oVc' = cholesky(_V)
		if _rc & "`nsim'"!="1" {
			di in yel "Warning: e(V) matrix is not positive definite."
			di in yel "         Spatial effects Std. Err. will be computed using a modified"
			di in yel "         positive definite matrix (Rebonato and Jackel, 2000)."
				qui{
					mata: _VVV = st_matrix("_V")
					mata: eigensystem(_VVV, X=., L=.)
					mata: nlesszero = cols(L[mm_which(Re(L):<0)])
					mata: L[mm_which(Re(L):<0)] = J(1,nlesszero,0.001)
					mata: _AAA = Re((X*diag(L)*X'))
					mata: st_matrix("`_oVc'", cholesky(_AAA))	
				}
		}
		
		if "`nsim'"=="1" {
			local _rows = rowsof(_V)
			local _cols = colsof(_V)
			mat `_oVc' = J(`_rows',`_cols',0)
			mata: draws = _xsmle_draws("__b","`_oVc'", `nsim')
		}
		else {
			mata: draws = _xsmle_draws("__b","`_oVc'", `nsim')
			di in gr "Computing marginal effects standard errors using MC simulation..."
		}
		
		mat `_bbeta' = __b[1,"Main:"]
		if `lagdep' == 1 {
			local _bbetanames_dyn_temp: colnames `_bbeta'
			if `dlag_type'==1 {
				local _bbetanames_dyn: word 1 of `_bbetanames_dyn_temp'
				mat `_tau' = `_bbeta'[1,1]
				mat `_psi' = 0
				mat `_bbeta' = `_bbeta'[1,2...]	
			}
			if `dlag_type'==2 {
				local _bbetanames_dyn: word 1 of `_bbetanames_dyn_temp'
				mat `_tau' = 0
				mat `_psi' = `_bbeta'[1,1]
				mat `_bbeta' = `_bbeta'[1,2...]	
			}
			if `dlag_type'==3 {
				local _bbetanames_dyn1: word 1 of `_bbetanames_dyn_temp'
				local _bbetanames_dyn2: word 2 of `_bbetanames_dyn_temp'
				local _bbetanames_dyn "`_bbetanames_dyn1' `_bbetanames_dyn2'"
				mat `_tau' = `_bbeta'[1,1]
				mat `_psi' = `_bbeta'[1,2]
				mat `_bbeta' = `_bbeta'[1,3...]	
			}
		}
		
		local _bbetanames_temp: colnames `_bbeta'
		local _n_bbetanames: word count `_bbetanames_temp'

		forvalues _name=1/`_n_bbetanames'  {

			if `vvcheck'>=11 {
				`vv_fv' _ms_parse_parts `:word `_name' of `_bbetanames_temp''
				local rtype "`r(type)'"
			}
			else local rtype "variable"
			
			if "`rtype'"=="variable" local _bbetanames "`_bbetanames' `r(name)'"		
			if "`r(type)'"=="factor" & "`r(omit)'"=="0" local _bbetanames "`_bbetanames' `r(op)'.`r(name)'"
			if ("`r(type)'"=="interaction" | "`r(type)'"=="product") & "`r(omit)'"=="0" {
				local _inter
				forvalues lev=1/`r(k_names)' {
					if `lev'!=`r(k_names)' local _inter "`_inter'`r(op`lev')'.`r(name`lev')'#"
					else local _inter "`_inter'`r(op`lev')'.`r(name`lev')'"
				}
				local _bbetanames "`_bbetanames' `_inter'"						
			}			
		}

		if `noconst'==0 {
			local _posofcons: list posof "_cons" in _bbetanames
		    local __cons _cons
		    local _bbetanames: list _bbetanames - __cons
		}
		
		if `modtype'==2 {
			mat `_ttheta' = __b[1,"Wx:"]
			local _tthetanames_temp: colnames `_ttheta'
			local _n_tthetanames: word count `_tthetanames_temp'

			forvalues _name=1/`_n_tthetanames'  {

				if `vvcheck'>=11 {
					`vv_fv' _ms_parse_parts `:word `_name' of `_tthetanames_temp''
					local rtype "`r(type)'"
				}
				else local rtype "variable"
	
				if "`rtype'"=="variable" local _tthetanames "`_tthetanames' `r(name)'"		
				if "`r(type)'"=="factor" & "`r(omit)'"=="0" local _tthetanames "`_tthetanames' `r(op)'.`r(name)'"
				if ("`r(type)'"=="interaction" | "`r(type)'"=="product") & "`r(omit)'"=="0" {
					local _inter
					forvalues lev=1/`r(k_names)' {
						if `lev'!=`r(k_names)' local _inter "`_inter'`r(op`lev')'.`r(name`lev')'#"
						else local _inter "`_inter'`r(op`lev')'.`r(name`lev')'"
					}
					local _tthetanames "`_tthetanames' `_inter'"						
				}					
			}
		}
		
		*** Check for which variables must be computeted what
		local _allvars "`_bbetanames' `_tthetanames'"
		local _allvars: list uniq _allvars
		local _nallvars: word count `_allvars'
		local _case1: list _bbetanames - _tthetanames
		local _case2: list _bbetanames & _tthetanames
		local _case3: list _tthetanames - _bbetanames
		
		mata: `_dir' = J(1,`_nallvars',.)
		mata: `_indir' = J(1,`_nallvars',.)
		mata: `_tot' = J(1,`_nallvars',.)
		mata: `_vdir' = J(`_nallvars',`_nallvars',0)
		mata: `_vindir' = J(`_nallvars',`_nallvars',0)
		mata: `_vtot' = J(`_nallvars',`_nallvars',0)
		
		if `lagdep'==1 {
			mata: `_dir2' = J(1,`_nallvars',.)
			mata: `_indir2' = J(1,`_nallvars',.)
			mata: `_tot2' = J(1,`_nallvars',.)
			mata: `_vdir2' = J(`_nallvars',`_nallvars',0)
			mata: `_vindir2' = J(`_nallvars',`_nallvars',0)
			mata: `_vtot2' = J(`_nallvars',`_nallvars',0)	
		}
		
		local _for_rho_pos: colnames __b
		local __posrho: list posof "rho" in _for_rho_pos
		
		if `lagdep'==1 {
			local __posly: list posof "L.y" in _for_rho_pos
			local __poslWy: list posof "L.Wy" in _for_rho_pos
		}
		
		m __deffects_ = J(`nsim',`_nallvars',.)
		m __indeffects_ = J(`nsim',`_nallvars',.)
		m __toteffects_ = J(`nsim',`_nallvars',.)
		if `lagdep'==1 {
			m __deffects2_ = J(`nsim',`_nallvars',.)
			m __indeffects2_ = J(`nsim',`_nallvars',.)
			m __toteffects2_ = J(`nsim',`_nallvars',.)
		}
		
		forvalues _c=1/3 {
				
			foreach _v of local _case`_c' {
			
				local __nbeta: word count `_bbetanames'

				if (`_c' == 1 | `_c' == 2) {
					local __posbeta: list posof "`_v'" in _bbetanames
					local __posbeta = `__posbeta' + cond(`dlag_type'==3,2,cond(`dlag_type'==1 | `dlag_type'==2,1,0 ))
				}
				if (`_c' == 2 | `_c' == 3) {
					local __postheta: list posof "`_v'" in _tthetanames
					local __postheta = `__postheta'+`__nbeta' + cond(`noconst'==0,1,0) + cond(`dlag_type'==3,2,cond(`dlag_type'==1 | `dlag_type'==2,1,0 ))
				}
							
				if "`__posbeta'"=="" local __posbeta = 1
				if "`__postheta'"=="" local __postheta = 1
							
				*mata: __effects = _xsmle_effects(draws[.,`__posbeta'],draws[.,`__posrho'],"`wmatrix'",`_c',"`dmatrix'",draws[.,`__postheta'],"`_tau'","`_psi'",`lagdep',_FrOm_SpMaT_oBj)
				m __effects = _xsmle_effects(draws[.,`__posbeta'],draws[.,`__posrho'],"`wmatrix'",`_c',"`dmatrix'",draws[.,`__postheta'],"`_tau'","`_psi'",`lagdep',_FrOm_SpMaT_oBj)
			
				local __posfin: list posof "`_v'" in _allvars
				
				if `lagdep'==1 {				
					m __deffects_[.,`__posfin'] = __effects[.,1]
					m __indeffects_[.,`__posfin'] = __effects[.,2]
					m __toteffects_[.,`__posfin'] = __effects[.,3]
					m __deffects2_[.,`__posfin'] = __effects[.,4]
					m __indeffects2_[.,`__posfin'] = __effects[.,5]
					m __toteffects2_[.,`__posfin'] = __effects[.,6]
				}
				else {
					m __deffects_[.,`__posfin'] = __effects[.,1]
					m __indeffects_[.,`__posfin'] = __effects[.,2]
					m __toteffects_[.,`__posfin'] = __effects[.,3]					
				}
		
				/*
				if `lagdep'==1 {
				
					local __posfin: list posof "`_v'" in _allvars
					mata: `_dir'[1,`__posfin'] = __effects[1,1]
					mata: `_indir'[1,`__posfin'] = __effects[1,2]
					mata: `_tot'[1,`__posfin'] = __effects[1,3]
					mata: `_vdir'[`__posfin',`__posfin'] = __effects[2,1]
					mata: `_vindir'[`__posfin',`__posfin'] = __effects[2,2]
					mata: `_vtot'[`__posfin',`__posfin'] = __effects[2,3]	
					
					
					mata: `_dir2'[1,`__posfin'] = __effects[1,4]
					mata: `_indir2'[1,`__posfin'] = __effects[1,5]
					mata: `_tot2'[1,`__posfin'] = __effects[1,6]
					mata: `_vdir2'[`__posfin',`__posfin'] = __effects[2,4]
					mata: `_vindir2'[`__posfin',`__posfin'] = __effects[2,5]
					mata: `_vtot2'[`__posfin',`__posfin'] = __effects[2,6]
				
				}
				else {
					local __posfin: list posof "`_v'" in _allvars
					mata: `_dir'[1,`__posfin'] = __effects[1,1]
					mata: `_indir'[1,`__posfin'] = __effects[1,2]
					mata: `_tot'[1,`__posfin'] = __effects[1,3]
					mata: `_vdir'[`__posfin',`__posfin'] = __effects[2,1]
					mata: `_vindir'[`__posfin',`__posfin'] = __effects[2,2]
					mata: `_vtot'[`__posfin',`__posfin'] = __effects[2,3]
				}
				*/
				
				local __nbeta
				local __posbeta
				local __postheta	
			}
		}
		
		if `lagdep'==0 m _xsmle_get_marginal_effects("__b","_V",__deffects_,__indeffects_,__toteffects_,`nsim')
		else {
			m _xsmle_get_marginal_effects_dyn("__b","_V",__deffects_,__indeffects_,__toteffects_, ///
									 __deffects2_,__indeffects2_,__toteffects2_,`nsim')
		}
		
		/*
		mata: st_matrix("`_dir'",`_dir')
		mata: st_matrix("`_indir'",`_indir')
		mata: st_matrix("`_tot'",`_tot')
		mata: st_matrix("`_vdir'",`_vdir')
		mata: st_matrix("`_vindir'",`_vindir')
		mata: st_matrix("`_vtot'",`_vtot')
		
		if `lagdep'==1 {
		
			mata: st_matrix("`_dir2'",`_dir2')
			mata: st_matrix("`_indir2'",`_indir2')
			mata: st_matrix("`_tot2'",`_tot2')
			mata: st_matrix("`_vdir2'",`_vdir2')
			mata: st_matrix("`_vindir2'",`_vindir2')
			mata: st_matrix("`_vtot2'",`_vtot2')		
	
		}
		
		*/
		
		** Fix names
		local __effnames "`_allvars'"		
		foreach name of local __effnames {
		
			if `lagdep'==0 {
				local _colnames_vdir `"`_colnames_vdir' "LR_Direct""'
				local _colnames_vindir `"`_colnames_vindir' "LR_Indirect""'
				local _colnames_vtot `"`_colnames_vtot' "LR_Total""'
			}
			else {
				local _colnames_vdir `"`_colnames_vdir' "SR_Direct""'
				local _colnames_vindir `"`_colnames_vindir' "SR_Indirect""'
				local _colnames_vtot `"`_colnames_vtot' "SR_Total""'
				local _colnames_vdir2 `"`_colnames_vdir2' "LR_Direct""'
				local _colnames_vindir2 `"`_colnames_vindir2' "LR_Indirect""'
				local _colnames_vtot2 `"`_colnames_vtot2' "LR_Total""'
			}
		}
		
		* This has been substituted by the option -effects-
		*if "`showeffects'"!="" {
	
			/*
			if `lagdep'==0 mat __b = __b,`_dir',`_indir',`_tot'
			else mat __b = __b,`_dir',`_indir',`_tot',`_dir2',`_indir2',`_tot2'
			*/
			if `lagdep'==0 `vv' mat colnames __b = `_regr_names' `__effnames' `__effnames' `__effnames'
			else  `vv' mat colnames __b = `_regr_names' `__effnames' `__effnames' `__effnames' `__effnames' `__effnames' `__effnames'
			if `lagdep'==0 `vv' mat coleq __b = `__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot'
			else `vv' mat coleq __b = `__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot' `_colnames_vdir2' `_colnames_vindir2' `_colnames_vtot2'

		/*}
		else {
			mat __effects = `_dir',`_indir',`_tot'
			`vv' mat colnames __effects = `__effnames' `__effnames' `__effnames'
			`vv' mat coleq __effects = `_colnames_vdir' `_colnames_vindir' `_colnames_vtot'		
		}*/
		
		/*
		mata: __V = st_matrix("_V")
		if "`nsim'"=="1" {
			mata: _diag(`_vdir',0)
			mata: _diag(`_vindir',0)
			mata: _diag(`_vtot',0)
			if `lagdep'==1 {
				mata: _diag(`_vdir2',0)
				mata: _diag(`_vindir2',0)
				mata: _diag(`_vtot2',0)			
			}
		}
		*/
		
		* This has been substituted by the option -effects-
		*if "`showeffects'"!="" {
			/*
			mata: __V = blockdiag(__V,`_vdir')
			mata: __V = blockdiag(__V,`_vindir')
			mata: __V = blockdiag(__V,`_vtot')
			if `lagdep'==1 {
				mata: __V = blockdiag(__V,`_vdir2')
				mata: __V = blockdiag(__V,`_vindir2')
				mata: __V = blockdiag(__V,`_vtot2')
			}
			*/
			
			*mata: st_matrix("_V", __V)
			if `lagdep'==0 {
				`vv' mat colnames _V = `_regr_names' `__effnames' `__effnames' `__effnames'
				`vv' mat rownames _V = `_regr_names' `__effnames' `__effnames' `__effnames' 
				`vv' mat coleq _V = `__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot'
				`vv' mat roweq _V = `__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot'
			}
			else {
				`vv' mat colnames _V = `_regr_names' `__effnames' `__effnames' `__effnames' `__effnames' `__effnames' `__effnames'
				`vv' mat rownames _V = `_regr_names' `__effnames' `__effnames' `__effnames' `__effnames' `__effnames' `__effnames'
				`vv' mat coleq _V = `__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot' `_colnames_vdir2' `_colnames_vindir2' `_colnames_vtot2'
				`vv' mat roweq _V = `__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot' `_colnames_vdir2' `_colnames_vindir2' `_colnames_vtot2'						
			}
			
			
		/*}
		else {
			m __effects__V = J(0,0,0)
			mata: __effects__V = blockdiag(__effects__V,`_vdir')
			mata: __effects__V = blockdiag(__effects__V,`_vindir')
			mata: __effects__V = blockdiag(__effects__V,`_vtot')
			mata: st_matrix("__effects__V", __effects__V)
			`vv' mat colnames __effects__V = `__effnames' `__effnames' `__effnames'
			`vv' mat rownames __effects__V =  `__effnames' `__effnames' `__effnames' 
			`vv' mat coleq __effects__V =  `_colnames_vdir' `_colnames_vindir' `_colnames_vtot'
			`vv' mat roweq __effects__V = `_colnames_vdir' `_colnames_vindir' `_colnames_vtot'		
		}*/
	}
}

if "`effects'"=="" local pippo "`__colnames'"
else {
	if `lagdep'==1 local pippo "`__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot' `_colnames_vdir2' `_colnames_vindir2' `_colnames_vtot2'"
	else local pippo "`__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot'"
}

local to_count_eqs: list uniq pippo
local k_eq: word count `to_count_eqs'

if `modtype'==2 & `lagdep'==1 {
	** Make sigma_mu positive
	local _n__b: word count `_regr_names'
	local _n__b = `_n__b'-1
	tempname __sigma_mu
	scalar `__sigma_mu' = abs(__b[1,`_n__b'])
	mat __b[1,`_n__b'] = `__sigma_mu' 
}

*** Post result for display
eret post __b _V, e(`touse') obs(`nobs')

///////////////// Display results /////////////////
*** Common post 
eret local depvar "`lhs_name'"
eret local rhsvar "`_rhsvar'"
if `modtype'==2 {
	tempname ____b 
	mat `____b' = e(b)
	mat `____b' = `____b'[1,"Main:"],`____b'[1,"Wx:"]
	local _allvars: colnames `____b'
	local _posofcons: list posof "_cons" in _allvars
	if "`_posofcons'" != "0" {
		local __cons _cons
		local _allvars: list _allvars - __cons
	}
	if `dlag_type' == 1 loc dvar2drop "L.`e(depvar)'"
	else if `dlag_type' == 2 loc dvar2drop "L.W`e(depvar)'"
	else loc dvar2drop "L.`e(depvar)' L.W`e(depvar)'"
	local _allvars = subinstr("`_allvars'", "`dvar2drop'", "", 1)			
	local _allvars: list uniq _allvars
	eret local covariates "`_allvars'"
}
else eret local covariates "`_rhsvar'"

eret local marginsok "xb rform naive limited full"
eret local drhsvar "`_durb_rhsvar'"
eret local predict "xsmle_p"
eret local cmd "xsmle" 
eret local noconst "`noconst'"
if "`model'"=="" local model "sar"
eret local model "`model'"
eret local effects "`re'`fe'"
eret local cmdline "`_cmd_line'"
eret local technique "`technique'"
if "`e(effects)'"=="re" & "`e(model)'"=="sar" eret local ml_method "v0"
else eret local ml_method "v1"
eret scalar rank = _rank_V

if "`contraintsy'"=="1" {
	forvalues i=1/`: word count `constraints'' {
		cap constr get `i'
		eret local constr`i' "`r(contents)'"
	}
	eret mat Cns = _CNS
}

if `effects==1' {
	if `efftype'==1 local type "ind"
	if `efftype'==2 local type "time"
	if `efftype'==3 local type "both"
	local df_adj `N_g'
}
eret scalar sigma_e = sigma_e
if `modtype'==1 | `modtype'==2 {
	if `effects'==1 {
		eret scalar a_avg = mu_av
		eret local user "_xsmle_vlfun_fesar"
	}
	if `effects'==2 {
		eret scalar sigma_a = sigma_a
		if `lagdep'==0 eret local user "_xsmle_vlfun_resar"
		else eret local user "_xsmle_vlfun_dresar"
	}
}
if `modtype'==3 {
	if `effects'==1 {
		eret scalar a_avg = mu_av
		eret local user "_xsmle_vlfun_fesem"
	}
	if `effects'==2 {
		eret scalar sigma_a = sigma_a
		eret local ml_method "v0"
		eret local user "_xsmle_vlfun_resem"
	}
}
if `modtype'==4 {
	eret scalar a_avg = mu_av
	eret local user "_xsmle_vlfun_fesac"
}
if `modtype'==5 {
	if `error'==1 eret local user "_xsmle_vlfun_gspre1"
	if `error'==2 eret local user "_xsmle_vlfun_gspre2"
	if `error'==3 eret local user "_xsmle_vlfun_gspre3"
	if `error'==4 eret local user "_xsmle_vlfun_gspre4"
	eret local gspre_err "`error'"
	eret scalar sigma_mu = sigma_mu
}
eret local type "`type'"
eret local ivar `id'
eret local tvar `time'
eret scalar t_max = `t_max'
eret scalar N_g = `N_g'
if "`vce'"=="cluster" eret scalar N_clust = N_clust
else eret scalar N_clust = `N_g'
eret scalar ll = ll
if `lagdep'==0 eret local dlag "no"
else {
	eret local dlag "yes"
	eret local dlag_type `dlag_type'
}
cap eret scalar ll_c = c_ll
eret matrix ilog = itlog
eret matrix gradient = _grad
eret scalar converged = converged
eret scalar ic = itfinal
eret local crittype "`crittype'"
eret local vce "`vce'"
eret local vcetype "`vcetype'"
eret local clustvar "`clustervar'"
if "`weight4post'" != "" {
	eret local wtype "`weight4post'"
	eret local wexp "`__equal' `exp4post'"
}
if `noconst' == 0 local _df_r_cons = 1
else local _df_r_cons = 0
eret scalar df_m = `_k_final' + `_kd_final' + `df_adj'
eret scalar k_exp = `_k_exp' 
*eret scalar df_r = `e(N)' - (`e(df_m)' + `e(k_exp)' + `_df_r_cons')
if "`roblag'"!="" eret scalar dkraay_lag = roblag
if `effects' == 1 {
	if "`leeyu'" != "" eret local transf_type "leeyu"
	else eret local transf_type "demean"
}
if "`postscore'"!="" eret matrix score = _score
if "`posthessian'"!="" eret matrix hessian = _hessian
eret scalar k_eq = `k_eq'
eret scalar r2 = r2
eret scalar r2_b = r2_b
eret scalar r2_w = r2_w

*** Matrices post
if "`wmatrix'"!="" {
	eret local wmatrix "`wmatrix'"
	eret local w_spmat_obj `_wmatspmatobj'
}
if "`ematrix'"!="" {
	eret local ematrix "`ematrix'"
	eret local e_spmat_obj `_ematspmatobj'
}
if "`dmatrix'"!="" {
	eret local dmatrix "`dmatrix'"
	eret local d_spmat_obj `_dmatspmatobj'
}

/* This has been substituted by the option -effects-
if "`showeffects'"=="" {
	eret mat effects = __effects
	eret mat effects_V = __effects__V	
}
*/ 


if "`d_i_t_effects'" != "" & "`se_effects_meth'"=="dm" {
		di in gr "Computing marginal effects standard errors using delta-method..."
		mat __b = e(b)
		mat `_bbeta' = __b[1,"Main:"]
		if `lagdep' == 1 {
			local _bbetanames_dyn_temp: colnames `_bbeta'
			if `dlag_type'==1 {
				local _bbetanames_dyn: word 1 of `_bbetanames_dyn_temp'
				mat `_tau' = `_bbeta'[1,1]
				mat `_psi' = 0
				mat `_bbeta' = `_bbeta'[1,2...]	
			}
			if `dlag_type'==2 {
				local _bbetanames_dyn: word 1 of `_bbetanames_dyn_temp'
				mat `_tau' = 0
				mat `_psi' = `_bbeta'[1,1]
				mat `_bbeta' = `_bbeta'[1,2...]	
			}
			if `dlag_type'==3 {
				local _bbetanames_dyn1: word 1 of `_bbetanames_dyn_temp'
				local _bbetanames_dyn2: word 2 of `_bbetanames_dyn_temp'
				local _bbetanames_dyn "`_bbetanames_dyn1' `_bbetanames_dyn2'"
				mat `_tau' = `_bbeta'[1,1]
				mat `_psi' = `_bbeta'[1,2]
				mat `_bbeta' = `_bbeta'[1,3...]	
			}
		}
		
		local _bbetanames_temp: colnames `_bbeta'
		local _n_bbetanames: word count `_bbetanames_temp'

		forvalues _name=1/`_n_bbetanames'  {

			if `vvcheck'>=11 {
				`vv_fv' _ms_parse_parts `:word `_name' of `_bbetanames_temp''
				local rtype "`r(type)'"
			}
			else local rtype "variable"
			
			if "`rtype'"=="variable" local _bbetanames "`_bbetanames' `r(name)'"		
			if "`r(type)'"=="factor" & "`r(omit)'"=="0" local _bbetanames "`_bbetanames' `r(op)'.`r(name)'"
			if ("`r(type)'"=="interaction" | "`r(type)'"=="product") & "`r(omit)'"=="0" {
				local _inter
				forvalues lev=1/`r(k_names)' {
					if `lev'!=`r(k_names)' local _inter "`_inter'`r(op`lev')'.`r(name`lev')'#"
					else local _inter "`_inter'`r(op`lev')'.`r(name`lev')'"
				}
				local _bbetanames "`_bbetanames' `_inter'"						
			}			
		}

		if `noconst'==0 {
			local _posofcons: list posof "_cons" in _bbetanames
		    local __cons _cons
		    local _bbetanames: list _bbetanames - __cons
		}
		
		if `modtype'==2 {
			mat `_ttheta' = __b[1,"Wx:"]
			local _tthetanames_temp: colnames `_ttheta'
			local _n_tthetanames: word count `_tthetanames_temp'

			forvalues _name=1/`_n_tthetanames'  {

				if `vvcheck'>=11 {
					`vv_fv' _ms_parse_parts `:word `_name' of `_tthetanames_temp''
					local rtype "`r(type)'"
				}
				else local rtype "variable"
	
				if "`rtype'"=="variable" local _tthetanames "`_tthetanames' `r(name)'"		
				if "`r(type)'"=="factor" & "`r(omit)'"=="0" local _tthetanames "`_tthetanames' `r(op)'.`r(name)'"
				if ("`r(type)'"=="interaction" | "`r(type)'"=="product") & "`r(omit)'"=="0" {
					local _inter
					forvalues lev=1/`r(k_names)' {
						if `lev'!=`r(k_names)' local _inter "`_inter'`r(op`lev')'.`r(name`lev')'#"
						else local _inter "`_inter'`r(op`lev')'.`r(name`lev')'"
					}
					local _tthetanames "`_tthetanames' `_inter'"						
				}					
			}
		}
		
		*** Check for which variables must be computeted what
		local _allvars "`_bbetanames' `_tthetanames'"
		local _allvars: list uniq _allvars

		tempname __dm_dir __dm_vdir __dm_indir __dm_vindir __dm_tot __dm_vtot
		cap margins, dydx(`_allvars') predict(direct) noestimcheck nochainrule force
		if _rc==0 {
			mat `__dm_dir' = r(b)
			mat `__dm_vdir' = r(V)
		}
		else {
			di as error "Delta-method direct effects' standard errors cannot be computed."
			error 198
		}
		
		cap margins, dydx(`_allvars') predict(indirect) noestimcheck nochainrule force
		if _rc==0 {
			mat `__dm_indir' = r(b)
			mat `__dm_vindir' = r(V)
		}
		else {
			di as error "Delta-method indirect effects' standard errors cannot be computed."
			error 198
		}
		
		cap margins, dydx(`_allvars') predict(total) noestimcheck nochainrule force
		if _rc==0 {
			mat `__dm_tot' = r(b)
			mat `__dm_vtot' = r(V)
		}
		else {
			di as error "Delta-method total effects' standard errors cannot be computed."
			error 198
		}
	
		if `lagdep'==1 {
			tempname __dm_dir2 __dm_vdir2 __dm_indir2 __dm_vindir2 __dm_tot2 __dm_vtot2
			cap margins, dydx(`_allvars') predict(directlr) noestimcheck nochainrule force
			if _rc==0 {
				mat `__dm_dir2' = r(b)
				mat `__dm_vdir2' = r(V)
			}
			else {
				di as error "Delta-method direct effects' standard errors cannot be computed."
				error 198
			}
			
			cap margins, dydx(`_allvars') predict(indirectlr) noestimcheck nochainrule force
			if _rc==0 {
				mat `__dm_indir2' = r(b)
				mat `__dm_vindir2' = r(V)
			}
			else {
				di as error "Delta-method indirect effects' standard errors cannot be computed."
				error 198
			}
			
			cap margins, dydx(`_allvars') predict(totallr) noestimcheck nochainrule force
			if _rc==0 {
				mat `__dm_tot2' = r(b)
				mat `__dm_vtot2' = r(V)
			}
			else {
				di as error "Delta-method total effects' standard errors cannot be computed."
				error 198
			}	
		}
	
		
		** Fix names
		local __effnames "`_allvars'"		
		foreach name of local __effnames {
		
			if `lagdep'==0 {
				local _colnames_vdir `"`_colnames_vdir' "LR_Direct""'
				local _colnames_vindir `"`_colnames_vindir' "LR_Indirect""'
				local _colnames_vtot `"`_colnames_vtot' "LR_Total""'
			}
			else {
				local _colnames_vdir `"`_colnames_vdir' "SR_Direct""'
				local _colnames_vindir `"`_colnames_vindir' "SR_Indirect""'
				local _colnames_vtot `"`_colnames_vtot' "SR_Total""'
				local _colnames_vdir2 `"`_colnames_vdir2' "LR_Direct""'
				local _colnames_vindir2 `"`_colnames_vindir2' "LR_Indirect""'
				local _colnames_vtot2 `"`_colnames_vtot2' "LR_Total""'
			}
		}
		
		
		if `lagdep'==0 mat __b = e(b),`__dm_dir',`__dm_indir',`__dm_tot' 
		else mat __b = e(b),`__dm_dir',`__dm_indir',`__dm_tot',`__dm_dir2',`__dm_indir2',`__dm_tot2' 
		
		if `lagdep'==0 `vv' mat colnames __b = `_regr_names' `__effnames' `__effnames' `__effnames'
		else  `vv' mat colnames __b = `_regr_names' `__effnames' `__effnames' `__effnames' `__effnames' `__effnames' `__effnames'
		if `lagdep'==0 `vv' mat coleq __b = `__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot'
		else `vv' mat coleq __b = `__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot' `_colnames_vdir2' `_colnames_vindir2' `_colnames_vtot2'

		/*}
		else {
			mat __effects = `_dir',`_indir',`_tot'
			`vv' mat colnames __effects = `__effnames' `__effnames' `__effnames'
			`vv' mat coleq __effects = `_colnames_vdir' `_colnames_vindir' `_colnames_vtot'		
		}*/
		
		/*
		mata: __V = st_matrix("_V")
		if "`nsim'"=="1" {
			mata: _diag(`_vdir',0)
			mata: _diag(`_vindir',0)
			mata: _diag(`_vtot',0)
			if `lagdep'==1 {
				mata: _diag(`_vdir2',0)
				mata: _diag(`_vindir2',0)
				mata: _diag(`_vtot2',0)			
			}
		}
		*/
		
		* This has been substituted by the option -effects-
		*if "`showeffects'"!="" {
			mata: __V = st_matrix("e(V)")
			mata: __V = blockdiag(__V,st_matrix("`__dm_vdir'"))
			mata: __V = blockdiag(__V,st_matrix("`__dm_vindir'"))
			mata: __V = blockdiag(__V,st_matrix("`__dm_vtot'"))
			if `lagdep'==1 {
				mata: __V = blockdiag(__V,st_matrix("`__dm_vdir2'"))
				mata: __V = blockdiag(__V,st_matrix("`__dm_vindir2'"))
				mata: __V = blockdiag(__V,st_matrix("`__dm_vtot2'"))
			}
			
			
			mata: st_matrix("_V", __V)
			if `lagdep'==0 {
				`vv' mat colnames _V = `_regr_names' `__effnames' `__effnames' `__effnames'
				`vv' mat rownames _V = `_regr_names' `__effnames' `__effnames' `__effnames' 
				`vv' mat coleq _V = `__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot'
				`vv' mat roweq _V = `__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot'
			}
			else {
				`vv' mat colnames _V = `_regr_names' `__effnames' `__effnames' `__effnames' `__effnames' `__effnames' `__effnames'
				`vv' mat rownames _V = `_regr_names' `__effnames' `__effnames' `__effnames' `__effnames' `__effnames' `__effnames'
				`vv' mat coleq _V = `__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot' `_colnames_vdir2' `_colnames_vindir2' `_colnames_vtot2'
				`vv' mat roweq _V = `__colnames' `_colnames_vdir' `_colnames_vindir' `_colnames_vtot' `_colnames_vdir2' `_colnames_vindir2' `_colnames_vtot2'						
			}
		
		*** RePost result for display
		eret repost b = __b V = _V, resize 
			
}

**********************************
**** Perform the Hausman test ****
**********************************
if "`hausman'"!="" {
	    	
	if (`_tobeestimated'!=1 & (`lagdep' > 0)) {
    	display as error "-hausman- option is ignored since the dynamic random-effects model is not allowed"
  	}
	else {
		
		if `_tobeestimated'==1 local _stobeestimated "fixed-effects"
		else local _stobeestimated "random-effects"
		di in yel "... estimating `_stobeestimated' model to perform Hausman test"
		
		tempname __betafe __betare __scorefe __scorere __Hessfe __Hessre
	
		if "`d_i_t_effects'" == "" local _minus_effects 0
		else {		
			if `modtype' == 1 | `modtype' == 2 {
				if `lagdep'==0 local _minus_effects = `: word count `__effnames''*3
				else local _minus_effects = `: word count `__effnames''*6
			}
			if `modtype' == 3 local _minus_effects 0
		}
	
		if `_tobeestimated' == 1 {
			mat `__betare' = e(b)
			local __creg: word count `_rhs_names'
	
			if "`noconstant'"!= "" {
				local __colre = colsof(`__betare')-2-`_minus_effects'
				mat `__betare' = `__betare'[1,1..`__colre']		
			}
			else {
				local __posofcons = `__creg'
				local __creg1 = `__creg'+1
				local __colre = colsof(`__betare')-2-`_minus_effects'
				mat `__betare' = `__betare'[1,1..`=`__creg'-1'],`__betare'[1,`__creg1'..`__colre']
			}
			mat `__scorere' = e(score)
			mat `__Hessre' = e(hessian)
		} 
		else {		
			mat `__betafe' = e(b)
			local __colfe = colsof(`__betafe')-1-`_minus_effects' 
			mat `__betafe' = `__betafe'[1,1..`__colfe']
			mat `__scorefe' = e(score)
			mat `__Hessfe' = e(hessian)
			if "`noconstant'"!= "" local noconst 0
		}	
	
		#delimit ;
		cap noi mata: _xsmle_est(`e(N_g)', `t_orig', "`htouse'", "`temp_id'", "`temp_t'",  
					"`lhs'", "`rhs'", "`durbin'", `noconst', 
					"`wmatrix'", "`ematrix'", "`dmatrix'", "`smatrix'", "`wtvar'", "`weight'",
					`modtype', `_tobeestimated', `efftype', `lytransf', `lagdep', `dlag_type',`error', `lndet',
					_InIt, _FrOm_SpMaT_oBj, &_xsmle_sv(), "`init_b'", &_xsmle_diagn());
		#delimit cr
	
		local _rc = _rc
		if `_rc' == 0 {
			if `_tobeestimated' == 1 {
				mat `__betafe' = __b
				local __colfe = colsof(`__betafe')-1
				mat `__betafe' = `__betafe'[1,1..`__colfe']
				mat `__scorefe' = _score
				mat `__Hessfe' = _hessian
			} 
			else {		
				mat `__betare' = __b
				local __creg: word count `_rhs_names'
				local __posofcons = `__creg'+1
				local __creg1 = `__posofcons'+1
				local __colre = colsof(`__betare')-2
				mat `__betare' = `__betare'[1,1..`__creg'],`__betare'[1,`__creg1'..`__colre']
				mat `__scorere' = _score
				mat `__Hessre' = _hessian
			}
	
			mata: _xsmle_hausman_ml("`temp_id' `temp_t'", `e(t_max)', `__creg', `_tobeestimated', "`__betafe'","`__betare'", "`__scorefe'", "`__scorere'", "`__Hessfe'", "`__Hessre'", `__posofcons')
		}
	}
}






**********************************
*** Display estimation results ***
**********************************

DiSpLaY, level(`level') hausman(`_rc') dlag(`lagdep') `diopts'


/// Destructor
local _scalars "_hau_chi2_df _hau_chi2_p _hau_chi2 N_clust converged itfinal ll CILEVEL MaXiterate NRTOLerance LTOLerance TOLerance roblag"
local _matrices "_hessian _score _V _grad __b"
foreach n of local _scalars {
	cap scalar drop	`n'
}
foreach n of local _matrices {
	cap matrix drop	`n'
}
if "`_wmatspmatobj'" == "1" cap mat drop `wmatrix'
if "`_ematspmatobj'" == "1" cap mat drop `ematrix'
if "`_dmatspmatobj'" == "1" cap mat drop `dmatrix'

return clear

end



program define DiSpLaY, eclass
        syntax [, Level(string) hausman(string) dlag(string) *]
	  
		local diopts "`options'"
		local vv : di "version " string(max(10,c(stata_version))) ", missing:"
		
		if "`dlag'"=="1" {
			local neq 9
			local dyn_ti "Dynamic "
		}
		
		if "`e(effects)'" == "fe" {
			if "`e(model)'" == "sar" {
				if "`e(type)'" == "ind"  eret local title "`dyn_ti'SAR with spatial fixed-effects"
				if "`e(type)'" == "time" eret local title "`dyn_ti'SAR with time fixed-effects"
				if "`e(type)'" == "both" eret local title "`dyn_ti'SAR with spatial and time fixed-effects"
			}
			if "`e(model)'" == "sdm" {
				if "`e(type)'" == "ind"  eret local title "`dyn_ti'SDM with spatial fixed-effects"
				if "`e(type)'" == "time" eret local title "`dyn_ti'SDM with time fixed-effects"
				if "`e(type)'" == "both" eret local title "`dyn_ti'SDM with spatial and time fixed-effects"
			}
			if "`e(model)'" == "sem" {
				if "`e(type)'" == "ind"  eret local title "SEM with spatial fixed-effects"
				if "`e(type)'" == "time" eret local title "SEM with time fixed-effects"
				if "`e(type)'" == "both" eret local title "SEM with spatial and time fixed-effects"
			}
			if "`e(model)'" == "sac" {
				if "`e(type)'" == "ind"  eret local title "SAC with spatial fixed-effects"
				if "`e(type)'" == "time" eret local title "SAC with time fixed-effects"
				if "`e(type)'" == "both" eret local title "SAC with spatial and time fixed-effects"
			}
		}
		else {
			if "`e(model)'" == "sar" eret local title "`dyn_ti'SAR with random-effects"
			if "`e(model)'" == "sdm" eret local title "`dyn_ti'SDM with random-effects"
			if "`e(model)'" == "sem" eret local title "SEM with random-effects"
			if "`e(model)'" == "gspre" eret local title "SEM with spatial autoregressive random-effects"
		}
		
        #delimit ;
		di as txt _n "`e(title)'" _col(54) "Number of obs " _col(68) "=" /*
			*/ _col(70) as res %9.0g e(N) _n;
        di in gr "Group variable: " in ye abbrev("`e(ivar)'",12) 
           in gr _col(51) "Number of groups" _col(68) "="
                 _col(70) in ye %9.0g `e(N_g)';
        di in gr "Time variable: " in ye abbrev("`e(tvar)'",12)                    
           in gr _col(55) in gr "Panel length" _col(68) "="
                 _col(70) in ye %9.0g `e(t_max)' _n;
        /*di       _col(64) in gr "avg" _col(68) "="
                 _col(70) in ye %9.1f `e(g_avg)' ;
        di       _col(64) in gr "max" _col(68) "="
                 _col(70) in ye %9.0g `e(g_max)' _n */;   
    	display in gr "R-sq:" _col(10) "within  = " in yel %6.4f `e(r2_w)';
    	display in gr _col(10) "between = " %6.4f in yel `e(r2_b)';
    	display in gr _col(10) "overall = " %6.4f in yel `e(r2)' _n;
    	if "`e(effects)'"=="fe" display in gr "Mean of fixed-effects = " in yel %7.4f e(a_avg) _n;   
   		if "`e(ll_c)'"!="" local _ll = `e(ll_c)';
		else local _ll = `e(ll)';
        di in gr "`e(crittype)' = " in yellow %10.4f `_ll';
		if "`e(vce)'"=="srobust" di in gr _col(9) 
		"(Standard errors adjusted for both within-" in yel "`e(ivar)'" in gr " and cross-" in yel "`e(ivar)'" in gr " correlation)";
        #delimit cr                    

*** DISPLAY RESULTS
`vv' eret di, level(`level') /*neq(`neq')*/ `diopts' 

if "`hausman'"!="" & "`hausman'"=="0" {
    di as text "Ho: difference in coeffs not systematic " _c
    di _col(40) in smcl "{help j_chibar##|_new:chi2(" _hau_chi2_df ") = }" /*
        */ as result %5.2f _hau_chi2 _c
    di _col(60) as text "Prob>=chi2 = " as result %5.4f /*
            */ _hau_chi2_p
    di as text "{hline 78}"
    eret scalar hau_chi2 = _hau_chi2
	eret scalar hau_chi2_p = _hau_chi2_p
	eret scalar hau_chi2_df = _hau_chi2_df
}
if "`hausman'"!="" & "`hausman'"!="0" {
	di as text "  Fitted models fails to meet the asymptotic assumptions of the Hausman test"
	di as text "{hline 78}"
}
end


/* ----------------------------------------------------------------- */

program define ParseLY
	args returmac colon leeyu
	
	local 0 ", `leeyu'"
	syntax [, LEEYU * ]

	if `"`options'"' != "" {
		di as error "The type() suboption is incorrectly specified"
		exit 198
	}
	local wc : word count `leeyu'
	if `wc' > 1 {
		di as error "type() invalid, only " /*
			*/ "one type_option can be specified"
		exit 198
	}
	c_local `returmac' `leeyu'
	
end

/* ----------------------------------------------------------------- */

program define ParseOTHvce
	args returmac colon vce
	
	local 0 ", `vce'"
	syntax [, DKraay * ]

** SROBust ** it works but it is not included for now (not documented)

	if `"`options'"' != "" {
		di as error "option vce() incorrectly specified"
		exit 198
	}
	local wc : word count `dkraay' `srobust'
	if `wc' > 1 {
		di as error "vce() invalid, only " /*
			*/ "one vce_option can be specified"
		exit 198
	}
	c_local `returmac' `dkraay'`srobust'
	
end
	
/* ----------------------------------------------------------------- */

program define Parse2waycsSpatMat, rclass
	syntax [, CSMATrix(string) ]

mata: st_rclear()
ret local rcmd "Parse2waycsSpatMat"

local smatrix `csmatrix'


if ("`smatrix'"=="") {
	display as error "Option -vce()- incorrectly specified. Suboption -srobust- requires that also a Stata matrix or a -spamat- object {it:name} is specified."
	error 198
}
else {
	local n_smatrix: word count `smatrix'
	if `n_smatrix'!=1 {
		display as error "Only one Stata matrix (or -spmat- object) is allowed in -vce(srobust {it:name})-."
	    error 198
	}
	capture confirm matrix `smatrix'
	local _rc_mat_assert = _rc
	if `_rc_mat_assert' != 0 {
		capture mata: SPMAT_assert_object("`smatrix'")
		local _rc_spmat_assert = _rc
		if `_rc_spmat_assert' == 3499 {
			capt findfile spmat.ado
		    if _rc {
		        di as error "Only Stata matrix and -spmat- objects are allowed as argument of -vce(drobust {it:name})-."
				di as error "You can install -spmat- by typing {stata net install sppack}."
		        error 499
		    }
		}
		if `_rc_spmat_assert' != 0 {
			di "{inp}`smatrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		capture mata: SPMAT_check_if_banded("`smatrix'",1)
		if _rc !=0 {
			di as error "xsmle does not support banded matrices"
			exit 498
		}
		
		tempname smatrix_new
		capture spmat getmatrix `smatrix' `smatrix_new'
		if _rc {
			di "{inp}`smatrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		else {
			tempname _smatspmatobj
			mata: st_matrix("`_smatspmatobj'", `smatrix_new')
			mata: `smatrix_new'=.
			local rww=rowsof(`_smatspmatobj')
		    local rcw=colsof(`_smatspmatobj')
		    if `rww' != `rcw' {
			    display as error "The matrix specified in vce(srobust {it:`smatrix'}) is not square."
			    error 198
		    }	
			ret matrix _smatspmatobj = `_smatspmatobj'
		}
	}
	if `_rc_mat_assert' == 0 {
    	local rww=rowsof(`smatrix')
    	local rcw=colsof(`smatrix')
    	if `rww' != `rcw' {
	    	display as error "The matrix specified in vce(srobust {it:`smatrix'}) is not square."
	    	error 198
    	}
		return local smatrix "`smatrix'"
	}
}

di in yel "Warning: Two-way clustering a' la Cameroon et al. (2009) requires a contiguity-like spatial structure."
di in yel "         Be aware that valid ineference may be conducted ONLY with such a structure."
di ""

end


/* ----------------------------------------------------------------- */

program define ParseSpatMat, rclass
	syntax [, CWMATrix(string) CEMATrix(string) CDMATrix(string) ]

mata: st_rclear()
ret local rcmd "ParseSpatMat"

local wmatrix `cwmatrix'
local ematrix `cematrix'
local dmatrix `cdmatrix'
// Notice that the structure has 4 columns instead of 3 for allowing the inclusion of Sd 
// (a matrix for double clustering, see _InIt.InIt_vce == "srobust" in _xsmle_est.mata)
m _FrOm_SpMaT_oBj = J(1, 4, _mata_matrices_xsmle())


if ("`wmatrix'"=="" & "`ematrix'"=="") {
	display as error "At least one of wmatrix() and ematrix() must be specified"
	error 198
}
if ("`wmatrix'" != "") {
	local n_wmatrix: word count `wmatrix'
	if `n_wmatrix'!=1 {
		display as error "Only one spatial weighting matrix `wmatrix' is allowed"
	    error 198
	}
	capture confirm matrix `wmatrix'
	local _rc_mat_assert = _rc
	if `_rc_mat_assert' != 0 {
		capture mata: SPMAT_assert_object("`wmatrix'")
		local _rc_spmat_assert = _rc
		if `_rc_spmat_assert' == 3499 {
			capt findfile spmat.ado
		    if _rc {
		        di as error "Only stata matrix and -spmat- objects are allowed as argument of -wmat()-."
				di as error "You can install -spmat- by typing {stata net install sppack}."
		        error 499
		    }
		}
		if `_rc_spmat_assert' != 0 {
			di "{inp}`wmatrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		capture mata: SPMAT_check_if_banded("`wmatrix'",1)
		if _rc !=0 {
			di as error "xsmle does not support banded matrices"
			exit 498
		}
		
		tempname wmatrix_new
		capture spmat getmatrix `wmatrix' `wmatrix_new'
		if _rc {
			di "{inp}`wmatrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		else {
			tempname _wmatspmatobj
			m st_numscalar("rww", rows(`wmatrix_new'))
			m st_numscalar("rcw", cols(`wmatrix_new'))
			m _FrOm_SpMaT_oBj = _GeT_FrOm_SpMaT_oBj(`wmatrix_new',1,_FrOm_SpMaT_oBj)
			//mata: st_matrix("`_wmatspmatobj'", `wmatrix_new')
			m `wmatrix_new'=.
			//local rww=rowsof(`_wmatspmatobj')
		    //local rcw=colsof(`_wmatspmatobj')
		    if rww != rcw {
			    display as error "Spatial weighting matrix `wmatrix' is not square"
			    error 198
		    }
			return local wmatrix ""
			return local o_wmatrix "`wmatrix'"
			return local _wmatspmatobj 1
		}
	}
	if `_rc_mat_assert' == 0 {
    	local rww=rowsof(`wmatrix')
    	local rcw=colsof(`wmatrix')
    	if `rww' != `rcw' {
	    	display as error "Spatial weighting matrix `wmatrix' is not square"
	    	error 198
    	}
		return local wmatrix "`wmatrix'"
	}
}

if ("`ematrix'" != "") {
	local n_ematrix: word count `ematrix'
	if `n_ematrix'!=1 {
		display as error "Only one spatial weighting matrix `ematrix' is allowed"
	    error 198
	}
	capture confirm matrix `ematrix'
	local _rc_mat_assert = _rc
	if `_rc_mat_assert' != 0 {
		capture mata: SPMAT_assert_object("`ematrix'")
		local _rc_spmat_assert = _rc
		if `_rc_spmat_assert' == 3499 {
			capt findfile spmat.ado
		    if _rc {
		        di as error "Only stata matrix and -spmat- objects are allowed as argument of -emat()-."
				di as error "You can install -spmat- by typing {stata net install sppack}."
		        error 499
		    }
		}
		if `_rc_spmat_assert' != 0 {
			di "{inp}`ematrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		capture mata: SPMAT_check_if_banded("`ematrix'",1)
		if _rc !=0 {
			di as error "xsmle does not support banded matrices"
			exit 498
		}
		
		tempname ematrix_new
		capture spmat getmatrix `ematrix' `ematrix_new'
		if _rc {
			di "{inp}`ematrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		else {
			tempname _ematspmatobj
			m st_numscalar("rww", rows(`ematrix_new'))
			m st_numscalar("rcw", cols(`ematrix_new'))
			m _FrOm_SpMaT_oBj = _GeT_FrOm_SpMaT_oBj(`ematrix_new',2,_FrOm_SpMaT_oBj)
			//mata: st_matrix("`_ematspmatobj'", `ematrix_new')
			m `ematrix_new'=.
			//local rww=rowsof(`_ematspmatobj')
		    //local rcw=colsof(`_ematspmatobj')
		    if rww != rcw {
			    display as error "Spatial weighting matrix `ematrix' is not square"
			    error 198
		    }
			return local ematrix ""
			return local o_ematrix "`ematrix'"
			return local _ematspmatobj 1
		}
	}
	if `_rc_mat_assert' == 0 {
    	local rww=rowsof(`ematrix')
    	local rcw=colsof(`ematrix')
    	if `rww' != `rcw' {
	    	display as error "Spatial weighting matrix `ematrix' is not square"
	    	error 198
    	}
		return local ematrix "`ematrix'"
	}
}

if ("`dmatrix'" != "") {
	local n_dmatrix: word count `dmatrix'
	if `n_dmatrix'!=1 {
		display as error "Only one spatial weighting matrix `dmatrix' is allowed"
	    error 198
	}
	capture confirm matrix `dmatrix'
	local _rc_mat_assert = _rc
	if `_rc_mat_assert' != 0 {
		capture mata: SPMAT_assert_object("`dmatrix'")
		local _rc_spmat_assert = _rc
		if `_rc_spmat_assert' == 3499 {
			capt findfile spmat.ado
		    if _rc {
		        di as error "Only stata matrix and -spmat- objects are allowed as argument of -dmat()-."
				di as error "You can install -spmat- by typing {stata net install sppack}."
		        error 499
		    }
		}
		if `_rc_spmat_assert' != 0 {
			di "{inp}`dmatrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		capture mata: SPMAT_check_if_banded("`dmatrix'",1)
		if _rc !=0 {
			di as error "xsmle does not support banded matrices"
			exit 498
		}
		
		tempname dmatrix_new
		capture spmat getmatrix `dmatrix' `dmatrix_new'
		if _rc {
			di "{inp}`dmatrix' {err}is not a valid {help spmat} object"
			exit 498
		}
		else {
			tempname _dmatspmatobj
			m st_numscalar("rww", rows(`dmatrix_new'))
			m st_numscalar("rcw", cols(`dmatrix_new'))
			m _FrOm_SpMaT_oBj = _GeT_FrOm_SpMaT_oBj(`dmatrix_new',3,_FrOm_SpMaT_oBj)
			//mata: st_matrix("`_dmatspmatobj'", `dmatrix_new')
			m `dmatrix_new'=.
			//local rww=rowsof(`_dmatspmatobj')
		    //local rcw=colsof(`_dmatspmatobj')
		    if rww != rcw {
			    display as error "Spatial weighting matrix `dmatrix' is not square"
			    error 198
		    }
			return local dmatrix ""
			return local o_dmatrix "`dmatrix'"
			return local _dmatspmatobj 1
		}
	}
	if `_rc_mat_assert' == 0 {
    	local rww=rowsof(`dmatrix')
    	local rcw=colsof(`dmatrix')
    	if `rww' != `rcw' {
	    	display as error "Spatial weighting matrix `dmatrix' is not square"
	    	error 198
    	}
		return local dmatrix "`dmatrix'"
	}
}


end



/* ----------------------------------------------------------------- */

program define ParseMod
	args returmac colon model

	local 0 ", `model'"
	syntax [, SAR SDM SEM SAC GSPRE * ]

	if `"`options'"' != "" {
		di as error "model(`options') not allowed"
		exit 198
	}
	
	local wc : word count `sar' `sdm' `sem' `sac' `gspre'

	if `wc' > 1 {
		di as error "model() invalid, only " /*
			*/ "one model can be specified"
		exit 198
	}

	if `wc' == 0 {
		c_local `returmac' 1
	}
	else {
		if ("`sar'"=="sar") local modtype=1
		if ("`sdm'"=="sdm") local modtype=2
		if ("`sem'"=="sem") local modtype=3
		if ("`sac'"=="sac") local modtype=4
		if ("`gspre'"=="gspre") local modtype=5
		c_local `returmac' `modtype' 		
	}	

end

/* ----------------------------------------------------------------- */

program define ParseType
	args returmac colon type

	local 0 ", `type'"
	syntax [, Ind Time Both * ]

	if `"`options'"' != "" {
		di as error "type(`options') not allowed"
		exit 198
	}
	
	local wc : word count `ind' `time' `both'

	if `wc' > 1 {
		di as error "type() invalid, only " /*
			*/ "one type can be specified"
		exit 198
	}
	if `wc' == 0 {
		c_local `returmac' 1
	}
	else {
		if ("`ind'"=="ind") local _efftype=1
		if ("`time'"=="time") local _efftype=2
		if ("`both'"=="both") local _efftype=3
		c_local `returmac' `_efftype' 		
	}	

end

/* ----------------------------------------------------------------- */

program define ParseIndirect
	args retumac retumac1 colon opts 

	local 0 ", `opts'"
	
	syntax [, INDirect NSIM(integer 500) * ]


	if `"`options'"' != "" {
		di as error "`options' not allowed"
		exit 198
	}

	c_local `retumac' `indirect'
	c_local `retumac1' `nsim'
	
end

/* ----------------------------------------------------------------- */

* version 1.0.0  25jun2009 from Stata 11.2
program _get_diopts, sclass
	/* Syntax:
	 * 	_get_diopts <lmacname> [<lmacname>] [, <options>]
	 *
	 * Examples:
	 * 	_get_diopts diopts, `options'
	 * 	_get_diopts diopts options, `options'
	 */

	local DIOPTS	Level(cilevel)		///
			vsquish			///
			ALLBASElevels		///
			NOBASElevels		/// [sic]
			BASElevels		///
			noCNSReport		///
			FULLCNSReport		///
			noOMITted		///
			noEMPTYcells		///
			COEFLegend		///
			SELEGEND

	syntax namelist(max=2) [, `DIOPTS' *]

	opts_exclusive "`baselevels' `nobaselevels'"
	opts_exclusive "`cnsreport' `fullcnsreport'"
	opts_exclusive "`coeflegend' `selegend'"
	local K : list sizeof namelist
	gettoken c_diopts c_opts : namelist

	if `K' == 1 & `:length local options' {
		syntax namelist(max=2) [, `DIOPTS']
	}

	if "`level'" != "`c(level)'" {
		local levelopt level(`level')
	}
	c_local `c_diopts'			///
			`levelopt'		///
			`vsquish'		///
			`allbaselevels'		///
			`baselevels'		///
			`cnsreport'		///
			`fullcnsreport'		///
			`omitted'		///
			`emptycells'		///
			`coeflegend'		///
			`selegend'

	if `K' == 2 {
		c_local `c_opts' `"`options'"'
	}
	
end

/* ----------------------------------------------------------------- */

* version 1.0.1  22aug2009 from Stata 11.2
program _post_vce_rank

	syntax, [CHecksize]

	/* use checksize option if it is possible to have a [0,0] e(V)
 	   matrix */

	if "`checksize'" != "" {
		tempname V
		capture matrix `V' = e(V)
		if _rc {
			exit
		}
		local cols = colsof(`V')
		if `cols' == 0 {
			exit
		}
	}
	tempname V Vi rank
	
	mat `V' = e(V)
	mat `Vi' = invsym(`V')
	sca `rank' = rowsof(`V') - diag0cnt(`Vi')
	
	mata:st_numscalar("e(rank)", st_numscalar("`rank'"))
	
end


/* ----------------------------------------------------------------- */

* version 1.0.3  10oct2011 from Stata 11.2 (sfpanel)
program define _parse_constraints, eclass

syntax, constraintslist(string asis) estparams(string asis) 

if "`constraintslist'"!="" {
	tempname b
	mat `b' = (`estparams')
	eret post `b'
	local colnames : colnames e(b)
	local colnames "`colnames' r"
	
		foreach cns of local constraintslist {
			constraint get `cns'
			
			if `r(defined)' != 0 {
				makecns `cns'
				if "`r(clist)'" == "" continue
				mat _CNS = nullmat(_CNS) \ get(Cns)	
		
			}
			else {
				di as err "Constraint `cns' is not defined."
			    error 198
			    exit
			}
		}
		mat colnames _CNS = `colnames'
	
}

end



exit



********************************** VERSION COMMENTS **********************************
* version 1.4.5 5jun2017  - fixed a bug that didn't allow for the proper use of aweight and iweight
* version 1.4.4 19dec2016 - fixed bug for dynamic models leading to conformability error of the bias_correction mata function
* version 1.4.3 12sep2016 - marginal effects standard errors can now be computed using delta-method. For this purpose the new -vceeffects()- option has been added
*						  - fix a bug affecting bias correction in dynamic models and marginal effects computation in dynamic models
*						  - now also covariances between direct, indirect and total effects are reported in e(V) 
* version 1.4.2 28jun2016 - forbidden dynamic random effects model. It deserves more checks and simulation
* version 1.4.1 27jun2016 - option -noeffects- removed. Now, option -effects- can be used to get direct, indirect and total effects
*						  - From now on -xsmle- is -margins- compliant. This can be very useful to get total effects and factor variables are used in the specification
* version 1.4.0 21jun2016 - dynamic model extended to exactly replicate Yu, De Jong and Lee (2008), bias correction included
*						  - Distinction between long- and short-run effects for dynamic models as in Elhorst (2014)
*						  - No effects if factor variables are used in the specification
* version 1.3.9 27may2016 - Fix -spmat- object weight matrix bug: now matrix limits are not important if -spmat- objects are used
* version 1.3.8 16mar2016 - Fix (again) a bug in the  -constraint()- option preventing multiple contraints 
*						  - Fix a display bug for RE models (sigma_e is actually sigma2_e)
* version 1.3.7 2may2014  - Fix the -constraint()- option bug
* version 1.3.6 12mar2014 - Version number sync between version of the pkg (SSC and econometrics.it) 
* version 1.3.5 13jul2013 - Hausman test, Time-Spatial clustering for e(V) and roblag(default) = floor(4*(5/100)^(2/9)) added
* version 1.3.4 13may2013 - Small-bug fixes: syntax errors
* version 1.3.3 18apr2013 - Small-bug fixes and factor variables full compatibility
* version 1.3.2 21mar2013 - Examples revised to distribute usaww.spmat
* version 1.3.1 12feb2013 - Check for banded matrices added
* version 1.3 23jan2013 - Small-bug fixes: syntax errors
* version 1.2 23nov2012 - Small-bug fixes: syntax errors
* version 1.1 20oct2012 - Small-bug fixes: syntax errors
* version 1.0.4 4apr2012 - Small-bug fixes: syntax errors
* version 1.0.3 15nov2011 - Small-bug fixes: syntax errors
* version 1.0.2 28sep2011 - Small-bug fixes: syntax errors
* version 1.0.1  20sep2011 - First version: merge between -spm- by fbapm and -xsmle- by gh 



