*new version 2003-12-02. Added version clause
program define lincom2 , rclass
	version 6.0
	tempname oneres 
	tempname result


	/* get everything thats before the comma into titles */

	gettoken part 0 : 0, parse(",") quotes
	while `"`part'"' ~= "," & `"`part'"' ~= "" {
		local interac `"`interac' `part' "'
		gettoken part 0 : 0, parse(" ,") quotes
	}

	local 0 `",`0'"'

	syntax  [, debug verbose mtx(string) quiet varnam(string) new or]

	*if "`verbose'" ~="" & "`quiet" ~= "" {
	*	di in red "Can't specify both quiet and verbose!"
	*	error 999
	*}

	if "`quiet'" == "" { 
		di ""
		di "Lincom2: multiple lincom expressions"
		di _dup(10) "-" _newl
	}


	if "`mtx'" ~= "" {

		if "`new'" ~= "" {capture matrix drop `mtx'}

		/*first, check that the matrix exists*/
		/*if it doesn't, it will be created later */
		tempname temp
		capture matrix `temp'=rowsof(`mtx')
		capture local exist=`temp'[1,1]
		if "`exist'" ~= "" {
			/*if it does, it must have 1 row and 3 rows*/

			if rowsof(`mtx')<1 | colsof(`mtx')<3 {
				di in red "Matrix to be added must have >1 row and >=3 rows"
				error 999
			}

		}
		matrix `result'=J(1,3,0)
	}
	else {
		matrix `result'=J(1,3,0)
	}


	/* get ready to save the lincom expressions */
	if "`varnam'" ~= "" {

		/* put the variable names at the next empty 	*/
		/* space in varnam 				*/

		if "`new'" ~= "" {capture drop `varnam'}

		quietly {
		capture confirm variable `varnam'
		if _rc ~= 0 {
			gen str15 `varnam'=""
			local nxt=1
		}
		else {
			tempname n n2 
			gen `n'=_n

			gen `n2'=.
			replace `n2'=_n if `varnam'==""
			sort `n2'
			local nxt=`n2'[1]
			sort `n'
		}

		} /*quietly*/
	}



	if index("svylogit logistic logit","`e(cmd)'")==0 {
		di in red "No logistic command previously executed!"
		error 999
	}

	qui `e(cmd)'

	local terms 0
	local 0 `"`interac'"' 

	while "`0'" ~= "" {
		matrix `oneres'=J(1,3,0)

		gettoken lincom 0 : 0, parse("\")
		local 0=substr("`0'",2,999)

		if "`debug'" ~= "" {
			di "lincom: -`lincom'-"
			di "0: -`0'-"
		}


		/*store the lincom expressions in a text variable*/

		if "`varnam'" ~= "" {
			if `nxt'<= _N	{
				qui replace `varnam'="`lincom'" if _n==`nxt'
				local nxt=`nxt'+1
			}
		}

		if "`verbose'" ~= "" {
			di in blue "lincom `lincom'"
		}


		if "`or'" ~= "" {qui lincom `lincom' ,or}
		else {qui lincom `lincom' }

		local terms=`terms'+1
		

		if (`r(estimate)')<-709 | (`r(estimate)')>709 {
			di in red "Overflow error: Odds ratios <10^-308 or >10^308"
			di in red "Reset to 11"
			matrix `oneres'[1,1] = 1
		}
		else {
			matrix `oneres'[1,1] = exp(`r(estimate)')
		}

		if (`r(estimate)'-(`r(se)'*invnorm(0.975)))<-709 {
			di in red "Overflow error: Odds ratios <10^-308"
			di in red "Reset to 10^-308"
			matrix `oneres'[1,2] = 10^-308
		}
		else {
			matrix `oneres'[1,2] = exp(`r(estimate)'-(`r(se)'*invnorm(0.975)))
		}

		if (`r(estimate)'-(`r(se)'*invnorm(0.975)))>709 {
			di in red "Overflow error: Odds ratios >10^308"
			di in red "Reset to 10^308"
			matrix `oneres'[1,3] = 10^308
		}
		else {
			matrix `oneres'[1,3] = exp(`r(estimate)'+(`r(se)'*invnorm(0.975)))
		}

		matrix `result'=`result' \ `oneres'
	}
	
	matrix `result'=`result'[2...,1...] 

	if "`mtx'" ~= "" {
		capture matrix temp=rowsof(`mtx')
		if _rc == 0 {
			matrix `mtx'=`mtx' \ `result'
		}
		else {
			matrix `mtx'=`result'
		}
	}

	
	if "`debug'" ~= "" {
		matrix list `result' , nohea nona
	}

	/***************************************/
	/* Display the matrix in a pretty form */
	/***************************************/

	if "`quiet'" == "" { 

		local i 1

		di "Term #" _col(10) "OR" _col(18) "CIl" _col(28) "CIu"
		di _dup(31) "-"
		while `i'<=`terms' {
			di `i' _col(10) %6.4f `result'[`i',1] _col(18) %6.4f `result'[`i',2] _col(28) %6.4f `result'[`i',3]
			local i=`i'+1
		}
	}

	return matrix interac `result'
end
