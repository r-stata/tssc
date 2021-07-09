*! version 1.0 20jun2013
*! version 1.0.1 27jun2013 Some bug fixes. Now -tihtest- works for both stata 11 and 12

program define tihtest, rclass byable(onecall) prop(xt /*svyb svyj swml*/)

    if _by() {
        local BY `"by `_byvars'`_byrc0':"'
    }

    version 11
                
        if replay() {
            if _by() { 
                error 190 
            }
            if "`r(cmd)'" != "tihtest" {
                error 301
            }
                DiSpLaY `0'
                exit
            }
		
    if _by() {
        by `_byvars' `_byrc0': tihtest_est `0'
    }       
    else tihtest_est `0'
    version 11: return local cmdline `"tihtest `0'"'
	return add
end



program define tihtest_est, rclass byable(recall) sortpreserve

version 11
syntax varlist(min=2 fv ts) [if] [in] [aweight fweight pweight/] , [ Model(string)   ///
                        VCE(passthru) CLuster(passthru) Robust Level(cilevel) ///
						FROM(string) DISPLAYestimates ///
                        TECHnique(string) ITERate(integer 100) NOWARNing DIFFICULT NOLOG ///
                        TRace GRADient SHOWSTEP HESSian SHOWTOLerance TOLerance(real 1e-6) ///
                        LTOLerance(real 1e-7) NRTOLerance(real 1e-5) ///
                        NOSEARCH REPEAT(integer 10) RESTART RESCale POSTSCORE POSTHESSian *] 


local vv : di "version " string(max(11,c(stata_version))) ", missing:"
local __cmdline "`0'"

/// Manage Mata function according to Stata version
local __version = round(c(stata_version))
	
*** Check for Panel setup                             
_xt, trequired

*** Marksample:
marksample touse, strok

*** Parsing of display options
_get_diopts diopts options, `options'

*** Parsing model
ParseMod model : `"`model'"'

*** Fixed effects: we do not allow for constant term 
local noconstant "noconstant"

*** Display results behavior
if "`displayestimates'"=="" local nolog "nolog"

*************** Errors ************* 
/*   
if "`model'"=="tfe" & "`nocons'"!="" {
    noi di as err "nocons option not allowed with tfe model."
    error 198
    exit
}
*/

***********************************************************************************************************************
******* Assigns objects to correctly create _InIt_OpTiMiZaTiOn() and _PoSt_ReSuLt_of_EsTiMaTiOn() structures **********
***********************************************************************************************************************

*** Locals 
if "`technique'"=="" local technique "nr"
if "`difficult'"!="" local difficult "hybrid"
else local difficult "m-marquardt"
if "`nowarning'"!="" local nowarning "on"
else local nowarning "off"
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
if "`nosearch'"!="" local nosearch "off"
else local nosearch "on"
if "`restart'"!="" local restart "on"
else local restart "off"
if "`rescale'"!="" | "`model'"=="kumb90" local rescale "on"
else local rescale "off"
/// Svy is currently disabled for panel data SF
//if "`r(wvar)'"!="" local InIt_svy "on"
//else local InIt_svy "off"
if "`exp'`weight'" != "" local weighted_est "on"
else local weighted_est "off"
if "`constraints'" != "" local constrained_est "on"
else local constrained_est "off"


*** Scalars
scalar TOLerance = `tolerance'
scalar LTOLerance = `ltolerance'
scalar NRTOLerance = `nrtolerance'
scalar MaXiterate = `iterate'
scalar REPEAT = `repeat'
scalar CILEVEL = `level'

************** Tokenize from varlist ***************
gettoken lhs rhs: varlist
****************************************************

**************************************************************************************************************
**************** Check for panel setup and perform checks necessary for weighted estimation ******************
**************************************************************************************************************
     
    *** Check for panel setup                
	_xt, trequired 
	local id: char _dta[_TSpanel]
	local time: char _dta[_TStvar]
	tempvar temp_id temp_t Ti
	qui egen `temp_id'=group(`id') if `touse'==1
	sort `temp_id' `time'
	qui by `temp_id': g `temp_t' = _n if `temp_id'!=.

	qui xtset 
	if "`r(balanced)'" != "strongly balanced" {
		di as error "The panel data must be strongly balanced"
		error 459
	}
		
	********************** Display info ********************** 
	tempvar Ti T_new
	tempname g_min g_avg g_max N_g N Tcon Tbar
	sort `temp_id' `temp_t'
	qui by `temp_id': gen long `Ti' = _N if _n==_N & `touse'==1
	qui summ `Ti' if `touse'==1, mean

	*** Check for number of time occasion in tfe, fe, fels and fecss models
	if (r(min) == 1) {
		di in yel "Warning: only units with more than 1 time occasion will be considered"
		tempvar _newtouse _maxTi_
		qui by `temp_id': egen `_maxTi_' = max(`Ti')
		qui gen `_newtouse' = `touse' if `_maxTi_'!=1
		markout `touse' `_newtouse'
	}

	qui summ `Ti' if `touse'==1, mean
	scalar `Tcon' = (r(min)==r(max))
	scalar `g_min' = r(min)
	scalar `g_avg' = r(mean)
	scalar `g_max' = r(max)
	qui count if `Ti'<. & `touse'==1
	scalar `N_g' = r(N)
	qui by `temp_id' : gen double `T_new' = 1/_N if _n==_N & `touse'==1
	qui summ `T_new'
	scalar `Tbar' = 1/r(mean)
	qui drop `T_new'
	
	local lxtset "`temp_id' `temp_t'"
	
	*** Set up weights
	if "`weight'" != "" local __equal "="

***********************************************************************
*** Get temporary variable names and perform Factor Variables check ***
***********************************************************************
*** (Note: Also remove base collinear variables if fv are specified)

	local fvops = "`s(fvops)'" == "true" 
	if `fvops'==1 {
	   local vv_fv : di "version " string(max(11,`c(version_rng)')) ", missing:"	   
	   ********* Factor Variables parsing ****
	   `vv_fv' _fv_check_depvar `lhs'	   
	   local fvars "rhs"
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

*** Test for missing values in dependent and independent variables
	local __check_missing "`lhs' `rhs'"
  	egen _tihtest_missing_obs=rowmiss(`__check_missing')
  	quietly sum _tihtest_missing_obs
  	drop _tihtest_missing_obs
  	local nobs=r(N)
  	local nmissval=r(sum)
  	if `nmissval' > 0 {
    	display as error "The panel data must be strongly balanced with no missing values"
    	error 198
  	}

/* Check if weight is constant within panel */
if "`weight'" != "" {
	sort `temp_id'
	tempvar _tihtest_weight_sd
	qui by `temp_id': egen `_tihtest_weight_sd'=sd(`exp')
	sum `_tihtest_weight_sd', mean
	local panel_sd_max=r(max)
	if `panel_sd_max' > 0 & `panel_sd_max'!=. {
		display as error "Weights must be constant within panels"
		error 198
	}
	if `panel_sd_max' == . {
		display as error "The dataset in memory is not a panel dataset."
		error 198		
	}
}
	
*** Parsing vce options

	local crittype "Log-likelihood"
	
	cap _vce_parse, opt(OIM Robust) old	///
	: [`weight' `__equal' `exp'], `vce' `robust'
	
	if _rc == 0 {
		local vce "`r(vce)'"
		if "`vce'" == "" local vce "oim"
		/*if "`vce'"=="cluster" {
			local vcetype "Robust"
			local clustervar "`r(cluster)'"
			local crittype "Log-pseudolikelihood"
		}*/
		if "`vce'"=="robust" {
			local vce "robust"
			local vcetype "Robust"
			local clustervar "`id'"
			local crittype "Log-pseudolikelihood"
		}
		*if "`vce'"=="opg" local vcetype "OPG"	
	}

*** Remove collinearity
	_rmcollright `rhs' if `touse' [`weight' `__equal' `exp'], `noconstant' 	
	local rhs "`r(varlist)'"
	if `fvops'==0 local _rhs_names "`rhs'"
	local _k_final: word count `_rhs_names'
	qui count if `touse'==1
	scalar `N' = r(N)

***************************************************************************

if "`model'"=="clogit" {

		tempname init_beta 					
		if "`from'"=="" {
			cap qui logit `lhs' `rhs', nocons iter(50)
			if _rc != 0 qui reg `lhs' `rhs', nocons
			mat `init_beta' = e(b)
			`vv' mat colnames `init_beta' =`_rhs_names'
			`vv' mat coleq `init_beta' = "Clogit"
		}
		else {
			`vv' mat colnames `init_beta' = `_rhs_names' 
			`vv' mat coleq `init_beta' = "Clogit"
			local arg `from'
			`vv' _mkvec `init_beta', from(`arg') update error("from()")
		}
		eret clear
		
		******************** This block MUST be included for each estimator ***********************
		local _params_list "init_beta"
		local _params_num = 1
		scalar InIt_nparams = wordcount("`_params_list'")
		/// Structure definition for initialisation
		mata: _tihtest_SV = J(1, st_numscalar("InIt_nparams"), _tihtest_starting_values`__version'())
		foreach _params of local _params_list {
			mata: _tihtest_SV = _tihtest_StArTiNg_VaLuEs`__version'("``_params''", `_params_num', _tihtest_SV)	
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_tihtest_SV)
			local _params_num = `_params_num' + 1
		}		
		local InIt_evaluator "clogit"
		local InIt_evaluatortype "gf2"	
		*** Get numb of categories 
		qui levelsof `lhs', l(_lncat)
		scalar _ncat = `:word count `_lncat''
		*** Collect InIt options and args	
		mata: _tihtest_InIt_OpT = _tihtest_InIt_OpTiMiZaTiOn`__version'()
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_tihtest_InIt_OpT)
		*******************************************************************************************	
			
} // Close model option

if "`model'"=="cologit" {

		tempname init_beta 					
		if "`from'"=="" {
			cap qui ologit `lhs' `rhs', iter(50)
			if _rc != 0 {
				qui reg `lhs' `rhs', nocons
				mat `init_beta' = e(b)
			}
			else {
				mat `init_beta' = e(b)
				mat `init_beta' = `init_beta'[1,"`lhs':"]
			}
	
			`vv' mat colnames `init_beta' =`_rhs_names'
			`vv' mat coleq `init_beta' = "Cologit"
		}
		else {
			`vv' mat colnames `init_beta' = `_rhs_names' 
			`vv' mat coleq `init_beta' = "Cologit"
			local arg `from'
			`vv' _mkvec `init_beta', from(`arg') update error("from()")
		}
		eret clear
		
		******************** This block MUST be included for each estimator ***********************
		local _params_list "init_beta"
		local _params_num = 1
		scalar InIt_nparams = wordcount("`_params_list'")
		/// Structure definition for initialisation
		mata: _tihtest_SV = J(1, st_numscalar("InIt_nparams"), _tihtest_starting_values`__version'())
		foreach _params of local _params_list {
			mata: _tihtest_SV = _tihtest_StArTiNg_VaLuEs`__version'("``_params''", `_params_num', _tihtest_SV)	
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_tihtest_SV)
			local _params_num = `_params_num' + 1
		}	
		local InIt_evaluator "cologit"
		local InIt_evaluatortype "gf2"
		*** Get numb of categories 
		qui levelsof `lhs', l(_lncat)
		scalar _ncat = `:word count `_lncat''
		*** Collect InIt options and args	
		mata: _tihtest_InIt_OpT = _tihtest_InIt_OpTiMiZaTiOn`__version'()
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_tihtest_InIt_OpT)
		*******************************************************************************************	
			
} // Close model option

if "`model'"=="cpoisson" {

		tempname init_beta 					
		if "`from'"=="" {
			cap qui poisson `lhs' `rhs', nocons iter(50)
			if _rc != 0 qui reg `lhs' `rhs', nocons
			mat `init_beta' = e(b)
			`vv' mat colnames `init_beta' =`_rhs_names'
			`vv' mat coleq `init_beta' = "Cpoisson"
		}
		else {
			`vv' mat colnames `init_beta' = `_rhs_names' 
			`vv' mat coleq `init_beta' = "Cpoisson"
			local arg `from'
			`vv' _mkvec `init_beta', from(`arg') update error("from()")
		}
		eret clear
		
		******************** This block MUST be included for each estimator ***********************
		local _params_list "init_beta"
		local _params_num = 1
		scalar InIt_nparams = wordcount("`_params_list'")
		/// Structure definition for initialisation
		mata: _tihtest_SV = J(1, st_numscalar("InIt_nparams"), _tihtest_starting_values`__version'())
		foreach _params of local _params_list {
			mata: _tihtest_SV = _tihtest_StArTiNg_VaLuEs`__version'("``_params''", `_params_num', _tihtest_SV)	
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_tihtest_SV)
			local _params_num = `_params_num' + 1
		}		
		local InIt_evaluator "cpoisson"
		local InIt_evaluatortype "gf2"	
		*** Collect InIt options and args	
		mata: _tihtest_InIt_OpT = _tihtest_InIt_OpTiMiZaTiOn`__version'()
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_tihtest_InIt_OpT)
		*******************************************************************************************	
			
} // Close model option

if "`model'"=="cnormal" { 

	qui {	
			tempvar mean_`lhs' dem_`lhs' 
			by `temp_id': egen double `mean_`lhs'' = mean(`lhs')
			gen double `dem_`lhs'' = `lhs' - `mean_`lhs''
			local demrhs ""
			foreach var of local rhs {
				tempvar mean_`var' dem_`var'
				by `temp_id': egen double `mean_`var'' = mean(`var')
				gen double `dem_`var'' = `var' - `mean_`var''
				local demrhs "`demrhs' `dem_`var''"
			}
			
			tempvar diff_`lhs' 
			xtset
			gen double `diff_`lhs'' = d.`lhs'
			local diff_rhs ""
			foreach var of local rhs {
				tempvar diff_`var'
				gen double `diff_`var'' = d.`var'
				local diff_rhs "`diff_rhs' `diff_`var''"
			}
			marksample dtouse
			markout `dtouse' `diff_`lhs'' `diff_rhs'
	}
	
	tempname init_beta init_sigma2				
	if "`from'"=="" { 
		qui reg `dem_`lhs'' `demrhs', nocons 
		mat `init_beta' = e(b)
		`vv' mat colnames `init_beta' =`_rhs_names'
		`vv' mat coleq `init_beta' = "Cnormal"
		mat `init_sigma2' = e(rmse)^2
		`vv' mat colnames `init_sigma2' = _cons
		`vv' mat coleq `init_sigma2' = "Sigma2"
	}
	else {
		`vv' mat colnames `init_beta' = `_rhs_names' 
		`vv' mat coleq `init_beta' = "Cnormal"
		local arg `from'
		`vv' _mkvec `init_beta', from(`arg') update error("from()")
	}
	eret clear
	
	******************** This block MUST be included for each estimator ***********************
	local _params_list "init_beta init_sigma2"
	local _params_num = 1
	scalar InIt_nparams = wordcount("`_params_list'")
	/// Structure definition for initialisation
	mata: _tihtest_SV = J(1, st_numscalar("InIt_nparams"), _tihtest_starting_values`__version'())
	foreach _params of local _params_list {
		mata: _tihtest_SV = _tihtest_StArTiNg_VaLuEs`__version'("``_params''", `_params_num', _tihtest_SV)	
		** The following to check the content of the structure ** Just for debugging
		*mata: liststruct(_tihtest_SV)
		local _params_num = `_params_num' + 1
	}		
	local InIt_evaluator "cnormal"
	local InIt_evaluatortype "gf0"	
	*** Collect InIt options and args	
	mata: _tihtest_InIt_OpT = _tihtest_InIt_OpTiMiZaTiOn`__version'()
	** The following to check the content of the structure ** Just for debugging
	*mata: liststruct(_tihtest_InIt_OpT)
	*******************************************************************************************
	
} // Close model option

if "`model'"!="cnormal" local evarlist "`lhs' `rhs'"
else {
	local evarlist "`dem_`lhs'' `demrhs'"
	local devarlist "`diff_`lhs'' `diff_rhs'"
}


///////////////////////////////////////////////////////////////////
////////////////////////// Estimation /////////////////////////////
///////////////////////////////////////////////////////////////////
	
	*** Collect post-results options
	mata: _tihtest_PoSt_OpT = _tihtest_InIt_PoSt_ReSuLt`__version'()
	*mata: liststruct(_tihtest_PoSt_OpT)
	*** Get Data
	mata: _tihtest_DaTa = _tihtest_GeT_dAtA`__version'("`evarlist'", "`touse'", "`lxtset'", "`model'", "`devarlist'", "`dtouse'")
	*** Estimation
	noi di ""
	noi mata: _tihtest_Results = _tihtest_est`__version'("`model'", _tihtest_DaTa, _tihtest_SV, _tihtest_InIt_OpT, _tihtest_PoSt_OpT)

///////////////// Display results /////////////////
return clear
return local cmd "tihtest"
return local depvar "`lhs'"
return local model "`model'"
return local ivar `id'
return local tvar `time'  
return local covariates "`_rhs_names'" 
return scalar Tbar = `Tbar'
return scalar Tcon = `Tcon'
return scalar g_min = `g_min'
return scalar g_avg = `g_avg'
return scalar g_max = `g_max'
return scalar N_g = `N_g'
return scalar N = `N'
return scalar p = chi2tail(df,stat)
return scalar stat = stat
return scalar df = df

if "`displayestimates'"!="" {
	
	if "`model'"!= "cnormal" {
		mat colnames b = `_rhs_names' `_rhs_names'
		mat colnames V = `_rhs_names' `_rhs_names'
		mat rownames V = `_rhs_names' `_rhs_names'
		
		foreach __estimator in Full Pairwise {
			forvalues __i = 1/`_k_final' {
				local __colnames "`__colnames' `__estimator'"
			}
		}
		mat coleq b = `__colnames'
		mat coleq V = `__colnames' 
		mat roweq V = `__colnames'
	}
	else {
		mat colnames b = `_rhs_names' sigma_e2 `_rhs_names' sigma_e2
		mat colnames V = `_rhs_names' sigma_e2 `_rhs_names' sigma_e2
		mat rownames V = `_rhs_names' sigma_e2 `_rhs_names' sigma_e2
		
		local _k_finalnorm = `_k_final'+1
		foreach __estimator in Full Pairwise {
			forvalues __i = 1/`_k_finalnorm' {
				local __colnames "`__colnames' `__estimator'"
			}
		}
		mat coleq b = `__colnames'
		mat coleq V = `__colnames' 
		mat roweq V = `__colnames'			
	}

	if "`model'"=="clogit" local title "Fixed-effects logit"
	if "`model'"=="cologit" local title "Fixed-effects Ordered logit"
	if "`model'"=="cpoisson" local title "Fixed-effects Poisson"
	if "`model'"=="cnormal" local title "Fixed-effects Gaussian linear"

	DiSpLaY, level(`level') model(`model') depvar(`lhs') covariates(`rhs') title(`title') ///
			 nobs(`N') esample(`touse') ivar(`id') tvar(`time') ///
			 gmin(`g_min') gavg(`g_avg') gmax(`g_max') ngroups(`N_g') retvce(`vce') ///
			 retvcetype(`vcetype') retcmdline(`__cmdline') `postscore' `posthessian' `diopts' 
	
}

di ""
di in gr "Bartolucci-Belotti-Peracchi test for time invariant heterogeneity" 
di in gr "    Ho: " in yel "time invariant heterogeneity"
di in gr "	  Outcome variable: " in yel "`model'"
di in gr "	  Model specification: " in yel "`lhs' = `_rhs_names'"
di ""
di in gr "    chi2(" in yel df in gr ") = " in yel %9.2f stat
di in gr "    Prob > chi2 = " in yel %6.4f  chi2tail(df,stat)
if "`model'" == "cnormal" {
di ""
di "Note: the test is performed excluding sigma_e2"	
}
__tietest_destructor
        
end



program define DiSpLaY, eclass
        syntax [, Level(cilevel) model(string) depvar(string) covariates(string) ///
				  title(string) nobs(string) esample(string) ivar(string) tvar(string) ///
				  gmin(string) gavg(string) gmax(string) ngroups(string) retvce(string) ///
				  retvcetype(string) retcmdline(string) postscore posthessian *]
				
		_get_diopts diopts, `options' 
		
		local _nobs = `nobs'
		local _esample = `esample'
		local _gmin = `gmin'
		local _gavg = `gavg'
		local _gmax = `gmax'
		local _ngroups = `ngroups'
		
		#delimit ;
		di as txt _n "`title' model" _col(54) "Number of obs " _col(68) "=" /*
 		*/ _col(70) as res %9.0g `_nobs';
        di in gr "Group variable: " in ye abbrev("`ivar'",12) 
           in gr _col(51) "Number of groups" _col(68) "="
                 _col(70) in ye %9.0g `_ngroups';
        di in gr "Time variable: " in ye abbrev("`tvar'",12)                    
           in gr _col(55) in gr "Panel length" _col(68) "="
                 _col(70) in ye %9.0g `_gmax' _n;
        /*di       _col(64) in gr "avg" _col(68) "="
                 _col(70) in ye %9.1f `e(g_avg)' ;
        di       _col(64) in gr "max" _col(68) "="
                 _col(70) in ye %9.0g `e(g_max)' _n */;				                            
		#delimit cr
		
		eret clear
		ereturn post b V, esample(`esample') obs(`_nobs') dep(`lhs')
		ereturn local cmd "tihtest"
		eret local cmdline "`retcmdline'"
		ereturn local model "`model'"
		ereturn local ivar "`ivar'"
		ereturn local tvar "`tvar'"  
		ereturn local covariates "`rhs'" 
		ereturn local vce "`retvce'"
		if "`retvcetype'"!="" ereturn local vcetype "`retvcetype'"
		ereturn local title "`title' model"
		ereturn local title "`title' model"
		ereturn scalar g_min = `_gmin'
		ereturn scalar g_avg = `_gavg'
		ereturn scalar g_max = `_gmax'
		ereturn scalar N_g = `_ngroups'
		if "`postscore'"!="" {
			ereturn matrix score_full = _score1
			ereturn matrix score_pair = _score2
		}
		if "`posthessian'"!="" {
			ereturn matrix hessian_full = _hessian1
			ereturn matrix hessian_pair = _hessian2
		}
				
		_coef_table, neq(2)


end


/* ----------------------------------------------------------------- */

program define ParseMod
	args returmac colon model

	local 0 ", `model'"
	syntax [, CLOGit COLOGit CPOISson CNORMal * ]

	if `"`options'"' != "" {
		di as error "model(`options') not allowed"
		exit 198
	}
	
	local wc : word count `clogit' `cologit' `cpoisson' `cnormal'

	if `wc' > 1 {
		di as error "model() invalid, only " /*
			*/ "one model can be specified"
		exit 198
	}

	if `wc' == 0 {
		c_local `returmac' cnormal
	}
	else	c_local `returmac' `clogit'`cologit'`cpoisson'`cnormal' 

end




program define __tietest_destructor
syntax

/// Destructor
local _scalars "MaXiterate TOLerance LTOLerance NRTOLerance REPEAT InIt_nparams _ncat df stat CILEVEL"
foreach n of local _scalars {
	cap scalar drop	`n'
}
local _matrices "_score1 _score2 _hessian1 _hessian2"
foreach n of local _matrices {
	cap matrix drop	`n'
}
// DROP structures
//capture mata: mata drop _tihtest_PoSt_OpT _tihtest_SV

end


exit 
