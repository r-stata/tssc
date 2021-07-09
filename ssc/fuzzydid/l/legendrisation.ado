/*
legendrisation.ado performs the following operation:
1) It computes the Legendre polynomials in X to be used to estimate the 
conditional expectations of Y and D, when the user wishes to estimate the 
Wald-DID and/or Wald-TC estimator with covariates, and specifies the sieve 
option.*/

quietly capture program drop legendrisation
quietly program legendrisation, eclass		
	
	version 12

	syntax ///
	[, continuous_var(varlist num) ///
	order1(numlist int) order2(numlist int) new_vars(namelist)]
	
	
	local newvar: word 1 of `new_vars'
	gen `newvar'=1		
	local ncont_var=wordcount("`continuous_var'")
	local ncont_var_minus=`ncont_var'-1
	
	if "`order2'"!="" {
		
		local poly_list_bis "`newvar'"
		local max_order=max(`order1',`order2')
		local min_order=min(`order1',`order2')
	}
	else {
	
		local max_order=`order1'
	}
	
	/*iterator that is incremented each time a tensor polynomial variable
	is built*/
	local iter=2
	
	
	/*build orthonormal polynomials up to specified order for each continuous
	variable*/
	forvalues p=1(1)`ncont_var' {
		
		/*add a constant to the polynomial expansion list of first continuous
		variable (important to build tensor polynomials in a dynamic way)*/
		if `p'==1 {
		
			local list1 "`newvar'"
		}
		else {
		
			local list`p' ""
		}
		
		local u: word `p' of `continuous_var'
		
		orthpoly `u', g("`u'_"*) degree(`max_order')
		
		forvalues q=1(1)`max_order' {
			
			/*for every continuous variable, build a list with its
			polynomial expansion*/
			local list`p' "`list`p'' `u'_`q'"
			
			/*if first continuous variable, store its polynomial expansion
			as final tensor polynomials*/
			if `p'==1 {
			
				local newvar: word `iter' of `new_vars'
				gen `newvar'=`u'_`q'
				local iter=`iter'+1
				
				if "`order2'"!="" {
				
					if `q'<=`min_order' {
					
						local poly_list_bis "`poly_list_bis' `newvar'"
					}
				}
			}
		}
	}		
	
	/*create final stage tensor polynomials*/
	
	/*list of tensor polynomials and of their order that is augmented
	dynamically*/
	local poly_list "`list1'"
	local order_list "0"
	
	forvalues o=1(1)`max_order' {
	
		local order_list "`order_list' `o'"
	}
	
	/*final loop: for each continuous variable, interact its polynomial
	expansion with terms already in the list of tensor polynomials if the
	order is no larger than max order specified by user in option order. Then 
	add new tensor polynomials to the list and go back to top of the loop.*/
	forvalues d=1(1)`ncont_var_minus' {
		
		local dbis=`d'+1
		local ncount_poly_list=wordcount("`poly_list'")
		
		forvalues v=1(1)`ncount_poly_list' {
			
			/*extract tensor polynomial (ranked v in the list) and its order*/
			local popol1: word `v' of `poly_list'
			local popol2: word `v' of `order_list'
			
			forvalues w=1(1)`max_order' {
				
				/*extract term w in the polynomial expansion of continuous
				variable d+1*/
				local popol3: word `w' of `list`dbis''
				
				/*compute order of new tensor polynomial*/
				local incr_order=`popol2'+`w'
				
				/*if order<= max order, build new tensor polynomial and store
				it and its order in the list*/
				if `incr_order'<=`max_order' {
				
					local newvar: word `iter' of `new_vars'
					gen `newvar'=`popol1'*`popol3'
					local poly_list "`poly_list' `newvar'"
					local order_list "`order_list' `incr_order'"
					local iter=`iter'+1
					
					if "`order2'"!="" {
					
						if `incr_order'<=`min_order' {
						
							local poly_list_bis "`poly_list_bis' `newvar'"
						}
					}
				}
			}		
		}
	}
	
	/*drop polynomial expansion of each continuous variable since they have 
	been added to the list of tensor polynomials*/
	forvalues p=1(1)`ncont_var' {
	
		local u: word `p' of `continuous_var'
		drop `u'_*
	} 
	
	if "`order2'"!="" {
		
		ereturn local list_bis `poly_list_bis'
	}
	
end
