program drm_probit_ll	
	args lnfj row col $DRMSETOFP $DRMSETOFQ $DRMRHO xb 
	tempvar mu
	if "$DRMINTERVARS" != "" {
		local interaction_plus "+(`rho')"
		local interaction_minus "-(`rho')"
	}
	if "$DRMWGTVAR" != "" {
		local nDRMSETOFP: word count $DRMSETOFP
		forvalues i=1(1)`nDRMSETOFP' {
			local pcurrent: word `i' of  $DRMSETOFP 
			local qcurrent: word `i' of  $DRMSETOFQ 			
			if `i' == 1	qui gen double	`mu' = ((``pcurrent'')`interaction_plus')*(`row') + ((``qcurrent'')`interaction_minus')*(`col') + `xb' if $DRMWGTVAR == `i'			
			else		qui replace		`mu' = ((``pcurrent'')`interaction_plus')*(`row') + ((``qcurrent'')`interaction_minus')*(`col') + `xb' if $DRMWGTVAR == `i'	
		}
	}
	else qui gen double `mu' = ((`p')`interaction_plus')*(`row') + ((`q')`interaction_minus')*(`col') + `xb'	
	quietly replace `lnfj' = ln(normal(`mu')) if $ML_y1 == 1
	quietly replace `lnfj' = ln(normal(-`mu')) if $ML_y1 == 0	
end
