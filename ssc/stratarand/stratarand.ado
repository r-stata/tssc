****John Ternovski*******************
**Harvard University*****************
***04feb2015*************************
*****version 2.0*********************
***john_ternovvski@hks.harvard.edu***
program define stratarand
	version 12
	syntax [if], strata(varname) gentreat(string) [conditionsnumber(real 0)] [replace] [group_percentages(numlist)] [exact]
	
	
	//error checking 
	if ("`conditionsnumber'"=="0" & "`group_percentages'"=="") | ("`conditionsnumber'"!="0" & "`group_percentages'"!="") {
		disp as error "ERROR: You must specify either the number of equally sized conditions in the conditionsnumber option or the percentage of observations in each condition via the group_percentages option." 
		exit
	}

	// deal with replace
	if "`replace'"!="" {
		cap drop `gentreat'
	}
	
	//deal with ifs
	if "`if'"!="" {
		local if2="& " + substr("`if'",3,.)
	}
	
	***********************
	********Equal Groups***
	***********************
	if "`conditionsnumber'"!="0" {
		//create random number and clean variables
		tempvar stratanum
		qui egen `stratanum'=group(`strata') `if'
		tempvar rand
		qui gen `rand'=runiform() `if'
		tempvar seq
		

		//randomly sort within strata
		sort `stratanum' `rand'
		by `stratanum': egen `seq' = seq() `if' 
		qui gen `gentreat'=. `if' 


		qui sum `stratanum' `if' 
		forval i=1/`r(max)' {
			local seednum= 143922171+`i'
			set seed `seednum'
			local first=1+int((`conditionsnumber')*runiform()) //randomly choosing which treatment condition to strat with 
			qui replace `gentreat'=`first' if `seq'==1 & `stratanum'==`i' `if2'
			local staybelow=`conditionsnumber'+1
			local tracker=`first'
			disp in green "On strata number `i'..."
			qui count if `stratanum'==`i' `if2'
			
			//warn when strata too small
			if `r(N)'<`conditionsnumber' {
				disp in red "WARNING: Strata number `i' has only `r(N)' observations and there are `conditionsnumber' experimental conditions."
			}
			forval n=2/`r(N)' {
				if `staybelow'>`tracker' {
					qui replace `gentreat'=`gentreat'[_n-1]+1 if `stratanum'==`i' & `seq'==`n' `if2' //use sequence function if the random assignment is number of conditions or less
					local tracker=`tracker'+1
					}
				if `tracker'==`staybelow' {
					qui replace `gentreat'=1 if `stratanum'==`i' & `seq'==`n' `if2' //start over once get to max number of conditions 
					local tracker=1
				}
			}
		}
	}
	****************************
	
	***********************
	********Unequal Groups*
	***********************
	if "`group_percentages'"!="" {

		tokenize `group_percentages'
		

		//error checking
		local num_group=wordcount("`*'")
		local sum=0
		forval n=1/`num_group' {
			local sum=``n''+`sum'
		}
		if .99>`sum' {
			disp as error "ERROR: Percentages in group_percentages must add up to 1"
			exit
		}

		//generating variables
		tempvar rand
		gen `rand' = runiform() `if' 
		tempvar strata_num
		egen `strata_num'=group(`strata') `if' 
		sort `strata_num' `rand'
		tempvar seq
		by `strata_num': egen `seq' = seq() `if' 
		tempvar size
		by `strata_num': egen `size'=max(`seq') `if' 
		qui gen `gentreat'=. `if' 


		//main assignment loop
		qui sum `strata_num' `if'   //getting number of strata
		forval i=1/`r(max)' {
			local first
			local num
			local strata_size
			local bound1
			local num
			local bound2
			

			local seednum= 143922171+`i'
			set seed `seednum'
			
			local first=1+int((`num_group')*runiform()) //determining which group the random assignment starts from 

			qui sum `size' if `strata_num'==`i' `if2' 
			local strata_size=`r(max)'  // getting strata size
			disp in green "On strata number `i'..."
			if `r(max)'<`num_group' {
				disp in red "WARNING: One of your strata have less observations than number of experimental conditions."
			}
			
			//random assignment within each strata

			//this loop assigns the treatment condition that was randomly determined to be first		
			forval x=1/`num_group' {
				if `first'==`x' {
					local num=round(`strata_size'*``x'')
					//determining how many people need to go to the first treatment condition 
					qui replace `gentreat'=`x' if `strata_num'==`i' & `seq'<=`num' `if2'  //the first chunk of observations go to whatever the first treatment condition is
				}
			}

			//this is the loop that happens if you still havent reached the max number of treatment groups
			local after=`first'+1
			if `after'<=`num_group'{
				forval qq=`after'/`num_group' {
					//determining the bounds for the next group
					local bound1=`num' //this is the lower bound
					local num2=round(`strata_size'*``qq'')
					local num=`num2'+`bound1' //this is the number of observations that go into this treatment condition
					local bound2=`num' //this is the upper bound
					qui replace `gentreat'=`qq' if `strata_num'==`i' & `seq'<=`bound2' & `seq'>`bound1' `if2'  //assign a chunk of observations to the next chunk
				}
			}
			
			//this is the loop when you reached the last treatment group, so you start over from 1
			local before=`first'-1
			if `before'>0 {
				forval qq=1/`before' {
					//determining the bounds for the next group
					local bound1=`num' //this is the lower bound 
					local num2=round(`strata_size'*``qq'')
					local num=`num2'+`bound1' //this is the number of observations that go into this treatment condition
					local bound2=`num' //this is the upper bound
					qui replace `gentreat'=`qq' if `strata_num'==`i' & `seq'<=`bound2' & `seq'>`bound1' `if2'  //assign a chunk of observations to the next chunk
					
				}
			}
			

			//dealing with rounding error 
			if "`exact'"!="" {
				qui count if `gentreat'!=. & `strata_num'==`i'
				if `r(N)'!=`strata_size' {
					tempvar seq2
					qui egen `seq2' = seq() if `strata_num'==`i' & `gentreat'==. `if2' 
			
					local seednum2= 143922171+`i'
					set seed `seednum2'
					local first2=1+int((`num_group')*runiform()) //randomly choosing which treatment condition to strat with 
					
					
					qui replace `gentreat'=`first2' if `seq2'==1 & `strata_num'==`i' `if2'
					*disp " treat2 `first2' in 1 in strata `i'"
					local staybelow2=`num_group'+1
					local tracker2=`first2'
					qui count if `strata_num'==`i' & `gentreat'==. `if2'
							
					forval n=2/`r(N)' {
						if `staybelow2'>`tracker2' {
							qui replace `gentreat'=`gentreat'[_n-1]+1 if `strata_num'==`i' & `seq2'==`n' & `gentreat'==. `if2' //use sequence function if the random assignment is number of conditions or less
							local tracker2=`tracker2'+1
							*disp " treat2 `first2' in `n' in strata `i'"
							}
						if `tracker2'==`staybelow2' {
							qui replace `gentreat'=1 if `strata_num'==`i' & `seq2'==`n' & `gentreat'==. `if2' //start over once get to max number of conditions 
							local tracker2=1
							*disp " treat2 `first2' in `n' in strata `i'"
						}

					}
				}
			}	

		}
	}
end
	
	
**