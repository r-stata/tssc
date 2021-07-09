/*
five_fold_cv.ado performs the following operation:
1) It selects the polynomial order in the series approximation to be used to 
estimate the conditional expectations of Y and D, when the user wishes to estimate
the Wald-DID and/or Wald-TC estimator with covariates, and specifies the sieve 
option, but not the sieve_order one. It calls legendrisation.ado to compute the 
Legendre polynomials in X to be used to estimate the conditional expectations 
of Y and D*/

capture program drop five_fold_cv

program five_fold_cv, sortpreserve

	version 12
	
	syntax varlist(min=3 max=4 numeric) [, continuous(varlist num) ///
	qualitative(varlist numeric) cluster(varlist num) sieve_order(name)]
	
	tokenize `varlist', parse(" ,")		 
	marksample touse
	
	local varlist_count=wordcount("`varlist'")
	
	/*rename outcome, group, time and treatment*/
	if `varlist_count'==3 {
	
		args outcome G T
	}
	
	if `varlist_count'==4 {
	
		args outcome Gb Gf T
	}
		
	preserve

	
		
	quietly {
		
		keep if `touse'	
		tempname mat_cv
		tempvar u T_init T_no_init
		local ncont=wordcount("`continuous'")
		local nquali=wordcount("`qualitative'")
		scalar `sieve_order'=0
		quietly count 
		local N_obs=r(N)	
	
		/*Create random partitions of the data into 5 groups:*/
		
		local K=1
		
		forvalues i=1(1)`K' {
		
			set seed `i'
	
			if "`cluster'"=="" {
				
				tempvar no_clust_`i'
				gen `u'=runiform()
				sort `u'	
				gen `no_clust_`i'' = mod(_n-1,5) + 1
				drop `u'
			}
			
			/*if there is clustering in the data, partition at the cluster level*/
			
			else {
				
				tempvar clust_`i'
				gen `u'=runiform()
				sort `u'
				bysort `cluster': gen `clust_`i''=cond(_n==1,runiform(),.)
				replace `clust_`i''=cond(`clust_`i''<0.2,1, ///
				cond(`clust_`i''<0.4,2,cond(`clust_`i''<0.6,3, ///
				cond(`clust_`i''<0.8,4,cond(`clust_`i''<1,5,.)))))
				sort `cluster' `clust_`i''
				replace `clust_`i''=`clust_`i''[_n-1] if `clust_`i''>=.
				drop `u'
			}
		}
		
		local iter=1
		local time_to_stop=0
		matrix `mat_cv'=J(10,1,0)
		
		if `varlist_count'==4 {
		
			gen `T_init'=(`T'==1)
			gen `T_no_init'=(`T'>1)
		}
		
		
		while `iter'!=0 {
		
			local iter2=`iter'+4
			local iter3=`iter'
			
			forvalues i=`iter'(1)`iter2' {
				
				local n_new_vars=comb(`ncont'+`i',`i')
				
				/*if at a certain order, too many polynomial terms, error*/
				if `n_new_vars'>min(4800,`N_obs'/5) {
				
					scalar `sieve_order'=.
					ereturn clear
					local time_to_stop=1
					continue, break
				}
				
				/*create polynomials at current order*/
				local varz ""
				
				forvalues j=1(1)`n_new_vars' {
				
					tempname v`j'
					local varz "`varz' `v`j''"
				}
				
				legendrisation, continuous_var(`continuous') ///
				order1(`i') new_vars(`varz')
				
				/*regress, compute standard errors and average those for each partition*/
	
				forvalues j=1(1)`K' {
					
					local temp_CV=0
					
					forvalues l=1(1)5 {
						
						tempvar outcome_hat
						
						if "`cluster'"=="" {
							
							if `varlist_count'==3 {
							
								reg `outcome' i.`G'#i.`T'#c.(`varz') ///
								i.`G'#i.`T'#i.(`qualitative') ///
								if `no_clust_`j''!=`l', noc
							}
							else {
							
								reg `outcome' i.`T_no_init'#i.`Gb'#i.`T'#c.(`varz') ///
								i.`T_no_init'#i.`Gb'#i.`T'#i.(`qualitative') ///
								i.`T_init'#i.`Gf'#i.`T'#c.(`varz') ///
								i.`T_init'#i.`Gf'#i.`T'#i.(`qualitative') ///
								if `no_clust_`j''!=`l', noc							
							}
							
							predict `outcome_hat' if `no_clust_`j''==`l'
						}
						else {
							
							if `varlist_count'==3 {
							
								reg `outcome' i.`G'#i.`T'#c.(`varz') ///
								i.`G'#i.`T'#i.(`qualitative') ///
								if `clust_`j''!=`l', noc
							}
							else {
							
								reg `outcome' i.`T_no_init'#i.`Gb'#i.`T'#c.(`varz') ///
								i.`T_no_init'#i.`Gb'#i.`T'#i.(`qualitative') ///
								i.`T_init'#i.`Gf'#i.`T'#c.(`varz') ///
								i.`T_init'#i.`Gf'#i.`T'#i.(`qualitative') ///
								if `clust_`j''!=`l', noc								
							}
							
							predict `outcome_hat' if `clust_`j''==`l'						
						}
						
						replace `outcome_hat'=(`outcome_hat'-`outcome')^2
						sum `outcome_hat'
						local temp_CV=`temp_CV'+(1/`N_obs')*r(sum)
	
						drop `outcome_hat'						
					}
					
					matrix `mat_cv'[`i',1]=((`j'-1)/`j')*`mat_cv'[`i',1]+ ///
					(1/`j')*`temp_CV'					
				}
				
				drop `varz'
				
				/*see whether current order better than best so far in terms of MSE*/
				if `mat_cv'[ `i',1]<=`mat_cv'[`iter3',1] {
				
					local iter3=`i'
				}
			}
			
			if `time_to_stop'==1 {
			
				continue, break
			}
			
			if `iter3'==`iter2' {
				
				/*order larger than 10 not allowed*/
				if `iter3'==10 {
				
					/*display as err _newline(1) ///
					"max power reached" _newline(1)*/
					local iter=0
					scalar `sieve_order'=10
				}
				/*if MSE decreased at each order and order=10 not reached, try 5 more
				orders*/
				else {
					
					local iter=`iter'+5
				}
			}
			else {
			
				local iter=0
				scalar `sieve_order'=`iter3'
			}
		}
			
		ereturn clear
	}
end	
			

