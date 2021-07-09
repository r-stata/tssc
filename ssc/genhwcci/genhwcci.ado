****************************************************************
*! Version 9.0.2, 7 October 2006
*! Author: James Cui, Monash University
*! Perform Hardy-Weinberg Equilibrium Test in case-control study
*! Original publication: Sep 2000 STB 57: 17-19
*! Update 07Oct06: table position use _col
****************************************************************

capture program drop genhwcci
program genhwcci, rclass
version 9.0
	
	gettoken AA1 0 : 0, parse(" ,")
	gettoken Aa1 0 : 0, parse(" ,")
	gettoken aa1 0 : 0, parse(" ,")
	gettoken AA2 0 : 0, parse(" ,")
	gettoken Aa2 0 : 0, parse(" ,")
	gettoken aa2 0 : 0, parse(" ,")

	confirm integer number `AA1'
	confirm integer number `Aa1'
	confirm integer number `aa1'
	confirm integer number `AA2'
	confirm integer number `Aa2'
	confirm integer number `aa2'

	if (`AA1'<0 | `Aa1'<0 | `aa1'<0 | `AA2'<0 | `Aa2'<0 | `aa2'<0) {
		di in red "negative numbers invalid"
		exit 498
	}

	syntax [, Label(string) Binvar ]

	tempname obs1 obs2 obs AA Aa aa nA1 na1 nA2 na2 nA na 	
		
	scalar `obs1' = `AA1' + `Aa1' + `aa1'
 	scalar `obs2' = `AA2' + `Aa2' + `aa2'
	scalar `obs' = `obs1' + `obs2'
	scalar `AA' = `AA1' + `AA2'
	scalar `Aa' = `Aa1' + `Aa2'
	scalar `aa' = `aa1' + `aa2'
	scalar `nA1' = 2*(`AA1') + `Aa1'
	scalar `na1' = 2*(`aa1') + `Aa1'
	scalar `nA2' = 2*(`AA2') + `Aa2'
	scalar `na2' = 2*(`aa2') + `Aa2'
	scalar `nA' = 2*(`AA') + `Aa'
	scalar `na' = 2*(`aa') + `Aa'

	local nob = `nA' + 1

	if _N < `nA' {
		preserve	
		qui set obs `nob'
	}

	if "`label'" ~= "" {
		parse "`label'", parse (" ")
		local  naAA = "`1'"
		local  naAa = "`2'"
		local  naaa = "`3'"
	}	
	else {
		local  naAA = "AA"
           	local  naAa = "Aa"
           	local  naaa = "aa"
	}
	local al1 = substr("`naAA'",1,1)
	local al2 = substr("`naaa'",1,1)


*---------------------------------------------------------------
* 1. CASE-CONTROL TABLE
*---------------------------------------------------------------

	di in gr _col(9) "Genotype |" _col(28) "Case" _col(41) "Control  |" _col(59) "Total"
	di in gr _col(6) "------------+-------------------------------+-------------"

	di in gr %16s 	/*
	*/ 	"`naAA'" " |" in ye _col(24) %8.0f `AA1' _col(40) %8.0f `AA2' 	/*
	*/	_col(50) in gr "|" in ye _col(56) %8.0f `AA' 

	di in gr %16s 	/*
	*/ 	"`naAa'" " |" in ye _col(24) %8.0f `Aa1' _col(40) %8.0f `Aa2' 	/*
	*/	_col(50) in gr "|" in ye _col(56) %8.0f `Aa'

	di in gr %16s 	/*
	*/ 	"`naaa'" " |" in ye _col(24) %8.0f `aa1' _col(40) %8.0f `aa2' 	/*
	*/	_col(50) in gr "|" in ye _col(56) %8.0f `aa'
	
	di in gr _col(6) "------------+-------------------------------+-------------"

	di in gr _col(12) "total" " |"		/*
	*/ 	in ye _col(24) %8.0f `obs1' _col(40) %8.0f `obs2' 		/*
	*/    _col(50) in gr "|" in ye _col(56) %8.0f `obs' 


*---------------------------------------------------------------
* 2. CHI-SQUARE TEST
*---------------------------------------------------------------

	tempname pAA1 pAa1 paa1 pA1 pa1 pA2 pa2
	scalar `pAA1' = `AA1'/`obs1'
	scalar `pAa1' = `Aa1'/`obs1'
	scalar `paa1' = `aa1'/`obs1'
	scalar `pA1' = `nA1'/(2*`obs1')
	scalar `pa1' = `na1'/(2*`obs1')
	scalar `pA2' = `nA2'/(2*`obs2')
	scalar `pa2' = `na2'/(2*`obs2')

	tempname eAA1 eAa1 eaa1 eAA2 eAa2 eaa2 xAA1 xAa1 xaa1 
	tempname xAA2 xAa2 xaa2 chi1 chi2 eobs1 eobs2
	scalar `eAA1' = `obs1'*(`pA1'^2)	
	scalar `eAa1' = `obs1'*2*(`pA1'*`pa1')	
	scalar `eaa1' = `obs1'*(`pa1'^2)	
	scalar `eAA2' = `obs2'*(`pA2'^2)	
	scalar `eAa2' = `obs2'*2*(`pA2'*`pa2')
	scalar `eaa2' = `obs2'*(`pa2'^2)	
	scalar `xAA1' = ((`AA1'-`eAA1')^2)/`eAA1'	
	scalar `xAa1' = ((`Aa1'-`eAa1')^2)/`eAa1'	
	scalar `xaa1' = ((`aa1'-`eaa1')^2)/`eaa1'	
	scalar `xAA2' = ((`AA2'-`eAA2')^2)/`eAA2'	
	scalar `xAa2' = ((`Aa2'-`eAa2')^2)/`eAa2'	
	scalar `xaa2' = ((`aa2'-`eaa2')^2)/`eaa2'	
	scalar `chi1' = `xAA1'+`xAa1'+`xaa1'
	scalar `chi2' = `xAA2'+`xAa2'+`xaa2'
	scalar `eobs1' = `eAA1'+`eAa1'+`eaa1'
	scalar `eobs2' = `eAA2'+`eAa2'+`eaa2'


	tempname llo1 lle1 llo2 lle2 lr1 lr2
	scalar `llo1'= (`AA1'*ln(`AA1'/`obs1')) /*
		*/ + (`Aa1'*ln(`Aa1'/`obs1')) /*
		*/ + (`aa1'*ln(`aa1'/`obs1'))
		
	scalar `lle1'= (`AA1'*ln(`eAA1'/`eobs1')) /*
		*/ + (`Aa1'*ln(`eAa1'/`eobs1')) /*
		*/ + (`aa1'*ln(`eaa1'/`eobs1'))
		
	scalar `llo2'= (`AA2'*ln(`AA2'/`obs2')) /*
		*/ + (`Aa2'*ln(`Aa2'/`obs2')) /*
		*/ + (`aa2'*ln(`aa2'/`obs2'))
		
	scalar `lle2'= (`AA2'*ln(`eAA2'/`eobs2')) /*
		*/ + (`Aa2'*ln(`eAa2'/`eobs2')) /*
		*/ + (`aa2'*ln(`eaa2'/`eobs2'))
	
	scalar `lr1'=2*(`llo1'-`lle1')
	scalar `lr2'=2*(`llo2'-`lle2')

	tempvar nAA1 nAa1 naa1 pobs1 pcal1 pval1 sump1
	qui gen int `nAA1'=_n-1
	qui gen int `nAa1'=`nA1'-2*(`nAA1')
	qui replace `nAA1'=. if `nAa1'<0

	qui gen double `pcal1'= 	/*
	*/	lnfact(`obs1') - lnfact(2*`obs1') + lnfact(`nA1') +	/*
	*/	lnfact(2*`obs1'-`nA1') - lnfact(`nAa1')-lnfact((`nA1' - `nAa1')/2)-	/*
	*/	lnfact(`obs1'-(`nA1'+`nAa1')/2)

	qui replace `pcal1'=exp(`pcal1'+(`nAa1')*ln(2))
	qui gen double `pobs1'=`pcal1' if `nAa1'==`Aa1'	
	qui sort `pobs1' `pcal1'
	qui replace `pobs1'=`pobs1'[_n-1] if `pobs1'==. & `pcal1'!=.
	qui gen double  `pval1'=`pcal1' if `pcal1'<=`pobs1'
	qui gen double `sump1'=sum(`pval1')


	tempvar nAA2 nAa2 naa2 pobs2 pcal2 pval2 sump2
	qui gen int `nAA2'=_n-1
	qui gen int `nAa2'=`nA2'-2*(`nAA2')
	qui replace `nAA2'=. if `nAa2'<0

	qui gen double `pcal2'= 	/*
	*/	lnfact(`obs2') - lnfact(2*`obs2') + lnfact(`nA2') +	/*		
	*/	lnfact(2*`obs2'-`nA2') - lnfact(`nAa2')-lnfact((`nA2' - `nAa2')/2)-	/*
	*/	lnfact(`obs2'-(`nA2'+`nAa2')/2)

	qui replace `pcal2'=exp(`pcal2'+(`nAa2')*ln(2))
	qui gen double `pobs2'=`pcal2' if `nAa2'==`Aa2'	
	qui sort `pobs2' `pcal2'
	qui replace `pobs2'=`pobs2'[_n-1] if `pobs2'==. & `pcal2'!=.
	qui gen double  `pval2'=`pcal2' if `pcal2'<=`pobs2'
	qui gen double `sump2'=sum(`pval2')


	tempname p0 q0 L0 L1 x2
	scalar `p0'= `nA'/(2*`obs')
	scalar `q0'= 1.0-`p0'
	scalar `L0'= `AA'*ln((`p0')^2)+`Aa'*ln(2*(`p0')*(`q0'))+`aa'*ln((`q0')^2)

	scalar `L1'=`AA1'*ln(`pAA1')+`Aa1'*ln(`pAa1')+`aa1'*ln(`paa1')	/*
	*/ 	    +`AA2'*ln((`pA2')^2)+`Aa2'*ln(2*`pA2'*`pa2')+		/*
	*/	    `aa2'*ln((`pa2')^2)
	qui gen `x2' = -2*(`L0'-`L1')


	tempname D1 D2 VD1 VD2 ED1 ED2 
	scalar `D1'=(`AA1'/`obs1')-(`pA1'^2)
	scalar `D2'=(`AA2'/`obs2')-(`pA2'^2)
	scalar `ED1'=`D1'-(1/(2*`obs1'))*(`pA1'*(1-`pA1')+`D1')
	scalar `ED2'=`D2'-(1/(2*`obs2'))*(`pA2'*(1-`pA2')+`D2')
	scalar `VD1'=(1/`obs1')* ( (`pA1'^2) * ((1-`pA1')^2) + ((1-2*`pA1')^2)*`D1' - `D1'^2)
	scalar `VD2'=(1/`obs2')* ( (`pA2'^2) * ((1-`pA2')^2) + ((1-2*`pA2')^2)*`D2' - `D2'^2)

	tempname se1 se2 se3 se4
	if `"`binvar'"'=="" {
		scalar `se1'= sqrt((1/(2*`obs1'))*(`pA1'+(`AA1'/`obs1')-2*(`pA1'^2)))
		scalar `se2'= sqrt((1/(2*`obs1'))*(`pa1'+(`aa1'/`obs1')-2*(`pa1'^2)))
		scalar `se3'= sqrt((1/(2*`obs2'))*(`pA2'+(`AA2'/`obs2')-2*(`pA2'^2)))
		scalar `se4'= sqrt((1/(2*`obs2'))*(`pa2'+(`aa2'/`obs2')-2*(`pa2'^2)))
	}
	else {
		scalar `se1'=sqrt(`pA1' * `pa1' / (2 * `obs1'))
		scalar `se2'=`se1'
		scalar `se3'=sqrt(`pA2' * `pa2' / (2 * `obs2'))
		scalar `se4'=`se3'
		local vartype " (binomial)"
	}


*---------------------------------------------------------------
* 3. CASE ONLY TABLE
*---------------------------------------------------------------
		
	di ""
	di in gr _col(13) "Case"
	/* di in gr "     Allele frequencies      " */

	di in gr /*
	*/  "          Allele |     Case     Frequency      Std. Err."

	di in gr _col(6) "------------+--------------------------------------"

	di in gr /*
	*/ %16s "`al1'" " |" in ye _col(20) %8.0f `nA1' /*
	*/ _col(34) %8.4f `pA1'  _col(49) %8.4f `se1' "`vartype'"

	di in gr /*
	*/ %16s "`al2'" " |" in ye _col(20) %8.0f `na1'/*
	*/  _col(34) %8.4f `pa1' _col(49) %8.4f `se2' "`vartype'"

	di in gr _col(6) "------------+--------------------------------------"

	di in gr _col(12) "total" " |" /*
	*/  in ye _col(20) %8.0f `na1'+`nA1' _col(34) %8.4f `pA1'+`pa1' 

	di in gr _col(6) "------------+--------------------------------------"

	di in gr _col(6) "Estimated disequilibrium coefficient (D) = "  /*
	*/  in ye %8.4f `D1'   /*
	*/  _n in gr _col(42) "  SE = " in ye %8.4f sqrt(`VD1')

	di in gr "     Hardy-Weinberg Equilibrium Test: "
	di in gr /*
	*/ "              Pearson chi2 (" in ye "1" in gr ") = " /* 
	*/ in ye %8.3f `chi1' /*
	*/  in gr "  Pr= " in ye %5.4f  chiprob(1,`chi1')

	di in gr /*
	*/ "     likelihood-ratio chi2 (" in ye "1" in gr ") = " /* 
	*/ in ye %8.3f `lr1' /*
	*/  in gr "  Pr= " in ye %5.4f  chiprob(1,`lr1')

	di in gr  /*
	*/ "     Exact significance prob   =               " /*
	*/ in ye %5.4f `sump1'[_N]  



*---------------------------------------------------------------
* 4. RETURN LIST IN CASES
*---------------------------------------------------------------

	return scalar N_1 = `obs1'
	return scalar chi2_1 = `chi1'
	return scalar pchi2_1 = chiprob(1,`chi1')
	return scalar lr_1 = `lr1'
	return scalar plr_1 = chiprob(1,`lr1')
	return scalar pexact_1 = `sump1'[_N]


*---------------------------------------------------------------
* 5. CONTROL ONLY TABLE
*---------------------------------------------------------------

	di ""
	di in gr _col(10) "Control"
	/* di in gr "     Allele frequencies      " */

	di in gr /*
	*/  "          Allele |  Control     Frequency      Std. Err."

	di in gr _col(6) "------------+--------------------------------------"

	di in gr /*
	*/ %16s "`al1'" " |" in ye _col(20) %8.0f `nA2' /*
	*/ _col(34) %8.4f `pA2'  _col(49) %8.4f `se3' "`vartype'"

	di in gr /*
	*/ %16s "`al2'" " |" in ye _col(20) %8.0f `na2'/*
	*/  _col(34) %8.4f `pa2' _col(49) %8.4f `se4' "`vartype'"

	di in gr _col(6) "------------+--------------------------------------"

	di in gr _col(12) "total" " |" /*
	*/  in ye _col(20) %8.0f `na2'+`nA2' _col(34) %8.4f `pA2'+`pa2' 

	di in gr _col(6) "------------+--------------------------------------"


	di in gr _col(6) "Estimated disequilibrium coefficient (D) = " /*
	*/    in ye %8.4f `D2'	/*
	*/    _n in gr _col(42) "  SE = " in ye %8.4f sqrt(`VD2')			 

	di in gr "     Hardy-Weinberg Equilibrium Test: "
	di in gr /*
	*/ "              Pearson chi2 (" in ye "1" in gr ") = " /* 
	*/ in ye %8.3f `chi2' /*
	*/  in gr "  Pr= " in ye %5.4f  chiprob(1,`chi2')

	di in gr /*
	*/ "     likelihood-ratio chi2 (" in ye "1" in gr ") = " /* 
	*/ in ye %8.3f `lr2' /*
	*/  in gr "  Pr= " in ye %5.4f  chiprob(1,`lr2')

	di in gr  /*
	*/ "     Exact significance prob   =               " /*
	*/ in ye %5.4f `sump2'[_N]  

*---------------------------------------------------------------
* 6. RETURN LIST IN CONTROLS
*---------------------------------------------------------------

	return scalar N_0 = `obs2'
	return scalar chi2_0 = `chi2'
	return scalar pchi2_0 = chiprob(1,`chi2')
	return scalar lr_0 = `lr2'
	return scalar plr_0 = chiprob(1,`lr2')
	return scalar pexact_0 = `sump2'[_N]
	
*---------------------------------------------------------------
* 7. GIVEN CONTROLS UNDER HWE, TEST CASES UNDER HWE
*---------------------------------------------------------------

	di _n _col(6) in gr "Test H0: cases under HWE: (given controls under HWE)"
	di in gr /*
	*/ "     likelihood-ratio chi2 (" in ye "2" in gr ") = " /* 
	*/ in ye %8.3f `x2' /*
	*/  in gr "  Pr= " in ye %5.4f  chiprob(2,`x2')

*---------------------------------------------------------------
* 8. UPDATED RETURN VALUES
*---------------------------------------------------------------

	return scalar lr_c = `x2'
	return scalar plr_c = chiprob(2,`x2')


end
