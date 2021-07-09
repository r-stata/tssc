*! version 1.0.0  Qiang Chen 18July2020
program define kurtosisreg, eclass byable(recall) sortpreserve
    local cmdline : copy local 0
	version 16
	
	syntax varlist(numeric fv) [if] [in] [, Detail Graph Level(cilevel) Predict(string) Reps(integer 50) Seed(integer 1)]
    marksample touse
	
	gettoken depvar indeps : varlist
    _fv_check_depvar `depvar'
	
	tempname b_numerator V_numerator b_denominator V_denominator
	local q1 = 1/8
	local q2 = 2/8
	local q3 = 3/8
	local q4 = 5/8
	local q5 = 6/8
	local q6 = 7/8
	
	if "`detail'" != "" {
		set seed `seed'
		sqreg `depvar' `indeps' if `touse', q(`q1' `q2' `q3' `q4' `q5' `q6') reps(`reps') level(`level')
		display _n as txt "Fitting kurtosis regression..."
	}
	else {
		display _n as txt "Fitting kurtosis regression..."
		set seed `seed'
		quietly sqreg `depvar' `indeps' if `touse', q(`q1' `q2' `q3' `q4' `q5' `q6') reps(`reps') 	
	}
	
	local N = e(N)               
    local df_r = e(df_r) 
	
	local eqnames = e(eqnames)	
	gettoken eq1 eqn : eqnames
	gettoken eq2 eqn : eqn
	gettoken eq3 eqn : eqn
	gettoken eq4 eqn : eqn
	gettoken eq5 eq6 : eqn
	local eq6 = strtrim("`eq6'")
			
	local pr2_`eq1' = 1 - (e(sumadv1)/e(sumrdv1))
	local pr2_`eq2' = 1 - (e(sumadv2)/e(sumrdv2))
	local pr2_`eq3' = 1 - (e(sumadv3)/e(sumrdv3))
	local pr2_`eq4' = 1 - (e(sumadv4)/e(sumrdv4))
	local pr2_`eq5' = 1 - (e(sumadv5)/e(sumrdv5))
	local pr2_`eq6' = 1 - (e(sumadv6)/e(sumrdv6))
	
	if "`predict'" != "" {
	quietly predictnl `predict' = (xb(#6)-xb(#4)+xb(#3)-xb(#1))/(xb(#5)-xb(#2)) if `touse'
	}	
	
	quietly margins if `touse',dydx(*) expression((xb(#6)-xb(#4)+xb(#3)-xb(#1))/(xb(#5)-xb(#2)))
	if "`graph'" != "" {
		quietly marginsplot,yline(0) ytitle("Effects on Conditional Kurtosis") level(`level')
	}
	tempname b_ame V_ame
	matrix `b_ame' = r(b)
	matrix `V_ame' = r(V)
	
	if "`detail'" != "" {
		quietly margins if `touse',dydx(*) expression(xb(#6)-xb(#4)+xb(#3)-xb(#1))
		tempname b_numerator V_numerator
		matrix `b_numerator' = r(b)
		matrix `V_numerator' = r(V)		
		
		quietly margins if `touse',dydx(*) expression(xb(#5)-xb(#2))
		tempname b_denominator V_denominator
		matrix `b_denominator' = r(b)
		matrix `V_denominator' = r(V)
		
		ereturn post `b_numerator' `V_numerator', buildfvinfo depname(Numerator) dof(`df_r') obs(`N') 
		display _n as txt "Kurtosis regression: The numerator part" _column(54) "Number of obs =  " as result %8.0fc `N'
		display _column(1) as txt "[Q(7/8|x)-Q(5/8|x)]-[Q(3/8|x)-Q(1/8|x)]" _column(56) "Random seed =  " as result %8.0fc `seed'
		display _column(53) as txt "Number of reps =  " as result %8.0fc `reps' _continue
		display _newline(1)
		ereturn display,level(`level')  
	
		ereturn post `b_denominator' `V_denominator', buildfvinfo depname(Denominator) dof(`df_r') obs(`N') 
		display _n as txt "Kurtosis regression: The denominator part" _column(54) "Number of obs =  " as result %8.0fc `N'
		display _column(1) as txt "[Q(6/8|x)-Q(2/8|x)]" _column(56) "Random seed =  " as result %8.0fc `seed'
		display as txt "(same as spread/interquantile regression)" _column(53) as txt "Number of reps =  " as result %8.0fc `reps' _continue
		display _newline(1)
		ereturn display,level(`level')  
	}
		
	ereturn post `b_ame' `V_ame', buildfvinfo depname(Kurtosis) dof(`df_r') obs(`N') esample(`touse') 
	display _n as txt "Kurtosis regression: Average marginal effects" _column(54) "Number of obs =  " as result %8.0fc `N'
	display _column(2) as txt "[Q(7/8|x)-Q(5/8|x)]-[Q(3/8|x)-Q(1/8|x)]" _column(56) "Random seed =  " as result %8.0fc `seed'
	display _column(1) as text "{hline 41}" _column(53) "Number of reps =  " as result %8.0fc `reps' 
	display _column(13) as txt "Q(6/8|x)-Q(2/8|x)" _continue 
	display _newline(1)
	ereturn display,level(`level') 
	display "Note: Std. Err. computed by the delta method from bootstrap standard errors."	

	ereturn scalar N   = `N'
	ereturn scalar df_r   = `df_r'
	ereturn scalar reps = `reps'
	ereturn scalar seed = `seed'
	ereturn scalar  q1 = 1/8
	ereturn scalar  q2 = 2/8
	ereturn scalar  q3 = 3/8
	ereturn scalar  q4 = 5/8
	ereturn scalar  q5 = 6/8
	ereturn scalar  q6 = 7/8
	ereturn scalar pr2_`eq1' = `pr2_`eq1''
	ereturn scalar pr2_`eq2' = `pr2_`eq2''
	ereturn scalar pr2_`eq3' = `pr2_`eq3''
	ereturn scalar pr2_`eq4' = `pr2_`eq4''
	ereturn scalar pr2_`eq5' = `pr2_`eq5''
	ereturn scalar pr2_`eq6' = `pr2_`eq6''
	ereturn local cmd "kurtosisreg"	
	ereturn local cmdline `"kurtosisreg `cmdline'"'
	ereturn local eqnames "`eqnames'"
	ereturn local vcetype "Delta-method"

end
 
 
 
 