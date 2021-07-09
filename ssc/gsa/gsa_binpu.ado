program define gsa_binpu

	version  9
	syntax varlist [if] [in], c1(real) c2(real) [gsa_binpu_precision(real .99)]
	*	order of varlist is "t X"
	
	marksample touse
	gettoken t X :varlist
	tempvar utilde ucont pseudo_u hat_temp hat_tu
	tempname scl_median mat_B_tu scl_hat_alpha	
	local nvar_sub1 = scalar(nvar_sub1)
	
	forvalues z = 1/99999 {
		capture drop `utilde'
		gen `utilde' = `c1'*res_to + `c2'*res_yo + rnormal() if `touse'
		reg `utilde' `X' if `touse'
		capture drop `ucont'
		predict `ucont' if `touse', resid
		sum `ucont' if `touse', det
		scalar `scl_median' = r(p50)
		capture drop `pseudo_u'
		gen `pseudo_u' = . if `touse'
		replace `pseudo_u' = 1 if `ucont' >= `scl_median' & `touse'
		replace `pseudo_u' = 0 if `ucont' < `scl_median' & `touse'
		
		*	CALCULATING rho_hto_htu TO CHECK THE ORTHOGONALITY OF U TO X
		reg `t' `X' `pseudo_u' if `touse'
		capture drop `hat_temp'
		predict `hat_temp' if `touse', xb
		matrix `mat_B_tu' = e(b)
		scalar `scl_hat_alpha' = `mat_B_tu'[1,`nvar_sub1']
		capture drop `hat_tu'
		gen `hat_tu' = `hat_temp' - `scl_hat_alpha'*`pseudo_u' if `touse'
		cor hat_to `hat_tu' if `touse'

		if r(rho)>`gsa_binpu_precision' {
			capture drop gsa_pseudo_u
			gen gsa_pseudo_u = `pseudo_u' if `touse'
			continue, break
		}
		if r(rho)<`gsa_binpu_precision' & `z'==10000 {
			noisily display ""
			noisily display as error "-gsa- is having a hard time in generating a binary pseudo unobservable."
		}
		if `z'==99999 {
			noisily display ""
			noisily display as error "Error: gsa_binpu_precision() might be too high. Try setting gsa_binpu_precision(.975) for example."
			exit					
		}
	}

end
