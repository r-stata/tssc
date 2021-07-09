program _lcauchyevaluator
version 12.0
	args lnf beta sigma
	tempvar eps
	qui gen double `eps' = ln($ML_y1) - `beta'
	qui replace `lnf'= -(log(_pi) + log(`sigma') + log(1 + ((`eps')/(`sigma'))^2))
end
