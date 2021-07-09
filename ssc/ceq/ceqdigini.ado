/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim  (2006-2008)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : digini                                                      */
/*************************************************************************/

** EDITED BY SEAN HIGGINS: 
**  07-02-2016 Replaced forval loops that looped through observations (inefficient)
**              (on the full Brazil CEQ data set with 189,000 observations, these changes
**              made the command 5x faster)
**             Formatting and remove table of results
**			   Calculate and return p-value of test of difference = 0

#delim ;

cap program drop ceqdigini2;  
program define ceqdigini2, rclass sortpreserve ;    
	version 9.2;         
	syntax varlist (min=1 max=1) 
		[, 
			HSize(varname) 
			HWeight(varname) 
			RANK(varname)  
			CI(real 5)  
			CONF(string) 
			LEVEL(real 95) 
			VAB(real 0) 
			TYPE(string)
		]
	;
		
	tokenize `varlist';
	if ("`rank'"=="") sort `1'    , stable;
	if ("`rank'"!="") sort `rank' , stable;
						 qui drop if `1'>=. ;
	if ("`hsize'"!="")   qui drop if `hsize'>=.;
	if ("`hweight'"!="") qui drop if `hweight'>=.;
	tempvar  hs sw fw ;
	qui gen `sw'=1;
	qui gen `hs'=1;
	if ("`hsize'"!="")     qui replace `hs' = `hsize';
	if ("`hweight'"!="")   qui replace `sw' = `hweight';
	gen `fw'=`hs'*`sw';
	tempvar smw smwy l1smwy ca;
	gen `smw'  =sum(`fw');
	gen `smwy' =sum(`1'*`fw');
	gen `l1smwy'=0;
	local mu=`smwy'[_N]/`smw'[_N];
	local suma=`smw'[_N];
	qui count;
	** forvalues i=2/`r(N)' { ;
	qui replace `l1smwy'=`smwy'[_n-1] if _n>1 ; // in `i';
	** };

	gen `ca'=`mu'+`1'*((1.0/`smw'[_N])*(2.0*`smw'-`fw')-1.0) - (1.0/`smw'[_N])*(2.0*`l1smwy'+`fw'*`1'); 
	qui sum `ca' [aw=`fw'], meanonly; 
	local gini=`r(mean)'/(2.0*`mu');
	if  ("`type'" == "abs") local gini=`r(mean)'/(2.0);
	local xi = `r(mean)';
	tempvar vec_a vec_b theta v1 v2 sv1 sv2;
	qui count;

			 
	local fx=0;
	gen `v1'=`fw'*`1';
	gen `v2'=`fw';
	gen `sv1'=sum(`v1');
	gen `sv2'=sum(`v2') ;
	qui replace `v1'=`sv1'[`r(N)']   in 1;
	qui replace `v2'=`sv2'[`r(N)']   in 1;

	** forvalues i=2/`r(N)'  {;
	qui replace `v1'=`sv1'[_N]-`sv1'[_n-1] if _n>1 ; // in `i';
	qui replace `v2'=`sv2'[_N]-`sv2'[_n-1] if _n>1 ; // in `i';
	** } ;
	   
	gen `theta'=`v1'-`v2'*`1';

	** forvalues i=1/`r(N)' {;
	qui replace `theta'=`theta'*(2.0/`suma') ; // in `i';
	local fx=`sv1'[_N] ; /* `sv1' is cum sum of original `v1'=`fw'*`1' */ ;
	** };            
	local fx=`fx'/`suma';
	gen `vec_a' = `hs'*((1.0)*`ca'+(`1'-`fx')+`theta'-(1.0)*(`xi'));
	qui gen `vec_b' =  2*`hs'*`1';
	if  ("`type'" == "abs") qui replace `vec_b' =  2*`hs';

	qui svy: ratio `vec_a'/`vec_b'; 
	cap drop matrix _aa;
	matrix _aa=e(b);
	local est = `gini';
	cap drop matrix _vv;
	matrix _vv=e(V);
	local std = el(_vv,1,1)^0.5;
	qui svydes;
	local fr=`r(N_units)'-`r(N_strata)';
	local lvl=(100-`level')/100;
	if ("`conf'"=="ts") local lvl=`lvl'/2; // note default is "ts" (two-sided)
	local tt=invttail(`fr',`lvl');
	return scalar est  = `est';
	return scalar std  = `std';
	return scalar lb   = `est' - `tt'*`std';
	return scalar ub   = `est' + `tt'*`std';
	return scalar df   = `fr';
	qui count; 
	return scalar nobs  = `r(N)';

	if (`vab'==1) {; // note that if the two vars come from the same data set, `vab' was set to 1 by digini;
		qui gen __va=`vec_a';
		qui gen __vb=`vec_b';
	};
	
end;     

capture program drop ceqdigini;
program define ceqdigini, eclass;
	version 9.2;
	syntax  namelist(min=2 max=2) 
		[, 
			FILE1(string) FILE2(string) 
			RANK1(string) RANK2(string)
			HSize1(string) HSize2(string)
			COND1(string)  COND2(string)  
			ITER(real 1000) /* added this to be able to adjust iterations but it makes no difference */
			TYPE(string) 
			LEVEL(real 95) CONF(string) TEST(string) DEC(int 6)
		]
	;

	global indica=3;
	tokenize `namelist';
	if ("`conf'"=="") local conf="ts";

	preserve;
	local indep = ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ); // ";
	local vab=0;
	if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) local vab=1; // ";
	if ("`file1'" !="") use `"`file1'"', replace; // ";
	tempvar cd1;
	tempvar ths1;
	qui gen `ths1'=1;

	if ( "`hsize1'"!="") qui replace `ths1'=`hsize1';

	if ( "`cond1'"!="") {;
		gen `cd1'=`cond1';
		qui replace `ths1'=`ths1'*`cd1';
		qui sum `cd1';
		if (`r(sum)'==0) {;
			dis as error " With condition(s) of distribution_1, the number of observations is 0.";
			exit;
		};
	};

	qui svyset ;
	if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

	local hweight1=""; 
	cap qui svy: total `1'; 
	local hweight1=`"`e(wvar)'"'; // ";
	cap ereturn clear; 

	ceqdigini2 `1' , 
		hweight(`hweight1') hsize(`ths1')  
		rank(`rank1') 
		conf(`conf') level(`level') type(`type') 
		vab(`vab')
	;
	if (`vab'==1) {;
		tempvar va vb;
		qui gen `va'=__va;
		qui gen `vb'=__vb;
		qui drop __va __vb;
	};
	matrix _res_d1  =(`r(est)',`r(std)',`r(lb)',`r(ub)', `r(df)');

	if ("`file2'" !="" & `vab'!=1) use `"`file2'"', replace; // ";
	tempvar cd2 ths2;
	qui gen `ths2'=1;
	if ( "`hsize2'"!="") qui replace `ths2'=`hsize2';
	if ( "`cond2'"!="") {;
		gen `cd2'=`cond2';
		qui replace `ths2'=`ths2'*`cd2';
		qui sum `cd2';
		if (`r(sum)'==0) {;
			dis as error " With condition(s) of distribution_2 the number of observations is 0.";
			exit;
		};
	};
	qui svyset ;
	if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
	local hweight2=""; 
	cap qui svy: total `2'; 
	local hweight2=`"`e(wvar)'"'; // ";
	cap ereturn clear; 

	ceqdigini2 `2' , 
		hweight(`hweight2') hsize(`ths2') rank(`rank2')  
		conf(`conf') level(`level') vab(`vab') type(`type') 
	;
	if (`vab'==1) {; // note that if the two vars come from the same data set, `vab' was set to 1 above;
		tempvar vc vd;
		qui gen `vc'=__va;
		qui gen `vd'=__vb;
		qui drop __va __vb;
	};

	matrix _res_d2 =(`r(est)',`r(std)',`r(lb)',`r(ub)', `r(df)');
	local dif = el(_res_d2,1,1)-el(_res_d1,1,1);
	local std = (el(_res_d1,1,2)^2+el(_res_d2,1,2)^2)^0.5;
	local sdif = `std';
	if (`vab'==1) {; // note that if the two vars come from the same data set, `vab' was set to 1 above;
		qui svy: mean `va' `vb' `vc' `vd';
		qui nlcom (_b[`va']/_b[`vb']-_b[`vc']/_b[`vd'] ),  iterate(`iter');
		cap drop matrix _vv;
		matrix _vv=r(V);
		local std = el(_vv,1,1)^0.5;
		local sdif = `std';
	}; 

	local est1=el(_res_d1,1,1);
	local est2=el(_res_d2,1,1);

	local std1=el(_res_d1,1,2);
	local std2=el(_res_d2,1,2);

	local df1=el(_res_d1,1,5);
	local df2=el(_res_d2,1,5);
		 

	local tyind1="GINI_Dis1";
	local tyind2="GINI_Dis2";
	if (`"`rank1'"'~="" & `"`rank1'"'~="`1'") local tyind1="CONC_Dis1"; // ";
	if (`"`rank2'"'~="" & `"`rank2'"'~="`2'") local tyind2="CONC_Dis2"; // ";

	matrix _res_di =(`dif',`sdif');
	
	/* added by Sean: calculate p-value */
	qui svydes;
	local fr=`r(N_units)'-`r(N_strata)';
	scalar _p = ttail(`fr',abs(`dif'/`sdif'));

	/*
	_dasp_dif_table `2' `2', 
	name1("`tyind1'")          name2("`tyind2'")
	m1(`est1')            m2(`est2')
	s1(`std1')            s2(`std2')
	df1(`df1')            df2(`df2')
	dif(`dif') sdif(`sdif')
	level(`level') conf(`conf') indep(`indep') test(`test');
	*/

	ereturn clear;
	ereturn matrix d1 = _res_d1;
	ereturn matrix d2 = _res_d2;
	ereturn matrix di = _res_di;
	ereturn scalar p  = _p;

	cap matrix drop _res_d1;
	cap matrix drop _res_d2;
	cap matrix drop _res_di;
	cap scalar drop _p;
	restore;
	
end;



