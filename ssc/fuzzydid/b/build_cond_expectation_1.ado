/*
build_cond_expectation_1.ado performs the following operation:
1) It computes the conditional expectations E(D_gt|X) and E(Y_gt|X) that are
needed to compute the Wald-DID and Wald-TC estimators with covariates, when these
estimators are requested by the user*/

quietly capture program drop build_cond_expectation_1
quietly program build_cond_expectation_1

	version 12

	syntax varlist(max=3 numeric) ///
	[, inf_method(name) reg_method(name) ///
	continuous(varlist num fv) qualitative(varlist num fv) ///
	sieve_expansion(varlist num) i(numlist) j(numlist) target(name)]
	
	tokenize `varlist', parse(" ,")		 
	
	args outcome G T

	quietly {
		
		tempname mean_outcome coefs sd_coefs
		
		local n_quali=wordcount("`qualitative'")
		local quali_list ""
		
		/*include qualitative variables in the list of covariates*/
		forvalues l=1(1)`n_quali' {
		
			local a: word `l' of `qualitative'			
			local quali_list "`quali_list' i.`a'"
		}		
		
		local covariates "`quali_list' `continuous'"
		
		/*computation of unconditional expectations of the form
		E(D_gt) or E(Y_gt)*/		
		sum `outcome' if `G'==`i' & `T'==`j', meanonly
		scalar `mean_outcome'=r(mean)
		
		/*computation of conditional expectations of the form
		E(D_ij|X) or E(Y_ij|X), according to computation method chosen by user*/
		if "`inf_method'"=="param" {
			
			`reg_method' `outcome' `covariates' if `G'==`i' & ///
			`T'==`j'
			matrix `coefs'=e(b)
			matrix `sd_coefs'=e(V)
		}
		else {
		
			if "`inf_method'"=="sieve" {
			
				reg `outcome' `quali_list' `sieve_expansion' ///
				if `G'==`i' & `T'==`j'
				matrix `coefs'=e(b)
				matrix `sd_coefs'=e(V)
			}
		}
		
		/*evaluation of regression function E(D_ij|X) or E(Y_ij|X)
		(ij different from 11) at values of X in subgroup {G=1,T=1}*/
		predict `target' if `G'==1 & `T'==1 
				
		/*if prediction is missing for some observations in {G=1,T=1}, 
		regression function=unconditional mean for those observations*/
		if "`inf_method'"=="sieve" | "`reg_method'"=="reg" {
		
			replace `target'=`mean_outcome' if `target'==. & `G'==1 & `T'==1 
		}
		else {
		
			if "`reg_method'"=="logit" { 
			
				replace `target'=`mean_outcome' if `target'==. & `G'==1 & `T'==1
			}
			
			if "`reg_method'"=="probit" { 
			
				replace `target'=`mean_outcome' if `target'==. & `G'==1 & `T'==1
			}			
		}
						
		/*check if support of some qualitative covariates larger on 
		{G=1,T=1} than on {G=i,T=j}*/
		tempvar patch_var
		
		gen `patch_var'=0
		
		/*loop over the list of qualitative regressors*/
		forvalues l=1(1)`n_quali' {
			
			/*identify qualitative regressor at step l of the loop*/
			local quali_var`l': word `l' of `qualitative'
			
			/*count how many values the variable takes in pop
			{G=1,T=1}*/
			quietly levelsof `quali_var`l'' if `G'==1 ///
			& `T'==1, local(coucou1)
			
			/*count how many values the variable takes in pop
			{G=i,T=j}*/			
			levelsof `quali_var`l'' if `G'==`i' ///
			& `T'==`j', local(coucou2)
			
			/*count how many values of the variable appear in {G=1,T=1} without
			appearing in {G=i,T=j}*/
			local both : list coucou1 - coucou2
			local count=wordcount("`both'")
			
			/*if there are actually values that appear in {G=1,T=1} and
			not in {G=i,T=j}, identify all the obs in {G=1,T=1} for which
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
		replace `target'=`mean_outcome' if `patch_var'!=0
		
		drop `patch_var'
	}
end
