program define lrchg, rclass
*! 1.0.0 6 June 2000 Jan Brogger
	version 6.0
	syntax [, store(integer -1) contr(numlist integer) noCOEFF]

	capture assert `store' ~= -1 | "`contr'" ~= ""
	if _rc ~= 0 { 
			di in red "Wrong syntax for lrchg"
			error 999 
			}

	preserve

	if `store' ~= -1 {
		capture lrmatx
		if _rc ~= 0 { 
			di in red "Error getting regression results"
			error 999 
			}
		matrix coeff`store' = r(or)
		matrix lrmatx`store' = r(lrmatx)
		matrix modinfo`store' = r(modinfo)
	} /* store */

	if `"`contr'"' ~= `""' {
	
		tokenize "`contr'"
		local mod1 `1'
		local mod2 `2'
		*check that the coefficients exist

		capture local exist = coeff`mod1'[1,1]+coeff`mod2'[1,1]
		if _rc ~= 0 { 
			di in red "Coefficients not found"
			error 999 
		}

		di _newl in gre "Likelihood ratio tests and change in coefficients"
		di       in gre "between logistic regression models"

		di in gre _dup(50) "-"

		/*compute likelihood ratio test between models */
	
		*local aic1=-2*e(ll)+2*(e(df_m)+`factn')
		*local rdf1=e(N)-(e(df_m)+`factn')
		matrix t=(modinfo`mod1'["ll","c1"])
		local dev1=-2*t[1,1]
		matrix t=modinfo`mod1'["df_m","c1"]
		local mdf1=t[1,1]

		matrix t=modinfo`mod2'["ll","c1"]
		local dev2=-2*t[1,1]
		matrix t=modinfo`mod2'["df_m","c1"]
		local mdf2=t[1,1]

		local chi=abs(`dev2' - `dev1')
		local df = abs(`mdf1'-`mdf2')
		local p= chiprob(`df',`chi')
		*local rdf= `rdf1'-`df'

		di _col(1) "Diff. in LL =" _col(20) %11.3f `chi'
		di _col(1) "Diff. in df  =" _col(20) %11.0f `df'
		di _col(1) "P-value      =" _col(20) %11.4f `p'

		return local dchi "`dchi'"
		return local ddf "`df'"
		return local p "`p'"

		if "`coeff'" == ""  {

			di _newl in green "Change in common coefficients " _newl "between models `mod1' and `mod2':" _newl

			/* this stores the coeffients and % change */
			tempname chg

			/* first, get the coefficients that are in both models */

			local names1: rowfullnames coeff`mod1' 
			local names2: rowfullnames coeff`mod2'
			matchwrd , names1("`names1'") names2("`names2'")

			*return list 
			local matches "`r(matches)'"
			local uniq1 "`r(uniq1)'"
			local uniq2 "`r(uniq2)'"

			local var_n : word count `r(matches)'

			if `var_n' > 0   /*process the matching coefficients */ {

				matrix `chg' = J(`var_n',3,0)

				matname `chg' `matches', rows(.) explicit
	
				/* now, put the coefficients into the matrix and compute change */

				local i = 1
				while `i' <= `var_n' {
					local varnam : word `i' of `matches'
					matrix `chg'[`i',1] = coeff`mod1'["`varnam'",1]
					matrix `chg'[`i',2] = coeff`mod2'["`varnam'",1]
					matrix `chg'[`i',3] = 100-(`chg'[`i',2] /`chg'[`i',1] )*100

					local i = `i'+1
				}

				matname `chg' mod`mod1' mod`mod2' chg, col(.) explicit

				/* now output a table */

				/* store the matrix names in the dataset */
				tempvar namecol

				quietly { 
				gen str10 `namecol'=""
				local i 1
				while `i' <= `var_n' {
					local s : word `i' of `matches'
					if "`s'"=="_cons" {
						local s = "cons"
					} 
					replace `namecol'="`s'" if _n==`i' 
	
					local i=`i'+1
				} /* while */
				} /* quietly */

				/* store the coeffients */
				capture drop mod`mod1'
				capture drop mod`mod2'
				capture drop chg
				svmat double `chg', names(col)

				rename `namecol' vars


				di in green _col(2) %-11s "Coefficient"  _column(14) %9s "Model `mod1'" _column(27) %9s "Model `mod2'" _column(37) %9s "%change"
				di in green _dup(50) "-"
				for X in numlist 1/`var_n', noheader: /*
					*/ di  %-11s _col(2) vars[X] _col(14) %9.4f mod`mod1'[X] _col(27) %9.4f  mod`mod2'[X] %9.1f _col(37) chg[X]
				di in green _dup(50) "-"

				return matrix lrchg `chg'

			} /*finished with the matching coefficients */

			/* Form a matrix of a unique coefficients */

			tempname m_uniq1
			tempname m_uniq2
			tempname m_uniq

			local uni1_n : word count `uniq1'
			local uni2_n : word count `uniq2'
			*di "uniq1: `uniq1' n=`uni1_n'"
			*di "uniq2: `uniq2' n=`uni2_n'"

			if `uni1_n' > 0 {
				matrix `m_uniq1' = J(`uni1_n',3,0)
				matname `m_uniq1' `uniq1', rows(.) explicit

				local i = 1
				while `i'<=`uni1_n' {
					matrix `m_uniq1'[`i',1] = coeff`mod1'[`i',1]
					local i = `i'+1
				} /* while */
			} /* if */

			if `uni2_n' > 0 {
				matrix `m_uniq2' = J(`uni2_n',3,0)
				matname `m_uniq2' `uniq2', rows(.) explicit
		
				local i = 1
				while `i'<=`uni2_n' {
					matrix `m_uniq2'[`i',2] = coeff`mod2'[`i',1]
					local i = `i'+1
				} /* while */
			} /* if */

			if (`uni1_n' >0) &  (`uni2_n' >0) {
				matrix `m_uniq' = `m_uniq1' \ `m_uniq2'
			}
			else if (`uni1_n' >0) {
				matrix `m_uniq' = `m_uniq1'
			}
			else if (`uni2_n' >0) {
				matrix `m_uniq' = `m_uniq2'
			}
	
			*matrix list `m_uniq'

			/* Return the uniques if there are any */
			tempname result
			if `uni1_n' > 0 | `uni2_n' > 0 {

				/* output the uniques */
		
				local uniq_n =rowsof(`m_uniq')
				local uniqv : rowfullnames `m_uniq'
				local i = 1
				while `i' <= `uniq_n' {
					local v : word `i' of `uniqv'
					di  %-11s _col(2) "`v'" _col(14) %9.4f `m_uniq'[`i',1] _col(27) %9.4f  %9.4f `m_uniq'[`i',2] %9s _col(37) "uniq"
					local i = `i'+1
				} /* while */

				return matrix uniq `m_uniq' 
			} /* if any uniques */

		} /* if not drop the coefficients */
	} /* contrast */

	restore
end

capture program drop matchwrd
program define matchwrd, rclass
	syntax , names1(string) names2(string)

	local n1 : word count `names1'
	local n2 : word count `names2'

	local matches ""
	local wordn1 = 1
	while `wordn1' <=`n1' {
		local var1: word `wordn1' of `names1'
		local wordn2 = 1

		while `wordn2' <=`n2' {
			local var2: word `wordn2' of `names2'
			
			if "`var1'"=="`var2'" {
				local matches "`matches' `var1'"
			}
			local wordn2 = `wordn2'+1
		}			

		local wordn1 = `wordn1'+1
	} /* while */

	** Find unique varnames in names1

	local match_n: word count `matches'
	local uniq1 ""

	local wordn1=1

	while `wordn1'<=`n1' {
		local var1: word `wordn1' of `names1'
		local uniq=0

		local match_i = 1
		while (`match_i' <= `match_n') & (`uniq'==0) {
			local match1: word `match_i' of `matches'

			if "`match1'" == "`var1'" {
				local uniq = 1
			}
			local match_i = `match_i' +1
		}

		if `uniq'==0 {
			local uniq1 "`uniq1' `var1'"
		}

		local wordn1 = `wordn1'+1
	}


	** Find unique varnames in names2

	local match_n: word count `matches'
	local uniq2 ""

	local wordn2=1

	while `wordn2'<=`n2' {
		local var2: word `wordn2' of `names2'
		local uniq=0
		local match_i = 1
		while (`match_i' <= `match_n') & (`uniq'==0) {
			local match2: word `match_i' of `matches'

			if "`match2'" == "`var2'" {
				local uniq = 1
			}
			local match_i = `match_i' +1
		}

		if `uniq'==0 {
			local uniq2 "`uniq2' `var2'"
		}

		local wordn2 = `wordn2'+1
	}

	return local matches "`matches'"		
	return local uniq1 "`uniq1'"		
	return local uniq2 "`uniq2'"		

end

