*! 1.0.0 Ariel Linden 20Sep2019

program define seqfind, rclass
version 11.0

	syntax newvarname [if] [in] , vars(varlist numeric) CHARval(numlist max=1) LENgth(numlist max=1 integer) 
	
		quietly {
			marksample touse, novarlist
			count if `touse'
			if r(N) == 0 error 2000
			local N = r(N)
			replace `touse' = -`touse'
		}

		local varcount : word count `vars'
		
		if `length' ==  0 | `length' > `varcount' {
			di as err "length must be an integer between 1 and `varcount'" 
			exit 198
		}
		
		local nlength =  `length' - 1

		tempvar testlength tag
		
		quietly {
			gen `testlength' = 0 if `touse' // test whether length is reached
			gen `tag' = 0 if `touse' // flips to 1 when desired sequence is found
			gen `varlist' = 0 if `touse'


			


			if `length' == 1 {
				forval i = 1/`=`varcount'-2' {
					local one : word `i' of `vars'
					local two : word `=`i'+ 1' of `vars'
					local three : word `=`i'+ 2' of `vars'	
				
					replace `tag' = 1 if (`i' == 1 & `one' == `charval' & `two' != `charval') | (`i' == `varcount'-2 & `two' != `charval' & `three' == `charval') & `touse'
					replace `tag' = 1 if (`i' < `varcount'-2 & `one' != `charval' & `two' == `charval' & `three' != `charval') & `touse'
				}
			} // end length==1
			
			else if `length' >  1 {
				forval i = 1/`=`varcount'-1' {
					local one : word `i' of `vars'
					local two : word `=`i'+ 1' of `vars'
				
					replace `testlength' = `testlength' + 1 if `one' == `charval' & `two' == `charval' & `touse'
					replace `testlength' = 0 if `testlength' < `nlength' & `two' != `charval' & `touse'
					replace `tag' = 1 if `testlength' == `nlength' & (`two' != `charval' | `i' == `varcount'-1) & `touse'
				} // end forval
			} // end length > 1

			replace `varlist' = 1 if `tag' == 1 & `touse'
			
		} // end quietly	
end
