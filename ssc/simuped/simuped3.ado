****************************************************************
*! Version 9.0.1, 5 October 2006
*! Author: James Cui, Monash University
*! Simulate three-generation families
*! Original publication: Nov 2000 STB 58: 2-5 (dm82)
****************************************************************

capture program drop simuped3
program simuped3
version 9.0

	gettoken age1 0 : 0, parse(" ,")
      gettoken std1 0 : 0, parse(" ,")
      gettoken age2 0 : 0, parse(" ,")
      gettoken std2 0 : 0, parse(" ,")
      gettoken age3 0 : 0, parse(" ,")
      gettoken std3 0 : 0, parse(" ,")

      if (`age1'<0 | `age2'<0 | `age3'<0 | `std1'<0 | `std2'<0 | `std3'<0) {
		di in red "negative numbers invalid"
		exit 498
       }

	syntax [, Saving(string) Reps(int 100) Alle(real 0.1) Sib(real 3) Si3(real 3)]  

	if "`saving'" ~= "" {
		parse "`saving'", parse (" ")
		local  output = "`1'"
	}	
	else {
		local  output = "temp.dta"
	}
		
	tempname nsimu mu mu1 p q simu
	tempvar degree id family nochild tlchild female age g x y i
	tempvar fchild mchild nogrand marry marriag

	if (`reps' < 1) {
		di in red "reps() required"
		exit 198
	}
	scalar `nsimu' = `reps'

	if (`sib' < 0) {
		di in red "Sibship size negative"
		exit 198
	}

	if (`si3' < 0) {
		di in red "Sibship size negative"
		exit 198
	}

	if (`alle' < 0) {
		di in red "Allele frequency negative"
		exit 198
	}
	scalar `p' = `alle'
	scalar `q' = 1-`p'


	local nob = int(5* (`sib' + `si3') + 4)
	qui set obs `nob'
	qui gen mu = `sib'
	qui gen mu1 = `si3'

	postfile simuped3 famid id degree family female marry g age using `output', replace

	qui gen `simu' = 0
	while (`simu' < `nsimu') {		/* begin simu */

		qui replace `simu' = `simu' + 1
	
*---------------------------------------------------------------
* 1. 1st and 2nd generation
*---------------------------------------------------------------

		qui gen byte `degree' = cond(_n <= 4, 1, .)
		qui gen byte `id' = _n if `degree' == 1
		qui gen byte `family' = cond(_n <= 2, 1, 2) if `degree' == 1

		qui rndpoix mu
		qui gen byte `nochild' = xp 
		qui replace `nochild'=. if `id'~=1 & `id'~=3		/* denote by 1st person in each family */
		qui drop xp

		qui gen byte `tlchild' = `nochild'[1] + `nochild'[3] if `id' == 1		/* denote by 1st person */

		qui replace `degree' = 2 if _n > 4 & _n <= 4 + `tlchild'[1]	
		qui replace `id' = _n if `degree' == 2
		qui replace `family' = cond(_n > 4 & _n <= 4 + `nochild'[1], 1, 2) if `degree' == 2

*---------------------------------------------------------------
* 2. SEX AND AGE
*---------------------------------------------------------------

		qui gen byte `female' = cond(_n == 2 | _n == 4, 1, 0) if `degree' == 1		/* the 2nd person female */

		qui gen `x' = uniform() if `degree' == 2	
		qui replace `female'=cond(`x'<0.5, 0, 1) if `degree'==2
		qui drop `x'

		qui gen int `age'=max(0,int(`age1'+`std1'*invnorm(uniform())+0.5)) if `degree'==1
		qui replace `age'=max(0,int(`age2'+`std2'*invnorm(uniform())+0.5)) if `degree'==2


*---------------------------------------------------------------
* 3. GENERATION 1: GENOTYPE
*---------------------------------------------------------------

		qui gen `x' = uniform() if `degree' == 1
		qui gen byte `g' = 11 if `x' <= `p' * `p' & `degree' == 1
		qui replace `g' = 12 if `x' > `p' * `p' & `x' <= `p' * `p' + 2* `p' * `q' & `degree' == 1
		qui replace `g' = 22 if `x' > `p' * `p' + 2 * `p' * `q' & `degree' == 1
		qui drop `x'

*---------------------------------------------------------------
* 4. GENERATION 2: GENOTYPE
*---------------------------------------------------------------

		qui gen `x' = uniform() if `degree' == 2
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
		qui drop `x' `y'

*---------------------------------------------------------------
* 5. Number of Males and Females
*---------------------------------------------------------------

		qui sort `family' `degree' `female'
		qui by `family': gen `fchild' = sum(`female' == 1 & `degree' == 2)
		qui by `family': replace `fchild' = `fchild'[_N] if _n ~= _N
		qui replace `fchild' = . if `id' ~= 1 & `id' ~= 3 		/* assign this number to grandpa */
		qui gen `mchild' = `nochild' - `fchild'

			
*---------------------------------------------------------------
* 5. Marriage
* last F in family 1 marry first M in family 2 
* first F in family 1 marry last M in family 2 
* No marriag if either condition holds         
*---------------------------------------------------------------
		
		qui sort `degree' `family' `female'	
		qui gen `marry'=.			/* check no. of females in family 1 > 1 */
			
		if (1-`fchild'[1] <= 0 & 1-`mchild'[3] <= 0) {		/* check no. of males in famiy 2 > 1 */

			qui by `degree' `family': replace `marry' = 1 	/*
			*/ 	if `degree' == 2 & `family' == 1 & _n == _N & `female' == 1

			qui by `degree' `family': replace `marry'=1 	/*
			*/ 	if `degree' == 2 & `family' == 2 & _n == 1 & `female' == 0
		}
		else if (1-`mchild'[1] <= 0 & 1-`fchild'[3] <= 0) {

			qui by `degree' `family': replace `marry'=1 	/*
			*/ 	if `degree' == 2 & `family' == 1 & _n == 1 & `female' == 0

			qui by `degree' `family': replace `marry'=1 	/*
			*/ 	if `degree' == 2 & `family' == 2 & _n == _N & `female' == 1
		}



*---------------------------------------------------------------
* 6. Generation 3, only if marriage exist 
*---------------------------------------------------------------

		qui gen byte `nogrand' = .

		qui gen byte `marriag' = cond(1-`fchild'[1] <= 0 & 1-`mchild'[3] <= 0 | 	/*
		*/ 	1-`mchild'[1] <= 0 & 1-`fchild'[3] <= 0, 1, 0)

		if (`marriag'==1) {		/* BEGIN marriag */

*---------------------------------------------------------------
* 7. Sibship size, generation 3 
*---------------------------------------------------------------

		qui rndpoix mu1

		qui replace `nogrand' = xp if `id' == 1			/* assign to grandpa family 1 */
		qui drop xp

		if (-`nogrand'[1] < 0) {		
			qui replace `degree' = 3 if _n > 4 + `tlchild'[1] & 	/*
			*/ 	_n <= 4 + `tlchild'[1] + `nogrand'[1]	

			qui replace `id' = _n if `degree' == 3
			qui replace `family' = 0 if `degree' == 3

*---------------------------------------------------------------
* 8. Sex 
*---------------------------------------------------------------

			qui gen `x' = uniform() if `degree' == 3
			qui replace `female' = cond(`x' < 0.5, 0, 1) if `degree' == 3
			qui drop `x'
	
*---------------------------------------------------------------
* 8. AGE and Genotype 
*---------------------------------------------------------------

			qui replace `age' = max(0,int(`age3' + `std3' * invnorm(uniform()) + 0.5)) if `degree' == 3

			qui sort `marry' `degree' `family' `female'			/* Married couple listed first */
			qui gen `x' = uniform() if `degree' == 3	
			qui gen `y' = uniform() if `degree' == 3	
					
			#delimit ;
			qui replace `g' = 11 if `degree' == 3 &
				(`g'[1] == 11 | `g'[1] == 12 & `x' < 0.5) &
				(`g'[2] == 11 | `g'[2] == 12 & `y' < 0.5) ;

			qui replace `g' = 22 if `degree' == 3 & 
				(`g'[1] == 22 | `g'[1] == 12 & `x' >= 0.5) & 
				(`g'[2] == 22 | `g'[2] == 12 & `y' >= 0.5) ;
			
			qui replace `g' = 12 if `degree' == 3 & 
				(`g'[1] == 11 | `g'[1] == 12 & `x' < 0.5) & 
				(`g'[2] == 22 | `g'[2] == 12 & `y' >= 0.5);

			qui replace `g' = 12 if `degree' == 3 & 
				(`g'[1] == 22 | `g'[1] == 12 & `x' >= 0.5) &
				(`g'[2] == 11 | `g'[2] == 12 & `y' < 0.5) ;
			#delimit cr
			drop `x' `y'
			}					
		}					

*---------------------------------------------------------------
* 9. OUTPUT TO STATA FILE 
*---------------------------------------------------------------

		if (`marriag' == 1) {	

			qui replace `marry' = 1 if `degree' == 1
			qui replace `marry' = 0 if `marry' == .
			qui sort `id'

			qui gen `i' = 1			/* the ith observation */
			while (`i' <= _N & `degree'[`i'] ~= .) {

				post simuped3 (`simu'[`i']) (`id'[`i']) (`degree'[`i']) (`family'[`i'])		/*
				*/	(`female'[`i']) (`marry'[`i']) (`g'[`i']) (`age'[`i'])
				qui replace `i'=`i' + 1
			}
			qui drop `i'
		}

		if (`simu' / 10 == int(`simu' / 10)) {
			di in green `simu' _skip(1) _con		/* display dots during simu */
		}

		qui drop `degree' `id' `family' `nochild' `tlchild' `female' `age' `g' 			/*
		*/		`fchild' `mchild' `nogrand' `marry' `marriag'

	} 		/* end SIMU */

	postclose simuped3
		
	use `output', clear
	qui gen str2 genotype = "AA" if g == 11
	qui replace genotype = "Aa" if g == 12
	qui replace genotype = "aa" if g == 22
	qui drop g
	qui save `output', replace
	di _n in ye `"A file named "`output'" has been created"'

	drop _all

end


