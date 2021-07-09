*capture program drop isa_rsq_outcome

*********************************************************************
*	ESTIMATING R-SQ FOR OUTCOME EQ.	

program define isa_rsq_outcome
	version 9
	syntax varlist
	
	*	COUNTING NUMBER OF VARIABLES
	local num_var=0
	foreach var in `varlist' {
		local num_var=`num_var'+1
	}
	local lastB = 2*`num_var'
	
	scalar sigma_sq = (matB[1, `lastB'])^2

end

