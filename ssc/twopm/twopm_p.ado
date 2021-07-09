*! version 1.0.5,  06Aug2013 - user must specify retransf method after twopm with regress, log
*! version 1.0.4,  8nov2011
*! version 1.0.3,  15oct2011
*! version 1.0.2  14nov2010
*! version 1.0.1,  09oct2010
*! authors: F.Belotti & P.Deb
*! Note: combined prediction does not take into account the e(sample) for the second part of the model 
*!       to be compliant with stata choice, while option scores take into account the e(sample) for the 
*!       second part of the model to get correct variance estimate with survey data and using margins

program define twopm_p, eclass
        version 11

    syntax [anything] [if] [in], [SCores NORMAL DUAN NOOFFset]
		
	*** Check for hetero retransf *** Undocumented
	mata: _go__ahead = 0
	cap mata: _go__ahead = (_het!="")
	mata: st_numscalar("_go__ahead",_go__ahead)
	mata: _go__ahead = .
	
	*** Marksample of predict
    marksample touse
	*** Marksample from twopm
	tempvar touse_twopm
	qui gen `touse_twopm' = (e(sample)==1)

	*** Parsing equation names
	local i = 1
	local eqnames "`e(eqnames)'"
	foreach n of local eqnames {	
		local eq`i': word `i' of `eqnames'
		local i=`i'+1
	}	

	*** Check prediction options
	if ("`normal'" != "" & "`duan'" != "") {
		di as error "normal and duan options are mutually exclusive."
			error 198
	}
	
	if "`eq2'" == "regress_log" & "`normal'`duan'" == "" & "`scores'"=="" {
		di as error "A retransformation method must be specified." 
		error 198
	}
		
	if "`normal'" != "" local retransform "normal"
	if "`duan'" != "" local retransform "duan"
	
	if "`eq2'" != "regress_log" & "`retransform'" != "" ///
		di as error "`retransform' option will be ignored."

	if "`scores'" != "" {
		_score_spec `0'
		local varn `s(varlist)'
		local vtyp `s(typlist)'
		
		local __i = 1
		foreach stubvar of local varn {
			if `__i' == 1 & "`eq1'" == "logit" {
				if "`e(offset_logit)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset_logit)'"
				qui logit_p `:word 1 of `vtyp'' `stubvar' if `touse_twopm' == 1 & `touse' == 1, eq(`eq1') scores
				label variable `stubvar' `"equation-level score:twopm (logit)"'
				if "`e(offset_logit)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset_logit)' for logit"
			}
			if `__i' == 1 & "`eq1'" == "probit" {
				if "`e(offset_probit)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset_probit)'"
				qui probit_p `:word 1 of `vtyp'' `stubvar' if `touse_twopm' == 1 & `touse' == 1, eq(`eq1') scores
				label variable `stubvar' `"equation-level score:twopm (probit)"'
				if "`e(offset_probit)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset_probit)' for probit"
			}
			if `__i' == 2 & "`=trim(regexr("`eq2'", "_log", ""))'" == "regress" {
				tempvar xb_`eq2'
				qui _predict double `xb_`eq2'' if `touse_twopm' == 1 & `touse' == 1 & `e(depvar)'>0, nooff eq(`eq2') xb
				if "`eq2'" == "regress_log" qui gen `:word `__i' of `vtyp'' `stubvar' = ln(`e(depvar)') - `xb_`eq2'' if `touse_twopm' == 1 & `touse' == 1  & `e(depvar)'>0
				else qui gen `:word `__i' of `vtyp'' `stubvar' = `e(depvar)' - `xb_`eq2'' if `touse_twopm' == 1 & `touse' == 1 & `e(depvar)'>0 
				qui replace `stubvar' = 0 if `stubvar' == .
				label variable `stubvar' `"equation-level score:twopm (`eq2')"'
			}
			if `__i' == 2 & "`eq2'" == "glm" {
					qui{
						if "`e(prefix)'"=="svy" {
							*** Here we save all glm estimation macros, scalars and matrices 
							*** to fit -margins- requirements 	
							local eret_scalar "N k k_eq k_eq_model k_dv k_autoCns df_r df_m df phi aic bic ll N_clust chi2 p deviance deviance_s deviance_p deviance_ps dispers dispers_s dispers_p dispers_ps nbml vf power rank ic rc converged"
							foreach element of local eret_scalar {
								tempname `element'_`eq2'
								if "`e(`element'_`eq2')'" != "" scalar ``element'_`eq2'' = e(`element'_`eq2')
								local eret_scalar_sp "`eret_scalar_sp' `element'_`eq2'"
							}

							local eret_macros "varfunc varfunct varfuncf link linkt linkf m offset chi2type cons hac_kernel hac_lag opt opt1 opt2 which ml_method user technique singularHmethod crittype properties predict asbalanced asobserved"	
							foreach element of local eret_macros {
								if "`e(`element'_`eq2')'" != "" local `element'_`eq2' "`e(`element'_`eq2')'"
								local eret_macros_sp "`eret_macros_sp' `element'_`eq2'"
							}

							*** Here we save all svy estimation macros, scalars and matrices 
							*** related to the second part of the model to fit -margins- requirements
							local ___strata = `e(N_strata)'
							tempname _N_sub _N_strata _N_strata_omit _singleton _census _N_pop _N_subpop _N_psu ///
							    _b _V _V_srs _V_srssub _V_srswr _V_srssubwr _V_modelbased _V_msp ///
								__N_strata_single __N_strata_certain __N_strata

							local ___svy_ereturn_scalars "N_sub N_strata N_strata_omit singleton census N_pop N_subpop N_psu"
							local ___svy_ereturn_macros "singleunit strata psu fpc poststrata postweight mse subpop wexp"
							forvalue k = 1/`___strata' {
								local ___svy_ereturn_macros = "`___svy_ereturn_macros' su`k' strata`k' fpc`k'"
							} 
							local ___svy_ereturn_matrices_join "V V_srs V_srssub V_srswr V_srssubwr V_modelbased V_msp" 
							local ___svy_ereturn_matrices_nojoin "_N_strata_single _N_strata_certain _N_strata"
							foreach ___svy_sca of local ___svy_ereturn_scalars {	
								if "`e(`___svy_sca')'" != "" scalar `_`___svy_sca'' = e(`___svy_sca')
							}
							foreach ___svy_loc of local ___svy_ereturn_macros {	
								if "`e(`___svy_loc')'" != "" local _`___svy_loc' = e(`___svy_loc') 
							}
							foreach ___svy_mat of local ___svy_ereturn_matrices_nojoin {	
								if "`e(`___svy_mat')'" != "" mat `_`___svy_mat'' = e(`___svy_mat') 
							}

							mat `_b' = e(b)
							mat `_b' = `_b'[1,"glm:"]

							foreach ___svy_mat of local ___svy_ereturn_matrices_join {	
								if "`e(`___svy_mat')'" != "" {
									mat `_`___svy_mat'' = e(`___svy_mat')
									mat `_`___svy_mat'' = `_`___svy_mat''["glm:", "glm:"]
								}
							}

							tempvar __esample 
							qui gen `__esample' = (`touse_twopm' == 1 & `touse' == 1 & `e(depvar)'>0)
							local __depvar "`e(depvar)'"

							qui est sto ___twopm

							eret post `_b' `_V', e(`__esample') depname(`__depvar')
							
							local ___svy_ereturn_scalars "_N_sub _N_strata _N_strata_omit _singleton _census _N_pop _N_subpop _N_psu"
							local ___svy_ereturn_macros "_singleunit _strata _psu _fpc _poststrata _postweight _mse _subpop _wexp"
							forvalue k = 1/`___strata' {
								local ___svy_ereturn_macros = "`___svy_ereturn_macros' _su`k' _strata`k' _fpc`k'"
							} 
							local ___svy_ereturn_matrices "_V_srs _V_srssub _V_srswr _V_srssubwr _V_modelbased _V_msp __N_strata_single __N_strata_certain __N_strata"
							foreach ___svy_sca of local ___svy_ereturn_scalars {
								local name = regexr("`___svy_sca'","^_","")	
								cap confirm scalar ``___svy_sca'' 
								if _rc == 0 eret scalar `name' = ``___svy_sca''
							}
							foreach ___svy_loc of local ___svy_ereturn_macros {	
								local name = regexr("`___svy_loc'","^_","")
								if "``___svy_loc''" != "" eret local `name' "``___svy_loc''" 
							}

							foreach ___svy_mat of local ___svy_ereturn_matrices {
								local name = regexr("`___svy_mat'","^_","")	
								cap confirm matrix ``___svy_mat'' 
								if _rc == 0 eret mat `name' = ``___svy_mat''
							}
							
							foreach name of local eret_scalar_sp {
								cap confirm scalar ``name''
							 	if _rc==0 {
									local truename = regexr("`name'", "_`eq2'", "")
									eret scalar `truename' = ``name''
								}
							}
							foreach name of local eret_macros_sp {
							 	if "``name''"!="" {
									local truename = regexr("`name'", "_`eq2'", "")
									eret local `truename' "``name''"
								}
							}							
							eret local cmd "glm"
							
							predict `:word `__i' of `vtyp'' `stubvar' if `touse_twopm' == 1 & `touse' == 1 & `e(depvar)'>0, `nooffset'  scores
							replace `stubvar' = 0 if `stubvar' == .
							label variable `stubvar' `"equation-level score:twopm (glm)"'
							qui est restore ___twopm
							if "`e(offset)'"!="" {
								if "`e(offset_glm)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset)' and `e(offset_glm)' for glm"
							}
							else {
								if "`e(offset_glm)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset_glm)' for glm"
							}
						}
						else {
							qui est sto ___twopm
							qui est restore ___glm 
							predict `:word `__i' of `vtyp'' `stubvar' if `touse_twopm' == 1 & `touse' == 1 & `e(depvar)'>0, `nooffset' scores
							replace `stubvar' = 0 if `stubvar' == .
							label variable `stubvar' `"equation-level score:twopm (glm)"'
							qui est restore ___twopm
							if "`e(offset)'"!="" {
								if "`e(offset_glm)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset)' and `e(offset_glm)' for glm"
							}
							else {
								if "`e(offset_glm)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset_glm)' for glm"
							}
						}
					}
			}
		local __i = `__i'+1	
		}
		cap est drop ___twopm
		cap est drop ___glm
		exit		
	}	
	

	gettoken 0 myopts: 0, parse(",")

    _pred_se "`myopts'" `0'
    if `s(done)' {
        exit
    }
    local vtyp  `s(typ)'
    local varn `s(varn)'
    local 0 `"`s(rest)'"'

	if "`eq2'" == "regress_log" {
	if "`retransform'" == "normal"  ///
		noi di as text "Lognormal retransformation under homoskedasticity"
	if "`retransform'" == "duan"  ///
		noi di as text "Duan-smearing retransformation under homoskedasticity"	
	}

    *** Compute predictions     
    CoMpUtE `"`vtyp'"' `varn' `eq1' `eq2' `touse' `retransform' `nooffset' 
	
end

program define CoMpUtE, eclass
        args vtyp varn eq1 eq2 cond retransform nooffset

	/* 
	vtyp: type of new variable
	varn: name of new variable
	cond: if & in, basically touse
	*/
	tempvar xb1 xb2 pr1 pr2
	
	*** 1st part
	if "`eq1'" == "logit" {
		if "`e(offset_logit)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset_logit)'"
		qui _predict double `xb1' if `cond', eq(`eq1')
		qui gen double `pr1' = invlogit(`xb1')
		if "`e(offset_logit)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset_logit)' for logit"
	}
	if "`eq1'" == "probit" {
		if "`e(offset_probit)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset_probit)'"
		qui _predict double `xb1' if `cond', eq(`eq1')
		qui gen double `pr1' = normal(`xb1')
		if "`e(offset_probit)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset_probit)' for probit"
	}
	
	*** 2nd part
	*** All families and link are allowed. This is useful for the next command -hurdle-
	*** It's better if -twopm- returns an error when is used with -glm- families other than gamma or gaussian and link other than: id, log, pow

	if "`eq2'" == "regress" {
		qui _predict double `pr2' if `cond', nooff eq(`eq2')
	}

	if "`eq2'" == "regress_log" {
		qui _predict double `xb2' if `cond', nooff eq(`eq2')
		
		if "`retransform'" == "normal" 	{
			if _go__ahead == 0 qui gen double `pr2' = exp(`xb2' + `e(sigma2)'/2)
		    else {
				tempvar smear1
				qui gen `smear1'=.
				mata: _get_retransf(_het, "`smear1'", 1)
				qui gen double `pr2' = exp(`xb2' + `smear1'/2)				
			}
		}		
		if "`retransform'" == "duan" 	{
			if _go__ahead == 0 qui gen double `pr2' = exp(`xb2') * `e(duan)'
		    else {
				tempvar smear2
				qui gen `smear2'=.
				mata: _get_retransf(_het, "`smear2'", 2)
				qui gen double `pr2' = exp(`xb2') * `smear2'				
			}
		}	
		if "`retransform'" == "notransf" qui gen double `pr2' = `xb2'
	}

	if "`eq2'" == "glm" {
		if "$SGLM_running" == "" {
			local drop drop	
			global SGLM_V	`"`e(varfunc_glm)'"'
			global SGLM_L	`"`e(link_glm)'"'
			global SGLM_A	// not used
			global SGLM_y	`"`e(depvar)'"'
			global SGLM_m	`"`e(m_glm)'"'
			global SGLM_a	`"`e(a_glm)'"'
			global SGLM_p	`"`e(power_glm)'"'
			global SGLM_f	// not used
			global SGLM_mu	// filled later
			global SGLM_s1 = `"`fam'"'=="glim_v2" | ///
				`"`fam'"'=="glim_v3" | `"`fam'"'=="glim_v6"
			global SGLM_ph	`e(phi)'
		}
		quietly {
			if "`e(offset_glm)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset_glm)'"
			tempvar eta mu
			_predict double `eta' if `cond', xb `nooffset' eq(`eq2')
			`e(link_glm)' 1 `eta' `mu'
			gen double `pr2' = `mu' if `cond'
			if "`e(offset)'"!="" {
				if "`e(offset_glm)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset)' and `e(offset_glm)' for glm"
			}
			else {
				if "`e(offset_glm)'"!="" & "`nooffset'"=="" qui eret local offset "`e(offset_glm)' for glm"
			}		
		}
		if "`drop'" != "" {
			macro drop SGLM_*
		}
	}
	
	*** Combined
	qui gen `vtyp' `varn' = `pr1' * `pr2' if `cond'
	label var `varn' "twopm combined expected values"
	
	cap scalar drop _go__ahead

end



//// Mata functions
/// FEDE: simple mataf for retransf

mata


struct _hetero {
	real vector sigma2, duan
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

Y, xb, resid

return(resid)

}


real matrix _get_retransf(struct _hetero vector _het,
    			   string scalar tempname,
				   real scalar retransf_type)
{

if (retransf_type == 1) st_store(., tempname, _het.sigma2)
if (retransf_type == 2) st_store(., tempname, _het.duan)

}


end








