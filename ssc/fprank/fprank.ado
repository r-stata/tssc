program define fprank,sortpreserve rclass byable(recall)
	version 10.1
	syntax varname (numeric) [if] [in], BY(varlist) 
	marksample touse
	markout `touse' `by'
	tempname Gr1 Gr2 p dubl n1
	tempvar rankt ranku avg
	local bytype : type `by'
	if substr("`bytype'",1,3)== "str" {
		di as err "The grouping variable should be numeric"
		exit 2000
	}
	qui {	
	sort `varlist'
	summarize `by' if `touse', meanonly
	}
	if r(N) == 0 {
		di as err "There are no observations"
		exit 2000
	}
	if r(min) == r(max) {
		di as err `"The grouping variable should have two groups"'
		exit 499
	}
	qui {
	scalar `Gr1' = r(min)    
	scalar `Gr2' = r(max)    

	count if `by'!=`Gr1' & `by'!=`Gr2' & `touse'
	if r(N) != 0 {
		di as err  `"More than 2 groups found, only 2 allowed"'
		exit 499
	}
	count if  `by'==`Gr1' & `touse'
	local n=r(N)
	count if  `by'==`Gr2' & `touse'
	local m=r(N)
	egen  double `rankt' = rank(`varlist') if `touse',t
	egen  double `ranku' = rank(`varlist') if `touse',u
	egen  double `avg' = mean( `ranku'), by (`rankt')
	sort `by' `avg'
	by `by' : gen `n1' = _n
	gen `p'=`avg'-`n1'
	sum  `p' if  `by'==`Gr1' & `touse'
	ret scalar N_1=r(N)
	ret scalar mean_1=r(mean)
	ret scalar Var_1=(return(N_1)-1)* r(Var) /*Fligner-Policello variance*/
	sum  `p' if  `by'==`Gr2' & `touse'
	ret scalar N_2=r(N)
	ret scalar mean_2=r(mean)
	ret scalar Var_2=(return(N_2)-1)*r(Var)
	local num=(return(N_1)*return(mean_1))-(return(N_2)*return(mean_2))
	local den=2*sqrt(return(Var_1)+return(Var_2)+(return(mean_1)*return(mean_2)))
	ret scalar U=`num'/`den' /*Fligner-Policello statistic*/
	local prob=2*normprob(-abs(return(U)))
	local prob1=`prob'/2
	}
	local LGr1 = `Gr1'
	local LGr2 = `Gr2'
	local lby : value label `by'
	if `"`lby'"'!=`""' {
		local LGr1 : label `lby' `LGr1'
		local LGr2 : label `lby' `LGr2'
	}
	if return(N_1)<=12 & return(N_2)<=12 {
		di in smcl _newline(1)"{p}{error}{bf}Warning :{result}{sf} The asymptotic p-value may " /*
		*/ "not be a good approximation when both samples {break} are <= 12. To obtain " /*
		*/ "the significance of the statistic U, calculated below,  refer {break}to the table " /*
		*/ "of critical values of U for the robust rank order test for small {break} sample sizes (<=12) "/*
		*/"(See {help fprank:help fprank} for refrences){p_end} "
	}
	di _n in text _col(10) "Two-Sample Fligner-Policello Robust Rank Order Test" _n
	di in smcl in text"    Variable {c |}    Obs"  _col(30) "Mean" /*
		*/ _col(41) " Index of   " _col(58) "U     Asymptotic" _n /*
		*/ _col(14) "{c |}"_col(41) "Variability " _col(58) "      2-tailed P*" _n /*	
		*/ "{hline 13}{c +}{hline 62}"
	#delimit ;
	di in smcl in text %12s abbrev("`LGr1'",12) " {c |}" in result
		%7.0f return(N_1) _col(28)
		%8.5f return(mean_1) _col(42)
		%8.5f return(Var_1) _col(53)
		%8.3f return(U) "    "
		%7.5f `prob'
	;
	#delimit ;
	di in smcl in text %12s abbrev("`LGr2'",12) " {c |}" in result
		%7.0f return(N_2) _col(28)
		%8.5f return(mean_2) _col(42)
		%8.5f return(Var_2) _col(53)
	;
	#delimit cr
	di in smcl in text "{hline 13}{c BT}{hline 62}"
	di in smcl in text "* 1-tailed asymptotic p-value = " in result  %7.5f `prob1'  	


end
		

