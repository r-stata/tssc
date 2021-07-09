/*
special_cases.ado performs the following operation:
1) It assesses whether the support conditions "S(D|G=1,T=0) included in the 
intersection of S(D|G=0,T=0) and S(D|G=0,T=0)" is satisfied. 
*/

quietly capture program drop special_cases
quietly program special_cases

	version 12

	syntax varlist(min=3 max=3 numeric) [if] [in] ///
	[, ncateg(numlist int) ///
	is_part_sharp(name)]
		
	tokenize `varlist', parse(" ,")		 

	args G T D
		
	scalar `is_part_sharp'=0
	
	quietly {
		
		forvalues d=1(1)`ncateg' {
		
			count if `G'==1 & `T'==0 & `D'==`d'
			
			if r(N)!=0 {
				
				tempname n_t0 n_t1
				quietly count if `G'==0 & `T'==0 & `D'==`d'
				scalar `n_t0'=r(N)
				quietly count if `G'==0 & `T'==1 & `D'==`d'
				scalar `n_t1'=r(N)
				
				/*if subpopulations {G=0,T=1,D=d} and/or {G=0,T=0,D=d} are
				empty, there is a support issue*/
				
				if `n_t0'==0 | `n_t1'==0 {
				
					scalar `is_part_sharp'=1
					
				}
			}	
		}
	}
	
end
