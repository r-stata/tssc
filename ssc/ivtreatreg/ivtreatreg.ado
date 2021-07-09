*! ivtreatreg v1.1.1 GCerulli 30jua2014
program ivtreatreg, eclass
	version 11
	#delimit ;     
	syntax varlist [if] [in] [fweight iweight pweight] [, 
	hetero(varlist numeric) 
	vce(string) 
	beta 
	graphic
	const(string) 
	head(string) 
	conf(numlist max=1)
	iv(varlist numeric)
	model(string)];
	#delimit cr
	***********************************************************************
	* DROP OUTCOME VARIABLES GENERATED LATER ON
	***********************************************************************
	foreach var of local hetero{
	capture drop _ws_`var'
	}
	foreach var of local hetero{
	capture drop _z_`var'
	}
	capture drop _wL1 _wL0 ATE_x ATET_x ATENT_x G_fv
	***********************************************************************
	* START BY ASKING IF A SPECIFIC MODEL HAS BEEN CHOSEN 
	***********************************************************************
	if "`model'"==""{
	di _newline(2)
	di as result in red "*****************************************************************"
	di as result in red "Warning: at least one of the following models has to be used:"
	di as result in red "direct-2sls, probit-2sls, probit-ols, heckit."
	di as result in red "*****************************************************************"
	}
	else{
	***********************************************************************
	* MODEL: PROBIT-OLS
	***********************************************************************
	if "`model'"=="probit-ols"{
	marksample touse
	tokenize `varlist'
    local y `1'
    local w `2'
	macro shift
	macro shift
	local xvars `*'
	***********************************************************************
	* SAMPLE PROCEDURE
	***********************************************************************
	probit `w' `iv' `xvars'  , nolog  
	tempvar G1_fv
    predict `G1_fv' , p
	foreach var of local hetero{
	capture drop _ws1_`var'
	}
	foreach var of local hetero{
	capture drop _z1_`var'
	}
	foreach var of local hetero{
	tempvar m1_`var' 
	tempvar s1_`var'
	egen `m1_`var'' = mean(`var') if `touse'
	gen  `s1_`var'' = (`var' - `m1_`var'') if `touse'
	}
	foreach var of local hetero{
	tempvar _z1_`var'
	gen `_z1_`var''=`G1_fv'*`s1_`var'' if `touse'
	local zvars1 `zvars1' `_z1_`var''
	}
	reg `y' `G1_fv' `zvars1' `xvars1' if `touse' , `vce' `beta' `const' `head' level(`conf')
	***********************************************************************
	* ACTUAL PROCEDURE
	***********************************************************************
	tempvar samplep
	gen `samplep'=1 if e(sample)
	probit `w' `iv' `xvars' if `touse' & `samplep'==1  , nolog  
	capture drop G_fv
    predict G_fv , p
	la var G_fv "Predicted probability for (w=1|x,z)"
	foreach var of local hetero{
	tempvar m_`var' 
	tempvar s_`var'
	tempvar ws_`var'
	egen `m_`var'' = mean(`var') if `touse' & `samplep'==1
	gen  `s_`var'' = (`var' - `m_`var'') if `touse' & `samplep'==1
	gen   _ws_`var'=G_fv*`s_`var'' if `touse' & `samplep'==1
	}
	foreach var of local hetero{
    local xvar2 `xvar2' _ws_`var'
	}
	foreach var of local hetero{
	gen _z_`var'=G_fv*`s_`var'' if `touse' & `samplep'==1
	local zvars `zvars' _z_`var'
	}
	reg `y' G_fv `zvars' `xvars' if `touse' & `samplep'==1 , `vce' `beta' `const' `head' level(`conf')	
	ereturn scalar ate = _b[G_fv]
	foreach var of local zvars{
	scalar d`var' = _b[`var']
	}
	tempvar k
    generate `k' = 0 if `touse' & `samplep'==1
    foreach var of local hetero{
 	replace `k' = `k' + (`s_`var'' * d_z_`var')
    }
	capture drop ATE_x
	gen ATE_x = _b[G_fv] + `k'
	tempvar wk
	gen `wk' = `w'*`k'
	qui sum `wk' if `w' == 1
	local mean_h = r(mean)
	ereturn scalar atet = _b[G_fv] + `mean_h'
	tempvar ATET_x
	capture drop ATET_x
	gen ATET_x = _b[G_fv] + `wk'  if `w'==1
	tempvar w2
	tempvar w2k
	gen `w2'=(1-`w')
	gen `w2k' = `w2'*`k' 
	qui sum `w2k' if `w'==0
	local mean_h2 = r(mean)
	ereturn scalar atent = _b[G_fv] + `mean_h2'
	tempvar ATENT_x
	capture drop ATENT_x
	gen ATENT_x =_b[G_fv] + `w2k'  if `w'==0
	*************************
	* Calculating sample size
	*************************
	qui sum ATE_x
	ereturn scalar N_tot=r(N)
	qui sum ATET_x
	ereturn scalar N_treat=r(N)
	qui sum ATENT_x
	ereturn scalar N_untreat=r(N)
	********************************
	* End of calculating sample size
	********************************
	if "`hetero'" != ""{
	if "`graphic'"=="graphic"{
	graph_1 `model'
	}
	}
	}
	else{
	*** This part is only for "cf-ols" and "direct-2sls" ***
	marksample touse
	tokenize `varlist'
    local y `1'
    local w `2'
	macro shift
	macro shift
	local xvars `*'
	foreach var of local hetero{
	tempvar m_`var' 
	tempvar s_`var' 
	tempvar ws_`var' 
	egen `m_`var'' = mean(`var')  if `touse'
	gen  `s_`var'' = (`var' - `m_`var'') if `touse'
	gen   _ws_`var'=`w'*`s_`var'' if `touse'
	}
	foreach var of local hetero{
    local xvar2 `xvar2' _ws_`var'
	}
	*** End of this part ***
    ***********************************************************************
	* MODEL: HECKIT
	***********************************************************************
	if "`model'"=="heckit"{
	if "`hetero'"==""{
	treatreg `y' `xvars' if `touse' , treat(`w' = `xvars' `iv') twostep `vce' `beta' `const' `head' level(`conf')
	}
	else{
	********************************************************************
	* Procedure to have the same sample size in the two-step regressions
	********************************************************************
	probit `w' `iv' `xvars' , nolog 
	tempvar qteta1
	predict `qteta1' , xb
	tempvar FI1
	tempvar fi1
	tempvar L11
	tempvar L01
	tempvar _wL11
	tempvar _wL01
	gen `FI1'  = normal(`qteta1') 
	gen `fi1'  = normalden(`qteta1') 
	gen `L11' = `fi1'/`FI1'
	gen `L01' = `fi1'/(1-`FI1')
	gen `_wL11' = `w'*`L11'
	gen `_wL01' = (1-`w')*`L01'
	local hec1  `_wL11' `_wL01'
	regress `y' `w' `xvars' `xvar2' `hec1' if `touse' , `vce' `beta' `const' `head' level(`conf')
	***************************************************
	* ACTUAL PROCEDURE
	***************************************************
	tempvar sample
	gen `sample'=1 if e(sample)
	foreach var of local hetero{
	capture drop _ws_`var'
	}
	foreach var of local hetero{
	tempvar m_`var' 
	tempvar s_`var' 
	tempvar ws_`var' 
	egen `m_`var'' = mean(`var')  if `touse' & `sample'==1
	gen  `s_`var'' = (`var' - `m_`var'') if `touse' & `sample'==1
	gen   _ws_`var'=`w'*`s_`var'' if `touse' & `sample'==1
	}
	foreach var of local hetero{
    local xvarh `xvarh' _ws_`var'
	}
	probit `w' `iv' `xvars' if `touse' & `sample'==1, nolog 
	tempvar qteta
	predict `qteta' , xb
	tempvar FI
	tempvar fi
	tempvar L1
	tempvar L0
	gen `FI'  = normal(`qteta') if `touse' & `sample'==1
	gen `fi'  = normalden(`qteta') if `touse' & `sample'==1
	gen `L1' = `fi'/`FI'
	gen `L0' = `fi'/(1-`FI')
	capture drop _wL1 _wL0
	gen _wL1 = `w'*`L1'
	gen _wL0 = (1-`w')*`L0'
	local hec  _wL1 _wL0
	regress `y' `w' `xvars' `xvarh' `hec' if `touse' & `sample'==1 , `vce' `beta' `const' `head' level(`conf')
	ereturn scalar ate = _b[`w']
	foreach var of local xvar2{
	scalar d`var' = _b[`var']
	}
	tempvar k
	generate `k' = 0 if `touse' & `sample'==1
	foreach var of local hetero{
	replace `k' = `k' + (`s_`var'' * d_ws_`var') 
	}
	capture drop ATE_x
	gen ATE_x = _b[`w'] + `k' 
	tempvar wk
	tempvar rholamda1
	gen `wk' = `w'*`k'
	qui sum `wk' if `w' == 1
	local mean_h = r(mean)
	gen `rholamda1' = (_b[_wL1]+_b[_wL0])*`L1' if `w' == 1
	qui sum `rholamda1' if `w' == 1
	local mean_rholamda1 = r(mean)
	ereturn scalar b_atet=r(mean)
	ereturn scalar atet = _b[`w'] + `mean_h'+ `mean_rholamda1'
	tempvar ATET_x
	capture drop ATET_x
	gen ATET_x = _b[`w'] + `wk' + `rholamda1'  if `w'==1 
	tempvar w2
	tempvar w2k
	tempvar rholamda0
	gen `w2'=(1-`w')
	gen `w2k' = `w2'*`k' 
	qui sum `w2k' if `w'==0
	local mean_h2 = r(mean)
	gen `rholamda0' = -(_b[_wL1]+_b[_wL0])*`L0' if `w'==0
	qui sum `rholamda0' if `w' == 0
	local mean_rholamda0 = r(mean)
	ereturn scalar atent = _b[`w'] + `mean_h2' + `mean_rholamda0'
	tempvar ATENT_x
	capture drop ATENT_x
	gen ATENT_x =_b[`w'] + `w2k' + `rholamda0'  if `w'==0
	*************************
	* Calculating sample size
	*************************
	qui sum ATE_x
	ereturn scalar N_tot=r(N)
	qui sum ATET_x
	ereturn scalar N_treat=r(N)
	qui sum ATENT_x
	ereturn scalar N_untreat=r(N)
	********************************
	* End of calculating sample size
	********************************
	if "`graphic'"=="graphic"{
	graph_1 `model'
	}
	}
    }
	else{
    ***********************************************************************
	* MODEL: DIRECT-2SLS
	***********************************************************************
	if "`model'"=="direct-2sls"{
	foreach var of local hetero{
	gen _z_`var'=`w'*`s_`var'' if `touse'
	la var _z_`var' "_z_`var'=instrument for w(`var'-mean(`var'))"
	local zvars `zvars' _z_`var'
	}
	ivreg  `y'  (`w' `xvar2'  =  `iv'  `zvars' ) `xvars' if `touse' , `vce' `beta' `const' `head' level(`conf')
	}
	***********************************************************************
	* MODEL: PROBIT-2SLS
	***********************************************************************
	if "`model'"=="probit-2sls"{
	***********************************************************************
	* SAMPLE PROCEDURE
	***********************************************************************
	probit `w' `iv' `xvars' if `touse'  
	tempvar G1_fv
    predict `G1_fv' , p
	*foreach var of local hetero{
	*capture drop _ws1_`var'
	*}
	*foreach var of local hetero{
	*capture drop _z1_`var'
	*}
	foreach var of local hetero{
	tempvar m1_`var' 
	tempvar s1_`var'
	tempvar _ws1_`var'
	egen `m1_`var'' = mean(`var') if `touse'
	gen  `s1_`var'' = (`var' - `m1_`var'') if `touse'
	gen  `_ws1_`var''=`G1_fv'*`s1_`var'' if `touse'
	}
	foreach var of local hetero{
    local xvar21 `xvar21' `_ws1_`var''
	}
	foreach var of local hetero{
	tempvar _z1_`var'
	gen `_z1_`var''=`G1_fv'*`s1_`var'' if `touse'
	local zvars1 `zvars1' `_z1_`var''
	}
	qui ivreg `y' (`w' `xvar21' = `G1_fv' `zvars1') `xvars1' if `touse'
	***********************************************************************
	* ACTUAL PROCEDURE
	***********************************************************************
    tempvar sample
	gen `sample'=1 if e(sample)
	foreach var of local hetero{
	capture drop _ws_`var'
	}
	foreach var of local hetero{
	tempvar m_`var' 
	tempvar s_`var' 
	tempvar ws_`var' 
	egen `m_`var'' = mean(`var')  if `touse' & `sample'==1
	gen  `s_`var'' = (`var' - `m_`var'') if `touse' & `sample'==1
	gen   _ws_`var'=`w'*`s_`var'' if `touse' & `sample'==1
	}
	foreach var of local hetero{
    local xvarh `xvarh' _ws_`var'
	}
	probit `w' `iv' `xvars' if `touse' & `sample'==1  , nolog  
	capture drop G_fv
    predict G_fv , p
    la var G_fv "Predicted probability for (w=1|x,z)"
	foreach var of local hetero{
	gen _z_`var'=G_fv*`s_`var'' if `touse' & `sample'==1
	la var _z_`var' "_z_`var'=instrument for w(`var'-mean(`var'))"
	local zvars `zvars' _z_`var' 
	}
	ivreg  `y'  (`w' `xvarh'  =  G_fv  `zvars' ) `xvars' if `touse' & `sample'==1 , `vce' `beta' `const' `head' level(`conf')
	}
	***********************************************************************
	* MODEL: CF-OLS
	***********************************************************************
	if "`model'"=="cf-ols"{
	regress `y' `w' `xvars' `xvar2' if `touse' , `vce' `beta' `const' `head' level(`conf')
	}
	ereturn scalar ate = _b[`w']
	foreach var of local xvar2{
	scalar d`var' = _b[`var']
	}
	tempvar k
    generate `k' = 0 
    foreach var of local hetero{
 	replace `k' = `k' + (`s_`var'' * d_ws_`var') 
    }
	capture drop ATE_x ATET_x ATENT_x
	gen ATE_x = _b[`w'] + `k'
	tempvar wk
	gen `wk' = `w'*`k' if `touse'
	qui sum `wk' if `w' == 1
	local mean_h = r(mean)
	ereturn scalar atet = _b[`w'] + `mean_h'
	tempvar ATET_x
	gen ATET_x = _b[`w'] + `wk'  if `w'==1
	tempvar w2
	tempvar w2k
	gen `w2'=(1-`w')
	gen `w2k' = `w2'*`k'  if `touse'
	qui sum `w2k' if `w'==0
	local mean_h2 = r(mean)
	ereturn scalar atent = _b[`w'] + `mean_h2'
	tempvar ATENT_x
	gen ATENT_x =_b[`w'] + `w2k'  if `w'==0
	*************************
	* Calculating sample size
	*************************
	qui sum ATE_x
	ereturn scalar N_tot=r(N)
	qui sum ATET_x
	ereturn scalar N_treat=r(N)
	qui sum ATENT_x
	ereturn scalar N_untreat=r(N)
	********************************
	* End of calculating sample size
	********************************
	if "`hetero'" != ""{
	if "`graphic'"=="graphic"{
	graph_1 `model'
	}
	}
	}
	}
	} 
end

***********************************************************************
* PROGRAM "graph_1" TO DRAW THE OVELAPPING DISTRIBUTIONS 
* OF ATE(x), ATET(x) and ATENT(x)
***********************************************************************

*! graph_1 v1.0.0 GCerulli 25aug2010
capture program drop graph_1
program graph_1
args model
version 11
twoway kdensity ATE_x , /// 
|| ///
kdensity ATET_x , lpattern(dash) ///
|| ///
kdensity ATENT_x , lpattern(longdash_dot) xtitle("") ///
ytitle(Kernel density) legend(order(1 "ATE(x)" 2 "ATET(x)" 3 "ATENT(x)")) ///
title("Model `model': Comparison of ATE(x) ATET(x) ATENT(x)", size(medlarge)) name()
end
