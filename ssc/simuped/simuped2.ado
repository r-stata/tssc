****************************************************************
*! Version 9.0.1, 5 October 2006
*! Author: James Cui, Monash University
*! Simulate two-generation families
*! Original publication: Nov 2000 STB 58: 2-5 (dm82)
****************************************************************

capture program drop simuped2
program simuped2
version 9.0

	gettoken age1 0 : 0, parse(" ,")
      gettoken std1 0 : 0, parse(" ,")
      gettoken age2 0 : 0, parse(" ,")
      gettoken std2 0 : 0, parse(" ,")

      if (`age1'<0 | `age2'<0 | `std1'<0 | `std2'<0) {
           	di in red "negative numbers invalid"
           	exit 498
      }

	syntax [, Saving(string) Reps(int 100) Alle(real 0.1) Sib(real 3)]  

	if "`saving'" ~= "" {
		parse "`saving'", parse (" ")
		local  output = "`1'"
	}	
	else {
		local  output = "temp.dta"
	}
		
	tempname nsimu p q simu

	if (`reps' < 1) {
		di in red "reps() required"
		exit 198
	}

	scalar `nsimu' = `reps'

	if (`sib' < 0) {
		di in red "Sibship size negative"
		exit 198
	}

	if (`alle' < 0) {
		di in red "Allele frequency negative"
		exit 198
	}

	scalar `p' = `alle'
	scalar `q' = 1-`p'

	local nob = int(10*`sib' + 2)
	qui set obs `nob'
	qui gen mu = `sib'
		
	tempvar simu degree id female nochild x g y age  i

	postfile simuped2 famid id degree female g age using `output', replace

	qui gen `simu' = 0
	while (`simu' < `nsimu') {		/* begin simu */

	 	qui replace `simu' = `simu' + 1
	
		tempvar degree id female nochild x g y age  i
			
*---------------------------------------------------------------
* 1. SIZE OF SIBSHIP
*---------------------------------------------------------------

		qui rndpoix mu
		qui gen byte `nochild' = xp 
		qui replace `nochild' = . if _n ~= 1 		/* denoted by 1st person */
		qui drop xp

		qui gen byte `degree' = 1 if _n <= 2
		qui replace `degree' = 2 if _n > 2 & _n <= 2 + `nochild'[1]
		qui gen byte `id' = _n if _n <= 2 + `nochild'[1]

*---------------------------------------------------------------
* 2. SEX AND AGE
*---------------------------------------------------------------

		qui gen byte `female' = 0 if `degree' == 1
		qui replace `female' = 1 if _n == 2 & `degree' == 1		/* father first */
			
		qui gen `x' = uniform() if `degree' == 2	
		qui replace `female' = 0 if `x' < 0.5 & `degree' == 2
		qui replace `female' = 1 if `x' >= 0.5 & `degree' == 2

		#delimit ;
		qui gen int `age' = max(0,int(`age1' + `std1' 
			* invnorm(uniform()) + 0.5)) if `degree' == 1;

		qui replace `age' = max(0,int(`age2' + `std2' 
			* invnorm(uniform()) + 0.5)) if `degree' == 2;
		#delimit cr

*---------------------------------------------------------------
* 3. GENERATION 1: GENOTYPE
*---------------------------------------------------------------

		qui replace `x' = uniform() if `degree' == 1
		qui gen byte `g' = 11 if `x' <= `p' * `p' & `degree' == 1
		qui replace `g' = 12 if `x' > `p' * `p' & `x' <= `p' * `p'		/*
		*/	+ 2 * `p' * `q' & `degree' == 1
		qui replace `g' = 22 if `x' > `p' * `p' + 2 * `p' * `q' 		/*
		*/	& `degree' == 1
				

*---------------------------------------------------------------
* 4. GENERATION 2: GENOTYPE
*---------------------------------------------------------------

		qui replace `x' = uniform() if `degree' == 2
		qui gen `y' = uniform() if `degree' == 2
		
		#delimit ;
		qui replace `g' = 11 if `degree' == 2 &
			(`g'[1] == 11 | `g'[1] == 12 & `x' < 0.5) &
			(`g'[2] == 11 | `g'[2] == 12 & `y' < 0.5);

		qui replace `g' = 22 if `degree' == 2 &
			(`g'[1] == 22 | `g'[1] == 12 & `x' >= 0.5) & 
			(`g'[2] == 22 | `g'[2] == 12 & `y' >= 0.5);

		qui replace `g' = 12 if `degree' == 2 &
			(`g'[1] == 11 | `g'[1] == 12 & `x' < 0.5) & 
			(`g'[2] == 22 | `g'[2] == 12 & `y' >= 0.5);

		qui replace `g' = 12 if `degree' == 2 &
			(`g'[1] == 22 | `g'[1] == 12 & `x' >= 0.5) &
			(`g'[2] == 11 | `g'[2] == 12 & `y' < 0.5);
		#delimit cr


*---------------------------------------------------------------
* 5. OUTPUT TO STATA FILE
*---------------------------------------------------------------

		qui gen `i'=1			/* the ith observation */

		while (`i' <= 2 + `nochild'[1]) {
	
			post simuped2 (`simu'[`i']) (`id'[`i']) (`degree'[`i']) /*
				*/ (`female'[`i']) (`g'[`i']) (`age'[`i'])
			qui replace `i' = `i' + 1
		}
		if (`simu' / 10 == int(`simu' / 10)) {
			di in green `simu' _skip(1) _con		/* display dots during simu */
		}

		qui drop `degree' `id' `female' `nochild' `x' `g' `y' `age' `i'

	} 		/* end SIMU */

	postclose simuped2

	use `output', clear

	qui gen str2 genotype = "AA" if g == 11
	qui replace genotype = "Aa" if g == 12
	qui replace genotype = "aa" if g == 22
	qui drop g
	
	qui save `output', replace
	di _n in ye `"A file named "`output'" has been created"'

	drop _all

end
