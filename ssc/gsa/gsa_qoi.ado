program define gsa_qoi

	version  9
	syntax varlist [if] [in], [vce(passthru)] [YLOGIT] [YPROBIT] [YLPM] [YCONTinuous] [LOGIT] [PROBIT] [LPM] [CONTinuous] [BINU]

	marksample touse
	gettoken u rhs :varlist
	gettoken t X :rhs
	
	tempvar res_tu res_utx res_ux
	tempname scl_sigma_sqyu mat_subB_yu mat_subV_yu mat_VAR_yu scl_var_yu scl_rsq_yu mat_B_tu ///
	mat_V_tu scl_sigma_sqtu mat_subB_tu mat_subV_tu mat_VAR_tu scl_var_tu scl_rsq_tu

	
	*	CALCULATING THE NUMBER OF VARIABLES
	local nvar = 0
	foreach var in `varlist' {		/* #varlist = u t X = y t X, u t X can be u t X or k t X_k */
		local nvar = `nvar'+1
	}
	local nvar_sub1 = `nvar'-1	
	local nvar_sub2 = `nvar'-2

	
	*	CALCULATING PARTIAL R-SQUARES OF "UNOBSERVABLE MODEL" & "OUTCOME EQ."		/* ADDED IN V21 */
	if "`ycontinuous'" != "" | "`ylpm'" != "" {	
		sum res_yu if `touse'
		scalar `scl_sigma_sqyu' = r(Var)
		scalar scl_partial_rsq_y = abs((scl_sigma_sqyo - `scl_sigma_sqyu')/scl_sigma_sqyo)
	}
	
	if "`ylogit'" != "" {

		qui cor `u' `t' if `touse', covariance
		scalar scl_covUT = r(cov_12)

		matrix `mat_subB_yu' = J(1, `nvar_sub1', .)				/* #var = nvar-1 b/c mat = t X */
		forvalues c = 1/`nvar_sub1' {
			matrix `mat_subB_yu'[1, `c'] = mat_B_yu[1, `c']
		}

		qui cor `rhs' if `touse', cov
		matrix `mat_subV_yu' = r(C)
		
		matrix `mat_VAR_yu' = `mat_subB_yu'*`mat_subV_yu'*`mat_subB_yu''
		scalar `scl_var_yu' = `mat_VAR_yu'[1,1]
		if "`binu'" != ""{
			scalar `scl_rsq_yu' = (`scl_var_yu' + scl_delta^2/4 + 2 * scl_b_tau_u * scl_delta * scl_covUT)/(`scl_var_yu' + scl_delta^2/4 + 2 * scl_b_tau_u * scl_delta * scl_covUT + _pi^2/3)
		}
		else {
			scalar `scl_rsq_yu' = (`scl_var_yu' + scl_delta^2 + 2 * scl_b_tau_u * scl_delta * scl_covUT)/(`scl_var_yu' + scl_delta^2 + 2 * scl_b_tau_u * scl_delta * scl_covUT + _pi^2/3)
		}
		scalar scl_partial_rsq_y = (`scl_rsq_yu' - scl_rsq_yo)/(1-scl_rsq_yo)			/* can be abs */

	}

	*	CALCULATING PARTIAL R-SQUARES OF "UNOBSERVABLE MODEL" & "TREATMENT EQ."
	if "`continuous'" != "" | "`lpm'" != "" {	
		reg `rhs' `u' if `touse', `vce'
		matrix `mat_B_tu' = e(b)
		matrix `mat_V_tu' = e(V)
		capture drop `res_tu'
		predict `res_tu' if `touse', resid		
		sum `res_tu' if `touse'
		scalar scl_alpha = `mat_B_tu'[1,`nvar_sub1']
		scalar `scl_sigma_sqtu' = r(Var)
		scalar scl_partial_rsq_t = abs((scl_sigma_sqto - `scl_sigma_sqtu')/scl_sigma_sqto)	/* can be abs */
	}

	if "`logit'" != "" {
		logit `rhs' `u' if `touse', `vce'
		matrix `mat_B_tu' = e(b)
		matrix `mat_V_tu' = e(V)
		matrix `mat_subB_tu' = J(1, `nvar_sub2', .)
		forvalues c = 1/`nvar_sub2' {
			matrix `mat_subB_tu'[1, `c'] = `mat_B_tu'[1, `c']
		}

		qui cor `X' if `touse', cov
		matrix `mat_subV_tu' = r(C)
		
		scalar scl_alpha = `mat_B_tu'[1,`nvar_sub1']
		matrix `mat_VAR_tu' = `mat_subB_tu'*`mat_subV_tu'*`mat_subB_tu''
		scalar `scl_var_tu' = `mat_VAR_tu'[1,1]
		if "`binu'" != ""{
			scalar `scl_rsq_tu' = (`scl_var_tu' + scl_alpha^2/4)/(`scl_var_tu' + scl_alpha^2/4 + _pi^2/3)
		}
		else {
			scalar `scl_rsq_tu' = (`scl_var_tu' + scl_alpha^2)/(`scl_var_tu' + scl_alpha^2 + _pi^2/3)
		}
		scalar scl_partial_rsq_t = abs((`scl_rsq_tu' - scl_rsq_to)/(1-scl_rsq_to))
	}

	if "`probit'" != "" {
		probit `rhs' `u' if `touse', `vce'
		matrix `mat_B_tu' = e(b)
		scalar scl_alpha = `mat_B_tu'[1,`nvar_sub1']
	}

	
	*	CALCULATING PARTIAL CORRELATION OF "UNOBSERVABLE MODEL" & "OUTCOME EQ."
	reg `varlist' if `touse', `vce'
	capture drop `res_utx'
	predict `res_utx' if `touse', resid
	cor res_yo `res_utx' if `touse'
	scalar scl_rho_res_yu = abs(r(rho))
	
	*	CALCULATING PARTIAL CORRELATION OF "UNOBSERVABLE MODEL" & "TREATMENT EQ."	
	reg `u' `X' if `touse', `vce'
	capture drop `res_ux'
	predict `res_ux' if `touse', resid
	cor res_to2 `res_ux' if `touse'
	scalar scl_rho_res_tu = abs(r(rho))

end
				