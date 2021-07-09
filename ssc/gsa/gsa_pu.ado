program define gsa_pu

	version  9
	syntax varlist [if] [in], c1(real) c2(real) [gsa_pu_precision(real .99)]
	*	order of varlist is "t X"
	
	marksample touse
	gettoken t X :varlist
	tempvar utilde pseudo_u hat_temp hat_tu
	tempname mat_B_tu scl_hat_alpha	
	local nvar_sub1 = scalar(nvar_sub1)
	
	forvalues z = 1/99999 {
		capture drop `utilde'
		gen `utilde' = `c1'*res_to + `c2'*res_yo + rnormal() if `touse'
		reg `utilde' `X' if `touse'
		capture drop `pseudo_u'
		predict `pseudo_u' if `touse', resid			

		*	CALCULATING rho_hto_htu TO CHECK THE ORTHOGONALITY OF U TO X
		reg `t' `X' `pseudo_u' if `touse'
		capture drop `hat_temp'
		predict `hat_temp' if `touse', xb
		matrix `mat_B_tu' = e(b)
		scalar `scl_hat_alpha' = `mat_B_tu'[1,`nvar_sub1']
		capture drop `hat_tu'
		gen `hat_tu' = `hat_temp' - `scl_hat_alpha'*`pseudo_u' if `touse'
		cor hat_to `hat_tu' if `touse'
		if r(rho)>`gsa_pu_precision' {
			capture drop gsa_pseudo_u
			egen gsa_pseudo_u = std(`pseudo_u') if `touse'
			continue, break
		}
	}
end
