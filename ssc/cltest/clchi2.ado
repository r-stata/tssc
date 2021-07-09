*!********** Adjusted Chi2 Program ********
*! Estimates chi2 statistic for dichotomous outcomes
*! on clustered data. May 30, 2000. Jeph Herrin
*! see also clprob.ado, cldiff.ado, and clttest.ado
capture program drop clchi2
program define clchi2, rclass
	version 7.0
	syntax varlist(min=2 max=2 default=none) [if] [in] , /*
*/		CLuster(varname) [TABle] [STRata(varname)]
	marksample touse
	if "`cluster'"!="" { 
		unabbrev `cluster', max(1)
		local clust "$S_1"
	}
	else {
		di in r "Must specify cluster"
		exit
	}
	if "`strata'"!="" { 
		unabbrev `strata', max(1)
		local strata "$S_1"
	}
	tokenize `varlist', parse(" ")
	local var1 "`1'"
	local var2 "`2'"
	if "`cluster'"==""|"`var1'"==""|"`var2'"==""  {
		di in gr "Syntax for " in wh "clchi2" _c
		di in gr ", the clustered chi2 is:"
		di in wh "clchi2 " in gr "v1 v2 " in wh ", cluster(" _c
		di in gr "v3" in wh ") strata(" _c
		di in gr "v4" in wh ") [table] "
		di in gr "  where " in wh "v1 " 
    		di in gr "is the dichotomous event variable"
		di in wh "        v2 " in gr "is the classification variable"
		di in wh "        v3 " in gr "is a required cluster variable"
		di in wh "        v4 " in gr "is an optional strata variable"
		exit
	}

	quietly {
	tempvar myin 
	tempname CT CA CR chi2 obs df PT PA PR rholb rhoub 
	tempname rho Nij Nt Xij P Pt summand nvar1 nvar2 nstr
	tempname M1 M2 A1 A2 chiMHA PM 
	tempname C1 C2 rhowarn rhoa rhou rhoal rhoau ind
	tempvar summand CA PA N P R C E T O Nij Nt Pt strvar strstr 
	tempvar topsum msum Mi Ai Ci size tmpvar

	gen byte `myin'= 1
	if ("`if'`in'"!="") {
		replace `myin'=0
		replace `myin'=1 `if' `in'
		}
	if "`strata'"!="" {
		inspect `strata'
		scalar `nstr'=r(N_unique)
		if `nstr'==. {
			di in r "Must have 1-99 `strata'!"
			exit
		}
		capture confirm string variable `strata'
		if _rc== 0 {
			gen str20 `strstr'=`strata'
		} 	
		else {
			gen str20 `strstr'=string(`strata')
		}
		encode `strstr', gen(`strvar')
	}
	else {
		gen `strvar'=1
	}
	replace `myin'=`myin'&`var1'!=.&`var2'!=.&`clust'!=.&`strvar'!=.
	} /* end quietly */

	quietly {
		preserve
		************* Pearson's and Rho *******
		keep if `myin'
		count
		if r(N) ==0 {
			di in r "No observations"
			exit
		}
		quietly tab `var1' `var2', chi2
		scalar `chi2'=r(chi2)
		scalar `obs'=r(N)
		quietly inspect `var1'
		scalar `nvar1'=r(N_unique)
		quietly inspect `var2'
		scalar `nvar2'=r(N_unique)
		loneway `var1' `clust'
		capture confirm existence r(rho)
		if _rc!=0 {
			global S_1 0
			local warn "Estimated < 0"
		}
		scalar `rho'=r(rho)
*		di in r `rho'
		scalar `rholb'=r(lb)
		scalar `rhoub'=r(ub)
		if `rho'==. {
			di in red "`var1' not grouped within `clust'"
			exit
		}
		scalar `df' = (`nvar1'-1)*(`nvar2'-1)
		*****************************************
		restore
		preserve
		**********  Pooled-adjustment ***********
		keep if `myin'
		collapse (count) `Nij'=`var1', by(`clust')
		gen `summand'=((`Nij'-1)*`rho'+1)*`Nij'
		collapse (sum) `Nij' `summand'
		scalar `CT'=`summand'[1]/`Nij'[1]
		scalar `CT'=`chi2'/`CT'
		scalar `PT' = chiprob(`df',`CT')
		*******************************************
		restore
		preserve
		************ Group-adjustment**************
		keep if `myin'
		sort `clust'
		by `clust'  :gen `summand'=((_N-1)*`rho'+1)
		egen `CA'=sum(`summand'), by(`var2')
		collapse (sum) `O'=`myin' (max) `CA', by(`var1' `var2')
		egen `R'=sum(`O'),by(`var1')
		egen `C'=sum(`O'),by(`var2')
		egen `T'=sum(`O')
		replace `CA'=`CA'/`C'
		gen `E' = (`R'*`C')/(`T')
		gen `summand'=((`O'-`E')^2)/(`CA'*`E')
		collapse (sum) `summand' 
		scalar `CA' = `summand'
		if `CA' < 0 { scalar `CA' = 0 }
		scalar `PA' = chiprob(`df',`CA')
		*******************************************
		restore
		preserve
		**********Adjusted MHA if stratified*******
		keep if `myin'
		if "`strata'"!="" {
			if `nvar1'!=2|`nvar2'!=2 {
				di in r "`var1'  = " `nvar1'
				di in r "`var2'  = " `nvar2'
				di in r "must have 2x2 for stratified MHA"
				exit
			}
			* make var1,var2 into  0/1 
			gen `tmpvar'=`var1'==`var1'[1]
			replace `var1'=`tmpvar'
			replace `tmpvar'=`var2'==`var2'[1]
			replace `var2'=`tmpvar'
			drop `tmpvar'
			scalar `ind' = 1
			scalar `rhoa' = 0
			while `ind'<=`nstr' {
				quietly loneway `var1' `clust' if `strvar'==`ind'
				capture confirm existence r(rho)
				if _rc!=0 {
					global S_1 0
				}
				scalar `rhoa'=`rhoa'+r(rho)
				scalar `ind' =`ind'+1
			}
			scalar `rhoa'=`rhoa'/`nstr'
			local rhowarn ""
			if `rhoa'==. {
				scalar `rhoa'=`rho'
				local rhowarn "Unadjusted rho used for stratified analysis"
			}

			#delimit ;
			collapse (max) `strvar' `var2' 
				 (count) `msum'=`var1' 
				 (sum) `Ai'=`var1', by(`clust');
			#delimit cr
			gen `topsum'=`msum'*(1+(`msum'-1)*`rhoa')
			collapse (sum) `Mi'=`msum' `Ai' `topsum' , by(`strvar' `var2')
			gen `Ci'=`topsum'/`Mi'
			gen `M1'=`Mi' if `var2'==0
			gen `M2'=`Mi' if `var2'==1
			gen `A1'=`Ai' if `var2'==0
			gen `A2'=`Ai' if `var2'==1
			gen `C1'=`Ci' if `var2'==0
			gen `C2'=`Ci' if `var2'==1
			collapse (max) `M1' `M2' `A1' `A2' `C1' `C2' , by(`strvar')
			gen `topsum'=`A1'*(`M2'-`A2')-`A2'*(`M1'-`A1')
			replace `topsum'=`topsum'/(`M1'*`C2'+`M2'*`C1')
			gen `msum'=`M1'*`M2'*(`A1'+`A2')*(`M1'+`M2'-`A1'-`A2')
			replace `msum'=`msum'/(`M1'*`C2'+`M2'*`C1'+1)
			replace `msum'=`msum'/((`M1'+`M2')^2)
			collapse (sum) `topsum' `msum'
			scalar `chiMHA'=abs(`topsum')-0.5
			scalar `chiMHA'=`chiMHA'^2
			scalar `chiMHA'=`chiMHA'/`msum'
			scalar `PM' = chiprob(`df',`chiMHA')
			***** end MHA ****************************
		}
		restore

		scalar `P' = chiprob(`df',`chi2')
	}  /* end quietly */
	if "`table'"!="" {
		tab `var1' `var2' if `myin', col row
	}
	di
	display in y " `var1'" in g " by " in y "`var2'" in g /*
*/                     ", clustered by " in y "`clust'"
	di in g  " ------------------------------------------------------"
	display in gr "  Inter-cluster correlation" _col(29) "= " /*
*/                     in y %16.4f `rho'
	display in g "      ICC 95% Asymptotic CI" _col(29) "= " /*
*/                     in g "     [" %6.4f in y `rholb' /*
*/                     in g "," %6.4f in y `rhoub' in g "]"
	if "`warn'"!="" {
		display in gr " `warn'"
	}
	display %1.0f in gr "         Pearson's Chi-2(" in y `df' in g ") = " _c
	display %9.4f in y `chi2' _c
	display %6.4f in gr _skip(4) " Pr = " in y %6.4f `P'
	display %1.0f in gr " Pooled adjustment Chi-2(" in y `df' in g ") = " _c
	display %9.4f in y `CT' _c
	display %6.4f in gr _skip(4) " Pr = " in y %6.4f `PT'
	display %1.0f in gr "  Group adjustment Chi-2(" in y `df' in g ") = " _c
	display %9.4f in y `CA' _c
	display %6.4f in gr _skip(4) " Pr = " in y %6.4f `PA'
	return scalar g_pval=`PA'
	if "`strata'"!="" {
		di in g  " ------------------------------------------------------"
		if "`rhowarn'"!="" {
			display in gr " `rhowarn'"
		}
		else {
			display in gr "        Strata-adjusted ICC" _col(29) "= " /*
*/                    		 in y %16.4f `rhoa'
		}
		display %1.0f in gr "    Stratified M-H Chi-2(" in y `df' in g ") = " _c
		display %9.4f in y `chiMHA' _c
		display %6.4f in gr _skip(4) " Pr = " in y %6.4f `PM'
		return scalar g_pval=`PM'
	}
end 
**************end program clchi2 ********
