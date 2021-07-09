*! 1.0.0 Ariel Linden 23Sep2018         

program define genidseq
version 11.0

	syntax varlist(max=1) ,				///
		Generate(string) 				///
		[Start(numlist int max=1 >0)	///
		Increment(numlist int max=1 >0)	///
		NOSort							///
		]                               


	quietly {

		count
		if r(N) == 0 error 2000
		local N = r(N)

		* validate options
		if "`start'" == "" local start = 1 
		if "`increment'" == "" local increment = 1 
		
		if "`nosort'" == "" {
			sort `varlist'
		}
		
		* generate sequence
		gen `generate' = `start' in 1
		replace `generate' = cond(`varlist' == `varlist'[_n-1], `generate'[_n-1],`generate'[_n-1] + `increment') in 2/`N'
		
	} // end quietly
end
