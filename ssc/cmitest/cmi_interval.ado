capt program drop cmi_interval
program define cmi_interval, rclass

version 11.1

// Programmed by Wooyoung Kim (University of Wisconsin-Madison, wkim68@wisc.edu) 
// This is the command implementing "Inference Based on Conditional Moment Inequalities" (Donald W.K. Andrews and Xiaoxia Shi, 2013). 

/*
<OUTPUT LIST>




<INPUT LIST>

*/



local lbvar ` '
local ubvar ` ' 

gettoken lbvar 0: 0, match(leftover)
gettoken ubvar 0: 0, match(leftover)


syntax anything [if] [in] [, LEVel(real 0.95) DECI(integer 3) *]


local max_deci `deci'
local reject = 1 - `level'
local bon_reject = 1 - (1 + `level')/2

local num_lb = wordcount("`lbvar'")
local num_ub = wordcount("`ubvar'")

if `num_lb' != 0 {
	foreach a of local lbvar {
		quietly sum `a'
		local lowmin = `r(min)'
		local lowmax = `r(max)'
	}
	
	foreach a of local lbvar {
		quietly sum `a'
		local lowmin = min(`lowmin',`r(min)')
		local lowmax = max(`lowmax',`r(max)')
	}
	
	local ldist = `lowmax' - `lowmin' 
	local lowmin = floor(`lowmin') 
	local lowmax = ceil(`lowmax')
	
}

if `num_ub' != 0 {
	foreach a of local ubvar {
		quietly sum `a'
		local upmin = `r(min)'
		local upmax = `r(max)'
	}
	foreach a of local ubvar {
		quietly sum `a'
		local upmin = min(`upmin',`r(min)')
		local upmax = max(`upmax',`r(max)')
	}

	local udist = `upmax' - `upmin' 
	local upmin = floor(`upmin')
	local upmax = ceil(`upmax') 
	
	
}




if `num_lb' == 0 {


	/********************************************************************/
	/******************* Upper Bound Only Case **************************/
	/********************************************************************/
	
	local dir = -1
	local ujump = 1
	local ubound `upmax'
	local inbound = 0
	local pinbound = 0
	if `udist' > 1 {
		while (`inbound' != 0 | `pinbound' != 1 | `ujump' != 1){ 
			
			
			local pinbound = `inbound' 
			local ub_temp ` '
		
			foreach a of local ubvar {
				tempvar ubound_theta`i'
				gen `ubound_theta`i'' = `a' - `ubound'  
				local dummy "`ubound_theta`i''"
				local ub_temp `ub_temp' `dummy'
				local i = `i' + 1
			}

			quietly cmi_test (`ub_temp') () `anything' `if' `in' , `options'

			local pval = `r(pval)'
			
			if `dir' == -1{
				if `pval' < `reject'{
					local ujump = `ujump' * 2
					local inbound = 0
				}
				else{
					local ujump = max(`ujump' /2, 1) 
					local dir = -1 * `dir'
					local inbound = 1
				}
			}
			else{
				if `pval' >= `reject'{
					local ujump = `ujump' * 2
					local inbound = 1
				}
				else{
					local ujump = max(`ujump' /2, 1) 
					local dir = -1 * `dir'
					local inbound = 0
				}
			}
		
			local ubound = `ubound' + `dir' * `ujump' 

		}
	}
	
	forval deci = 1(1)`max_deci'{
		
		local ujump = 10^(-`deci')
		local inbound = 0
		
		while (`inbound' != 1){
			local ub_temp ` '
	
			foreach a of local ubvar {
				tempvar ubound_theta`i'
				gen `ubound_theta`i'' = `a' - `ubound'
				local dummy "`ubound_theta`i''"
				local ub_temp `ub_temp' `dummy'
				local i = `i' + 1
			}
			
			quietly cmi_test (`ub_temp') () `anything' `if' `in' , `options'
			local pval = `r(pval)'
			
			if `pval' > `reject' {
				local inbound = 1
			}
			else{
				local ubound = `ubound' - `ujump'  
			}
		
		}

		local ubound = `ubound' + `ujump'
	}


}
else if `num_ub' == 0 {

	/********************************************************************/
	/******************* Lower Bound Only Case **************************/
	/********************************************************************/
	

	local dir = 1
	local ljump = 1
	local lbound `lowmin'
	local inbound = 0
	local pinbound = 0
	if `ldist' > 1 {
		while (`inbound' != 0 | `pinbound' != 1 | `ljump' != 1){ 
		
			local pinbound = `inbound' 
			local lb_temp ` '
		
			foreach a of local lbvar {
				tempvar lbound_theta`i'
				gen `lbound_theta`i'' = `lbound' - `a'
				local dummy "`lbound_theta`i''"
				local lb_temp `lb_temp' `dummy'
				local i = `i' + 1
			}

			quietly cmi_test (`lb_temp') () `anything' `if' `in' , `options'

			local pval = `r(pval)'
			
			if `dir' == 1{
				if `pval' < `reject'{
					local ljump = `ljump' * 2
					local inbound = 0
				}
				else{
					local ljump = max(`ljump' /2, 1) 
					local dir = -1 * `dir'
					local inbound = 1
				}
			}
			else{
				if `pval' >= `reject'{
					local ljump = `ljump' * 2
					local inbound = 1
				}
				else{
					local ljump = max(`ljump' /2, 1) 
					local dir = -1 * `dir'
					local inbound = 0
				}
			}
		
			local lbound = `lbound' + `dir' * `ljump' 

		}
	}
	
	forval deci = 1(1)`max_deci'{
		local ljump = 10^(-`deci')
		local inbound = 0
		
		while (`inbound' != 1){
			local lb_temp ` '
	
			foreach a of local lbvar {
				tempvar lbound_theta`i'
				gen `lbound_theta`i'' = `lbound' - `a'
				local dummy "`lbound_theta`i''"
				local lb_temp `lb_temp' `dummy'
				local i = `i' + 1
			}
			
			quietly cmi_test (`lb_temp') () `anything' `if' `in' , `options'
			local pval = `r(pval)'
			
			if `pval' > `reject' {
				local inbound = 1
			}
			else{
				local lbound = `lbound' + `ljump'  
			}
		
		}
		
		local lbound = `lbound' - `ljump'

	}

}
else{
    /********************************************************************/
	/************** Both Upper and Lower Bound Case *********************/
	/********************************************************************/
	
	/* STEP1: Bonferroni Upper Bound */ 
	
	local dir = -1
	local ujump = 1
	local ubound `upmax'
	local inbound = 0
	local pinbound = 0
	
	if `udist' > 1{
		while (`inbound' != 0 | `pinbound' != 1 | `ujump' != 1){ 
		
			local pinbound = `inbound' 
			local ub_temp ` '
		
			foreach a of local ubvar {
				tempvar ubound_theta`i'
				gen `ubound_theta`i'' = `a' - `ubound'  
				local dummy "`ubound_theta`i''"
				local ub_temp `ub_temp' `dummy'
				local i = `i' + 1
			}

			quietly cmi_test (`ub_temp') () `anything' `if' `in' , `options'

			local pval = `r(pval)'
			
			if `dir' == -1{
				if (`pval' < `bon_reject'){
					local ujump = `ujump' * 2
					local inbound = 0
				}
				else{
					local ujump = max(`ujump' /2, 1) 
					local dir = -1 * `dir'
					local inbound = 1
				}
			}
			else{
				if (`pval' >= `bon_reject'){
					local ujump = `ujump' * 2
					local inbound = 1
				}
				else{
					local ujump = max(`ujump' /2, 1) 
					local dir = -1 * `dir'
					local inbound = 0
				}
			}
		
			local ubound = `ubound' + `dir' * `ujump' 

		}
	}
	
	forval deci = 1(1)`max_deci'{
		local ujump = 10^(-`deci')
		local inbound = 0
		
		while (`inbound' != 1){
			local ub_temp ` '
	
			foreach a of local ubvar {
				tempvar ubound_theta`i'
				gen `ubound_theta`i'' = `a' - `ubound'
				local dummy "`ubound_theta`i''"
				local ub_temp `ub_temp' `dummy'
				local i = `i' + 1
			}
			
			quietly cmi_test (`ub_temp') () `anything' `if' `in' , `options'
			local pval = `r(pval)'
			
			if (`pval' > `bon_reject') {
				local inbound = 1
			}
			else{
				local ubound = `ubound' - `ujump'  
			}
		
		}

		local ubound = `ubound' + `ujump'
	}


	/* Bonferroni Lower Bound */ 

	local dir = 1
	local ljump = 1
	local lbound `lowmin'
	local inbound = 0
	local pinbound = 0
	
	if `ldist' > 1 {
		while (`inbound' != 0 | `pinbound' != 1 | `ljump' != 1){ 
		
			local pinbound = `inbound' 
			local lb_temp ` '
		
			foreach a of local lbvar {
				tempvar lbound_theta`i'
				gen `lbound_theta`i'' = `lbound' - `a'
				local dummy "`lbound_theta`i''"
				local lb_temp `lb_temp' `dummy'
				local i = `i' + 1
			}

			quietly cmi_test (`lb_temp') () `anything' `if' `in' , `options'

			local pval = `r(pval)'
			
			if `dir' == 1{
				if `pval' < `bon_reject'{
					local ljump = `ljump' * 2
					local inbound = 0
				}
				else{
					local ljump = max(`ljump' /2, 1) 
					local dir = -1 * `dir'
					local inbound = 1
				}
			}
			else{
				if (`pval' >= `bon_reject'){
					local ljump = `ljump' * 2
					local inbound = 1
				}
				else{
					local ljump = max(`ljump' /2, 1) 
					local dir = -1 * `dir'
					local inbound = 0
				}
			}
		
			local lbound = `lbound' + `dir' * `ljump' 

		}
	}
	
	forval deci = 1(1)`max_deci'{
		local ljump = 10^(-`deci')
		local inbound = 0
		
		while (`inbound' != 1){
			local lb_temp ` '
	
			foreach a of local lbvar {
				tempvar lbound_theta`i'
				gen `lbound_theta`i'' = `lbound' - `a'
				local dummy "`lbound_theta`i''"
				local lb_temp `lb_temp' `dummy'
				local i = `i' + 1
			}
			
			quietly cmi_test (`lb_temp') () `anything' `if' `in' , `options'
			local pval = `r(pval)'
			
			if (`pval' > `bon_reject') {
				local inbound = 1
			}
			else{
				local lbound = `lbound' + `ljump'  
			}
		
		}
		
		local lbound = `lbound' - `ljump'

	}

	
	/* STEP2: Calculate the strict bound */ 
	
	if (`lbound' > `ubound') {
		local empty = 1 
	}
	else{
		local empty = 0
		local dist = `ubound' - `lbound' 
		local jump = max(floor(`dist'/20),1)
		
		if (`dist' > 2){
			local inbound = 0 
			while (`inbound' == 0 | `jump' > 1 ){
				local i = 1
				local lb_temp = ` ' 
				
				foreach a of local lbvar {
					tempvar lbound_theta`i'
					gen `lbound_theta`i'' = `lbound' - `a'
					local dummy "`lbound_theta`i''"
					local lb_temp `lb_temp' `dummy'
					local i = `i' + 1
				}
			
				local i = 1
		
				foreach a of local ubvar {
					tempvar ubound_theta`i'
					gen `ubound_theta`i'' = `a' - `lbound'
					local dummy "`ubound_theta`i''"
					local lb_temp `lb_temp' `dummy'
					local i = `i' + 1
				
				}

				quietly cmi_test (`lb_temp') () `anything' `if' `in' , `options'
				local pval = `r(pval)' 
				if (`pval' > `reject') {
					local inbound = 1
					local lbound = `lbound' - `jump' 
					local jump = max(floor(`jump'/2),1)
					
				}	
				else if (`prepval' > `pval'){
					local inbound = 0.5
					local lbound = `lbound' - 2 * `jump' 
					local jump = max(floor(`jump'/2),1)
					
				}	
				else{	
					local lbound = `lbound' + `jump'
					local inbound = 0  
				}
			
			}
			
			if (`inbound' == 0.5) {
				local ubound = `lbound' + 2
			}
			else{
				local inbound = 0
				local dist = `ubound' - `lbound' 
				local jump = max(floor(`dist'/20),1)
				while (`inbound' == 0 | `jump' > 1 ){
					local i = 1
					local ub_temp = ` ' 
					
					foreach a of local lbvar {
						tempvar lbound_theta`i'
						gen `lbound_theta`i'' = `ubound' - `a'
						local dummy "`lbound_theta`i''"
						local ub_temp `ub_temp' `dummy'
						local i = `i' + 1
					}
				
					local i = 1
			
					foreach a of local ubvar {
						tempvar ubound_theta`i'
						gen `ubound_theta`i'' = `a' - `ubound'
						local dummy "`ubound_theta`i''"
						local lb_temp `lb_temp' `dummy'
						local i = `i' + 1
					
					}

					quietly cmi_test (`ub_temp') () `anything' `if' `in' , `options'
					local pval = `r(pval)' 
					if (`pval' > `reject') {
						local inbound = 1
						local ubound = `ubound' + `jump' 
						local jump = max(floor(`jump'/2),1)
						
					}	
					else{	
						local ubound = `ubound' - `jump'
						local inbound = 0  
					}
				
				}
			}
		
		
		}
		
		forval deci = 1(1)`max_deci'{
			
			local dist = `ubound' - `lbound'
			local jump = 10^(-`deci')
			
			if (`dist' > 20*`jump'){
				local inbound = 0 
				while (`inbound' == 0){
					local i = 1
					local lb_temp ` ' 
					
					foreach a of local lbvar {
						tempvar lbound_theta`i'
						gen `lbound_theta`i'' = `lbound' - `a'
						local dummy "`lbound_theta`i''"
						local lb_temp `lb_temp' `dummy'
						local i = `i' + 1
					}
				
					local i = 1
			
					foreach a of local ubvar {
						tempvar ubound_theta`i'
						gen `ubound_theta`i'' = `a' - `lbound'
						local dummy "`ubound_theta`i''"
						local lb_temp `lb_temp' `dummy'
						local i = `i' + 1
					
					}

					quietly cmi_test (`lb_temp') () `anything' `if' `in' , `options'
					local pval = `r(pval)' 
					
					if (`pval' > `reject') {
						local inbound = 1
					}	
					else{
						local lbound = `lbound' + `jump'
					}
				
				}
				local lbound = `lbound' - `jump' 
				
				local inbound = 0 
				while (`inbound' == 0){
					local i = 1
					local ub_temp ` '
					
					foreach a of local lbvar {
						tempvar lbound_theta`i'
						gen `lbound_theta`i'' = `ubound' - `a'
						local dummy "`lbound_theta`i''"
						local ub_temp `ub_temp' `dummy'
						local i = `i' + 1
					}
				
					local i = 1
			
					foreach a of local ubvar {
						tempvar ubound_theta`i'
						gen `ubound_theta`i'' = `a' - `ubound'
						local dummy "`ubound_theta`i''"
						local ub_temp `ub_temp' `dummy'
						local i = `i' + 1
					
					}

					quietly cmi_test (`ub_temp') () `anything' `if' `in' , `options'
					
					local pval = `r(pval)' 
					
					if (`pval' > `reject') {
						local inbound = 1
					}	
					else{
						local ubound = `ubound' - `jump'
					}
				
				}
				local ubound = `ubound' + `jump' 
				
		
			}
			else if `dist' > `jump'{
			
				local inbound = 0 
				local pval = 0
				local prepval = 0 
				
				while (`inbound' == 0 & `pval' >= `prepval'){
					
					local prepval = `pval'
					local i = 1
					local lb_temp ` ' 
					
					foreach a of local lbvar {
						tempvar lbound_theta`i'
						gen `lbound_theta`i'' = `lbound' - `a'
						local dummy "`lbound_theta`i''"
						local lb_temp `lb_temp' `dummy'
						local i = `i' + 1
					}
				
					local i = 1
			
					foreach a of local ubvar {
						tempvar ubound_theta`i'
						gen `ubound_theta`i'' = `a' - `lbound'
						local dummy "`ubound_theta`i''"
						local lb_temp `lb_temp' `dummy'
						local i = `i' + 1
					
					}
					
					quietly cmi_test (`lb_temp') () `anything' `if' `in' , `options'
					
					local pval = `r(pval)' 
					
					/* A case in which we can find a point in the bound */ 
					if (`pval' > `reject') {
						local inbound = 1
					}	
					else if (`pval' >= `prepval'){
						local lbound = `lbound' + `jump'
					}
					
				
				}
				local lbound = `lbound' - `jump'
				
				if (`pval' < `prepval'){
					/* we suspect a small interval here */ 
					local lbound = `lbound' - `jump'
					local ubound = `lbound' + `jump' 
				}
				else{
					local inbound = 0
					
					while (`inbound' == 0){
						local i = 1
						local ub_temp ` '
						
						foreach a of local lbvar {
							tempvar lbound_theta`i'
							gen `lbound_theta`i'' = `ubound' - `a'
							local dummy "`lbound_theta`i''"
							local ub_temp `ub_temp' `dummy'
							local i = `i' + 1
						}
					
						local i = 1
				
						foreach a of local ubvar {
							tempvar ubound_theta`i'
							gen `ubound_theta`i'' = `a' - `ubound'
							local dummy "`ubound_theta`i''"
							local ub_temp `ub_temp' `dummy'
							local i = `i' + 1
						
						}

						quietly cmi_test (`ub_temp') () `anything' `if' `in' , `options'
						local pval = `r(pval)' 
						
						
						if (`pval' > `reject') {
							local inbound = 1
							local ubound = `ubound' + `jump'
						}	
						else{
							local inbound = 0 
							local ubound = `ubound' - `jump' 
						}
					
					}
					
				
				}
			
			
			}
		}	

	}

}


local N = `r(N)'
local kappa = `r(kappa)'
local ncube = `r(ncube)'
local B = `r(B)'
local epsilon = `r(epsilon)'
local rep_cv = `r(rep_cv)'
local a_obs = `r(a_obs)'
local r_n = `r(r_n)'
local method = "`r(method)'"
local method_CV = "`r(method_CV)'"
local method_FUN = "`r(method_FUN)'"


return clear 
return local method = "`method'"
return local method_CV = "`method_CV'"
return local method_FUN = "`method_FUN'" 

return local x = "`anything'"
if `num_ub' != 0 {
	return local ubvar = "`ubvar'"
}
if `num_lb' != 0 {
	return local lbvar = "`lbvar'"
}
return local title = "Conditional Moment Inequalities Interval"
return local cmd = "cmi_interval"

return scalar N = `N'
if `num_lb' != 0 {
	return scalar lbound = `lbound'
}
if `num_ub' != 0 {
	return scalar ubound = `ubound'
}
return scalar level = `level'
return scalar kappa = `kappa'
return scalar ncube = `ncube'
return scalar B = `B'
return scalar epsilon = `epsilon'
return scalar rep_cv = `rep_cv'
return scalar a_obs = `a_obs'
return scalar r_n = `r_n'
return scalar deci = `max_deci' 


display as text _newline "Conditional Moment Inequalities Interval" _col(59) "Number of obs : " as result r(N) 
display as text "{hline 80}"
display as text "<Variables>"
if "`lbvar'" != "" {
	display as text "Variables for the Lower Bound : " as result "`lbvar'"
}
else{
	display as text "A Lower Bound is not computed"
}
if "`ubvar'" != "" {
	display as text "Variables for the Upper Bound : " as result "`ubvar'"
} 
else{
	display as text "An Upper Bound is not computed" 
}
display as text "Instruments : " as result "`anything'"
display as text "{hline 80}"

display as text "<Methods>"

display as text "`method'" 
display as text "`method_CV'" 
display as text "`method_FUN'" 


display as text "{hline 80}"
display as text "<Results>"
display as result 100*r(level) as text "% confidence interval is:" 
if `num_lb' == 0 {
	display as result as text "( " as result "-inf" as text " , " %5.`max_deci'f as result  `ubound' as text " )"
}
else if `num_ub' == 0 {
	display as result as text "( " %5.`max_deci'f as result `lbound' as text " , " as result "inf" as text " )"
}
else {
	if `empty' == 0{
		display as result as text "( " %5.`max_deci'f as result  `lbound' as text " , " as result %5.`max_deci'f `ubound' as text " )"
	}
	else{
		display as text "The confidence interval is empty under " `max_deci' " digits decimal"  
	}
}



end



