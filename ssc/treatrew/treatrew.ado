*! treatrew v1.0.0 GCerulli 01oct2012
capture program drop treatrew
program treatrew, eclass
	version 11
	#delimit ;
	syntax varlist [if] [in] [fweight iweight pweight]  , model(string)
	[GRaphic 
	vce(string) 
	conf(numlist max=1)];
	#delimit cr
	***********************************************************************
	* DROP OUTCOME VARIABLES GENERATED LATER ON
	***********************************************************************
	capture drop ATE_x ATET_x ATENT_x
	***********************************************************************
	* PARSE SYNTAX
	***********************************************************************
	marksample touse
	tokenize `varlist'
    	local y `1'
    	local w `2'
	macro shift
	macro shift
	local xvars `*'
	***********************************************************************
	* PROBIT ESTIMATION
	***********************************************************************
	if "`model'"=="probit"{                         // start "if" for probit
	probit `w' `xvars' if `touse', nolog `vce' level(`conf')
	scalar N=e(N)
	ereturn scalar N=N
	qui tab `w' if `w'==1 & `touse' & e(sample)
	scalar N1=r(N)
	ereturn scalar N1=N1
	qui tab `w' if `w'==0 & `touse' & e(sample)
	scalar N0=r(N)
	ereturn scalar N0=N0
	tempvar G_fv
    	predict `G_fv' if `touse' & e(sample) , p
	***********************************************************************
	* ESTIMATION OF: (ATE_x, ATE), (ATET_x, ATET), ATENT_x, ATENT) 
	***********************************************************************
	capture drop ATE_x ATET_x ATENT_x
	gen ATE_x=((`w'-`G_fv')*`y')/(`G_fv'*(1-`G_fv'))
	qui sum ATE_x
	scalar ate=r(mean)
	ereturn scalar ate=r(mean) 
	gen ATET_x=((`w'-`G_fv')*`y')/(N1/N*(1-`G_fv'))
	qui sum ATET_x
	scalar atet=r(mean)
	ereturn scalar atet=r(mean) 
	gen ATENT_x=((`w'-`G_fv')*`y')/(N0/N*`G_fv')
	qui sum ATENT_x
	scalar atent=r(mean)
	ereturn scalar atent=r(mean)
	********************************
	*** CALCULATE THE VECTOR "d" ***
	********************************
	qui probit `w' `xvars' if `touse' & e(sample), nolog `vce' level(`conf')
    tempvar xteta1
    predict `xteta1' if `touse' & e(sample) , xb
	tempvar FI1 fi1 g
	gen `FI1'  = normal(`xteta1')    if `touse' & e(sample)
	gen `fi1'  = normalden(`xteta1') if `touse' & e(sample)
	gen `g'=`fi1'*(`w'-`FI1')/`FI1'*(1-`FI1')
	local dvars
	foreach var in `xvars'{
	tempvar _d_`var'
	}	
	foreach var in `xvars'{   // Generate "d=dvars"
	gen `_d_`var''=`var'*`g' if `touse' & e(sample)
	local dvars `dvars' `_d_`var''
	}
	} 												  // end "if" for probit
	************************************************************************
	else{
	if "`model'"=="logit"{  							 // start "if" for logit
	logit `w' `xvars' if `touse', nolog `vce' level(`conf')
	scalar N=e(N)
	ereturn scalar N=N
	qui tab `w' if `w'==1 & `touse' & e(sample)
	scalar N1=r(N)
	ereturn scalar N1=N1
	qui tab `w' if `w'==0 & `touse' & e(sample)
	scalar N0=r(N)
	ereturn scalar N0=N0
	tempvar G_fv
    predict `G_fv' if `touse' & e(sample) , p
	***********************************************************************
	* ESTIMATION OF: (ATE_x, ATE), (ATET_x, ATET), ATENT_x, ATENT) 
	***********************************************************************
	capture drop ATE_x ATET_x ATENT_x
	gen ATE_x=((`w'-`G_fv')*`y')/(`G_fv'*(1-`G_fv'))
	qui sum ATE_x
	scalar ate=r(mean)
	ereturn scalar ate=r(mean) 
	gen ATET_x=((`w'-`G_fv')*`y')/(N1/N*(1-`G_fv'))
	qui sum ATET_x
	scalar atet=r(mean)
	ereturn scalar atet=r(mean) 
	gen ATENT_x=((`w'-`G_fv')*`y')/(N0/N*`G_fv')
	qui sum ATENT_x
	scalar atent=r(mean)
	ereturn scalar atent=r(mean)
	********************************
	*** CALCULATE THE VECTOR "d" ***
	********************************
	qui logit `w' `xvars' if `touse' & e(sample), nolog `vce' level(`conf')
    tempvar xteta1
    predict `xteta1' if `touse' & e(sample) , xb
	tempvar lamda g
	gen `lamda' = exp(`xteta1')/(1-exp(`xteta1'))  if `touse' & e(sample)
	gen `g'= (`w'-`lamda')
	local dvars
	foreach var in `xvars'{
	tempvar _d_`var'
	}	
	foreach var in `xvars'{   // Generate "d=dvars"
	gen `_d_`var''=`var'*`g' if `touse' & e(sample)
	local dvars `dvars' `_d_`var''
	}
	} 												   // end "if" for logit
	}
	************************************************************************
	* CALCULATE STD. ERR. FOR: ATE, ATET, ATENT
	************************************************************************
	************************
	*** STD.ERR. for ATE ***
	************************
	qui reg ATE_x `dvars' if `touse' & e(sample)
	tempvar e e2
	predict `e' if `touse' & e(sample) , res
	gen `e2'=`e'^2
	qui sum `e2'
	scalar mean_e2=r(mean)
	scalar N_e2=r(N)
	scalar std=sqrt(mean_e2)/sqrt(N_e2)
	scalar ttest=ate/std
	local numvars : word count `xvars'
	scalar df=N-(`numvars'+1)
	scalar pvalue=2*ttail(df,abs(ttest))
	*************************
	*** STD.ERR. for ATET ***
	*************************
	qui reg ATET_x `dvars' if `touse' & e(sample)
	tempvar e rw rw2
	predict `e' if `touse' & e(sample), res
	gen `rw'=(`e'-`w'*atet)
	gen `rw2'=`rw'^2
	qui sum `rw2'
	scalar mean_rw2=r(mean)
	scalar std1=(N1/N)^(-1)*sqrt(mean_rw2)/sqrt(N)
	scalar ttest1=atet/std1
	local numvars : word count `xvars'
	scalar df1=N-(`numvars'+1)
	scalar pvalue1=2*ttail(df1,abs(ttest1))
	**************************
	*** STD.ERR. for ATENT ***
	**************************
	qui reg ATENT_x `dvars' if `touse' & e(sample)
	tempvar e rw rw2
	predict `e' if `touse' & e(sample), res
	gen `rw'=(`e'-(1-`w')*atent)
	gen `rw2'=`rw'^2
	qui sum `rw2'
	scalar mean_rw3=r(mean)
	scalar std0=(N0/N)^(-1)*sqrt(mean_rw3)/sqrt(N)
	scalar ttest0=atent/std0
	local numvars : word count `xvars'
	scalar df0=N-(`numvars'+1)
	scalar pvalue0=2*ttail(df0,abs(ttest0))
	***********************************************************************
	* RESULTS AND TABLE BY "ereturn post" AND "ereturn display"
	***********************************************************************
	tempname b V
	matrix `b' = (ate,atet,atent)
	matrix `V' = (std^2,0,0\0,std1^2,0\0,0,std0^2)
	matrix colnames `b' = ATE ATET ATENT  // We reneame the columns of b
    matrix rownames `V' = ATE ATET ATENT  // To work, rows' names of V are to be equal to that of b
    matrix colnames `V' = ATE ATET ATENT  // To work, columns' names of V are to be equal to that of b
	ereturn post `b' `V' , esample(`touse')
	ereturn local depvar "`y'"
	qui sum ATE_x
	ereturn scalar ate=r(mean)
	qui sum ATET_x
	ereturn scalar atet=r(mean)
	qui sum ATENT_x
	ereturn scalar atent=r(mean)
	ereturn scalar N=N
	ereturn scalar N0=N0
	ereturn scalar N1=N1
	ereturn local cmd "treatrew"
	di _newline(2)
	di as text "Test of significance for ATE, ATET and ATENT with analytical Std. Err."
	ereturn display 
	di as text "Reference model: `model'"
	************************************************************************
	* GRAPHING ATE(x), ATET(x), ATENT(x)
	************************************************************************
	if "`graphic'"=="graphic"{
	graph_rw `model'
	}
	end
***********************************************************************
* PROGRAM "graph_rw" TO DRAW THE OVELAPPING DISTRIBUTIONS 
* OF ATE(x), ATET(x) and ATENT(x)
***********************************************************************
*! graph_rw v1.0.0 GCerulli 25aug2010
capture program drop graph_rw
program graph_rw
args mod
version 11
twoway kdensity ATE_x , /// 
|| ///
kdensity ATET_x , lpattern(dash) ///
|| ///
kdensity ATENT_x , lpattern(longdash_dot) xtitle() ///
ytitle(Kernel density) legend(order(1 "ATE(x)" 2 "ATET(x)" 3 "ATENT(x)")) ///
title("Reweighting: Comparison of ATE(x) ATET(x) ATENT(x)", size(medlarge)) name() ///
note("Model:`mod'" )
end
*END "TREATERW"
