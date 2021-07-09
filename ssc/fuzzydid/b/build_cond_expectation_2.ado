/*
build_cond_expectation_2.ado performs the following operation:
1) It computes the conditional expectations E(Y_d0t|X) that are
needed to compute the Wald-TC estimator with covariates, when this estimator is
requested by the user*/

quietly capture program drop build_cond_expectation_2
quietly program build_cond_expectation_2

	version 12

	syntax varlist(max=4 numeric) ///
	[, inf_method(name) reg_method(name) ///
	continuous(varlist num fv) qualitative(varlist num fv) ///
	sieve_expansion(varlist num) d(numlist) target0(name) ///
	target1(name)]
	
	tokenize `varlist', parse(" ,")		 
	
	args Y G T D
	*preserve
	
	quietly {
		
		tempname mean_outcome coefs sd_coefs
		
		local n_quali=wordcount("`qualitative'")
		local quali_list ""
		
		/*include qualitative variables in the list of covariates*/
		forvalues i=1(1)`n_quali' {
		
			local a: word `i' of `qualitative'			
			local quali_list "`quali_list' i.`a'"
		}		
		
		local covariates "`quali_list' `continuous'"		
		
		
		forvalues i=0(1)1 {

			/*computation of unconditional expectations of the form
			E(Y_d0i)*/		
			sum `Y' if `G'==0 & `T'==`i' ///
			& `D'==`d'
			scalar `mean_outcome'=r(mean)			
			
			/*conditional expectation E(Y_d0i|X)*/
			
			if r(min)==r(max) {
			
				gen `target`i''=`mean_outcome' if `G'==1 & `T'==1
			}
			else {
			
				if "`inf_method'"=="param" {
					
					`reg_method' `Y' `covariates' if `D'==`d' & `G'==0 ///
					& `T'==`i'
					matrix `coefs'=e(b)
					matrix `sd_coefs'=e(V)									
				}
				else {
				
					if "`inf_method'"=="sieve" {
						
						reg `Y' `quali_list' `sieve_expansion' ///
						if `D'==`d' & `G'==0 & `T'==`i'
						matrix `coefs'=e(b)
						matrix `sd_coefs'=e(V)										
					}
				}
				
				/*evaluation of regression function E(Y_d0i|X)
				at values of X in subgroup {G=1,T=1}*/							
				predict `target`i'' if `G'==1 & `T'==1
				
				/*if prediction is missing for some observations in {G=1,T=1}, 
				regression function=unconditional mean for those observations*/
				if "`inf_method'"=="sieve" | "`reg_method'"=="reg" {
				
					replace `target`i''=`mean_outcome' if `target`i''==. & `G'==1 & `T'==1 
				}
				else {
				
					if "`reg_method'"=="logit" { 
					
						replace `target`i''=`mean_outcome' if `target`i''==. & `G'==1 & `T'==1
					}
					
					if "`reg_method'"=="probit" { 
					
						replace `target`i''=`mean_outcome' if `target`i''==. & `G'==1 & `T'==1
					}			
				}					
			}

							
			/*check if support of some qualitative covariates larger on 
			{G=1,T=1} than on {G=0,T=i,D=d}*/
			tempvar patch_var
			
			gen `patch_var'=0
			
			/*loop over the list of qualitative regressors*/
			forvalues l=1(1)`n_quali' {
				
				/*identify qualitative regressor at step l of the loop*/
				local quali_var`l': word `l' of `qualitative'
				
				/*count how many distinct values the variable takes in pop
				{G=1,T=1}*/				
				levelsof `quali_var`l'' if `G'==1 ///
				& `T'==1, local(coucou1)
				
				/*count how many distinct values the variable takes in pop
				{D=d,G=0,T=i}*/					
				levelsof `quali_var`l'' if `G'==0 ///
				& `T'==`i' & `D'==`d', local(coucou2)

				/*count how many values of the variable appear in {G=1,T=1} 
				without appearing in {D=d,G=0,T=i}*/				
				local both : list coucou1 - coucou2
				local count=wordcount("`both'")
				
				/*if there are actually values that appear in {G=1,T=1} and
				not in {D=d,G=0,T=i}, identify all the obs in {G=1,T=1} for which
				the variable takes one of those problematic vales*/				
				if `count'!=0 {
				
					forvalues m=1(1)`count' {
						local word`m': word `m' of `both'
						replace `patch_var'=`patch_var'+1 if ///
						`quali_var`l''==`word`m'' & `G'==1 ///
						& `T'==1
					}
				}
			}						
			
			/*for observations in {G=1,T=1} that were identified as problematic, 
			regression function=unconditional mean*/
			replace `target`i''=`mean_outcome' if `patch_var'!=0
		}						
	}
end
