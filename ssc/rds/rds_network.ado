* respondent driven sampling 


*****************************************************************************************
* construct network variables and find depth of referral chains
* program isolates the temp variables "order" and "p_order"
* need rclass program, because all eclass results are wiped out when using the command "ereturn post" during compute_weights
program gen_network_var, rclass
version 10.1
syntax , ref(str) nref(int) keyvar(str)  degree(str) id(str) p_id(str) p_keyvar(str) [ ancestor(str) depth(str) ]

	    tempvar order p_order maxdepth ahne tiefe 	

		* find parents
		find_parents, ref(`ref') nref(`nref') keyvar(`keyvar')  degree(`degree') id(`id') order(`order') ///
			p_order(`p_order') p_id(`p_id') p_key(`p_keyvar')
		local nseed=r(nseed)
		di as res "Number of seeds= `nseed'"
	
		* compute depth
		compute_depth, order(`order') p_order(`p_order') maxdepthvar(`maxdepth') ahne(`ahne') tiefe(`tiefe') p_id(`p_id') id(`id')
		qui sum `tiefe'  
		local max_depth=r(max)
		di as res "Greatest chain length= `max_depth'"
		* "if `p_id'==." ensures that this is only printed out once per seed
		di " " 
		di as res "        Seed       MaxDepth"
		list `ahne' `maxdepth' if `p_id'==.,noheader
		
		* make network variables visible  outside the program if desired
		if ("`ancestor'"!="") {
			gen `ancestor'=`ahne'
		}
		if ("`depth'"!="") {
			gen `depth'=`tiefe'
		}

		return scalar n_seed=`nseed'
		return scalar max_depth=`max_depth'
end
*****************************************************************************************
* computes p_id p_keyvar p_degree
* assumes keyvar is calculated already
* assumes that id is unique
* nref is the number of reference coupons per person
program find_parents , rclass
version 10.1
syntax , ref(str) nref(int) keyvar(str)  degree(str) id(str) order(str) p_order(str) p_id(str) p_key(str)

	tempvar p_degree

	* find seed 
	qui gen `p_degree'=.
	qui gen `p_order'=.

	* p_order faciltates computing_depth
	* order is needed to ensure that the same order  is maintained 
	gen `order'=_n

	* foreach parent
	local N=_N
	local num=1
	while `num'<=`N' {
		* if any id matches the parent's child (ref) 
		* for those id's set the parentid
		* (all kids are simultaneously checked whether they correspond to this  one parent )
		foreach r of numlist 1/`nref' {
			qui replace `p_id'= 	    `id'[`num']   if `id'==`ref'`r'[`num']  
	      	qui replace `p_key'= `keyvar'[`num'] if `id'==`ref'`r'[`num'] 
			qui replace `p_degree'= `degree'[`num'] if `id'==`ref'`r'[`num'] 
			qui replace `p_order'= `order'[`num']     if `id'==`ref'`r'[`num'] 
		}
		local num=`num'+1
	}


	qui tab `p_key'
	local r1=r(r)
	qui tab `keyvar'
	if (`r1'!=r(r)) {
		di as err "The number of categories among recruiters does not equal the number of categories among recruitees."
		di as err "There are probably too few observations relative to the number of categories."
		error 999
		exit 
	}

	qui count if `p_id'==.
	return scalar nseed =r(N)
end 
***************************************************************************************
* compute chain length of referrals (or depth of tree)
* generates variables : ancestor, depth, maxdepth
* uses   p_order p_id 
program compute_depth
	version 10.1
	syntax , order(str) p_order(str) maxdepthvar(str) ahne(str) tiefe(str) p_id(str) id(str)
	
	* make sure sort order remains as intended
	sort `order'
			
	* ancestor:  the id of the ancestor (seed) belonging to a child
	* depth: the tree depth. seeds have tree depth 0.
	qui gen `ahne'=.
	qui gen `tiefe'=.
	
	qui replace `ahne'=`id' if `p_id'==.
	qui replace `tiefe'=0 if `p_id'==.
	
	local counter=0
	local miss =1
	*while there are still some depth values not yet set  
	*Counter< avoids Infinite loops (Circular references);Depth cannot be more than _N
	while(`miss'>0  & `counter'<_N){
		qui replace `tiefe'=`counter'+1 if  `tiefe'[`p_order']==`counter'
		qui replace `ahne'= `ahne'[`p_order'] if  `tiefe'[`p_order']==`counter'
		local counter=`counter'+1
		qui count if `tiefe'==.
		local miss = r(N)
	}
	if (`counter'>=_N) {
		di as error "Circular references: " 
		di as error "Coupon eventually links back to the respondent who handed out the coupon."
		di as error "In such cases the ancestor cannot be determined and is missing. "
		di as error "Here is an unordered list of id's involved in one or more circular references:"
		list `id' if `ahne'==. 
	}

	bysort `ahne': egen `maxdepthvar'=max(`tiefe')
	
end 
**************************************************************************************
* verify that each person (row) has a distinct id
program check_unique_id
	version 10.1
	syntax , id(str)

	tempvar dup
	qui duplicates tag `id' , gen(`dup')
	qui sum `dup'
	if r(mean)>0 {
		list `id' if `dup'>=1
		di as error "`id' is not unique (duplicates listed above) "
		di as error "This might occur, for example, if all seed coupons are zero or missing"

		error 999
	}
end
**************************************************************************************
* verify no self -references (a person has a coupon identical to his id)
program check_self_reference
	version 10.1
	syntax ,  id(str) coupon(str) ncoupon(int)
	
	tempvar selfref
	qui gen `selfref'=0
	foreach i of numlist 1/`ncoupon' {
		qui replace `selfref'=1 if `id'==`coupon'`i'
	}
	
	qui sum `selfref'
	if (r(mean)!=0) {
		di as error "There are self-references (a coupon of a respondent refers to his id)"
		list `id'  if `selfref'==1
		error 999
	}
end
**************************************************************************************
* verify that coupons are unique (i.e.  different people do not give out the same coupon,
*  and the same person does not twice give the same coupon)
program check_unique_coupon
	version 10.1
	syntax , id(str) coupon(str) ncoupon(int)
	
	preserve
	tempvar ref dup
	
	local s=""
	foreach i of numlist 1/`ncoupon' {
		local s = "`s' `coupon'`i'"
	}
	
	stack `s', into(`ref') clear 
	* When not all coupons are handed out, values are missing. Those are not duplicates.
	qui drop if `ref'==.
	
	qui duplicates tag `ref' , gen(`dup')
 	qui sum `dup'
	if r(mean)>0 {
			format `ref' %10.0f
			list `ref' if `dup'>=1 ,noheader
			di as error "There are duplicate referral coupons (listed above)"
			di as error "Possible reasons:"
			di as error "(1) Two respondents distributed the same coupon"
			di as error "(2) A respondent distributed the same coupon twice" 
			di as error "(3) Missing coupons were coded with the same value (e.g. 0)"

			error 999
	}
	
	restore
end
**************************************************************************************
* output and error for keyvar
program keyvar_output, rclass
    version 10.1 
    syntax , keyvar(str) vlist(str)
    
	qui tab `keyvar'
	di as res "Number of categories of (`vlist'): " r(r) "
	if (r(r) > 30 ) {
		di as res "The number of categories is very large."
		di as res "If any of the variables in <varlist> is continuous you should recode the variables and rerun the program."
	}
	return scalar n_group=r(r)
end

***************************************************************************************
* if desired, create permanent variables for recruiter_id and recruiter_var 
program save_recruiter_variables
	version 10.1
	syntax ,  p_id(str) p_keyvar(str) [ recruiter_id(str) recruiter_var(str) use_recruiter ]	
	if ("`use_recruiter'"=="") {
		if ("`recruiter_id'"!="") {
				qui gen `recruiter_id'=`p_id'
		}
		if ("`recruiter_var'"!="") {
				qui gen `recruiter_var'=`p_keyvar'
		}
	}
end 
***************************************************************************************
***************************************************************************************
program rds_network , eclass sortpreserve
*! 0.0.1 June 18, 2010, Matthias Schonlau
*! 0.0.2 June 30, 2010, minor update
*! 0.0.3 July 8, 2010, fixed bug related to id name
*! 0.0.4 July 12, 2010, fixed bug related to names of vars (recruiter_id and recruiter_var)
*! 1.0.0 November 4, 2011 ; no updates
*! 1.0.1 June 30, 2016, Added error message about circular references (coupon eventually links to itself) 
	version 10.1
	syntax varlist(max=1 min=1 numeric), id(varname) coupon(str) ncoupon(int) degree(varname)  ///
	[ ANCestor(str) depth(str) 	recruiter_id(str) recruiter_var(str) ]

	tempvar keyvar p_id p_keyvar

	check_unique_id, id(`id')
	check_self_reference, id(`id') coupon(`coupon') ncoupon(`ncoupon') 
	check_unique_coupon, id(`id') coupon(`coupon') ncoupon(`ncoupon') 

	* calculate keyvar 
	local keyvar = "`varlist'"
	keyvar_output, keyvar("`keyvar'") vlist(`varlist')
	local n_group= r(n_group)
	
	* generate parent vars
	qui gen `p_id'=.
	qui gen `p_keyvar'=.

	gen_network_var, ref(`coupon') nref(`ncoupon') keyvar("`keyvar'")  degree(`degree') id(`id') ///
			p_keyvar("`p_keyvar'") p_id(`p_id') ancestor("`ancestor'") depth("`depth'")	
	local n_seed=r(n_seed)
	local max_depth=r(max_depth)

	* if desired, create permanent variables for recruiter_id and recruiter_var 
	save_recruiter_variables, recruiter_id("`recruiter_id'") recruiter_var("`recruiter_var'") `use_recruiter' ///
		p_id(`p_id') p_keyvar(`p_keyvar')


end 
**************************************************************************************
