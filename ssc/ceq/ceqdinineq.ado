/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                      */
/* email : aabd@ecn.ulaval.ca                                            */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : dinineq                                                       */
/*************************************************************************/

** EDITED BY SEAN HIGGINS: 
**  07-03-2016 Replace inefficient while loop through observations
**			   Formatting and remove table of results
**			   Calculate and return p-value of test of difference = 0

#delim ;

/*****************************************************/
/* Density function      : fw=Hweight*Hsize          */
/*****************************************************/
cap program drop ceqdinineq_den;                    
program define ceqdinineq_den, rclass;              
	args fw x xval;                         
	qui su `x' [aw=`fw'], detail;           
	local tmp = (`r(p75)'-`r(p25)')/1.34;                          
	local tmp = (`tmp'<`r(sd)')*`tmp'+(`tmp'>=`r(sd)')*`r(sd)' ;    
	local h   = 0.9*`tmp'*_N^(-1.0/5.0);                            
	tempvar s1 s2;                                                  
	gen `s1' = sum( `fw' *exp(-0.5* ( ((`xval'-`x')/`h')^2  )  ));  
	gen `s2' = sum( `fw' );
	return scalar den = `s1'[_N]/( `h'* sqrt(2*c(pi)) * `s2'[_N] );  
end;

/***************************************/
/* Quantile  & GLorenz                 */
/***************************************/
cap program drop ceqdinineq_qua;
program define ceqdinineq_qua, rclass sortpreserve;
	args fw yyy xval order;
	preserve;
	sort `yyy', stable;
	qui cap drop if `yyy'>=. | `fw'>=.;
	tempvar ww qp glp pc;
	qui gen `ww'=sum(`fw');
	qui gen `pc'=`ww'/`ww'[_N];
	qui gen `qp' = `yyy' ;
	qui gen `glp' double = sum(`fw'*`yyy')/`ww'[_N];
	qui sum `yyy' [aw=`fw'];
	
	/* added by Sean to replace inefficient while loop through observations */	
	tempvar ordering ;
	gen `ordering' = _n;
	count if (`pc'<`xval');
	if r(N) { ; // i.e. positive number of obs with `pc'<`xval' ;
		summ `ordering' if (`pc'<`xval');
		local ar = r(max);
	} ;
	else { ;
		local ar = 0;
	};
	local i = `ar' + 1;
	
	if (`i'> 1) {;
		local qnt =`qp'[`ar'] +((`qp'[`i'] -`qp'[`ar']) /(`pc'[`i']-`pc'[`ar']))*(`pc'[`i']-`pc'[`ar']);
		local glor=`glp'[`ar']+((`glp'[`i']-`glp'[`ar'])/(`pc'[`i']-`pc'[`ar']))*(`pc'[`i']-`pc'[`ar']);
	};
	if (`i'==1) {;
		local qnt =(max(0,`qp'[`i'])/(`pc'[`i']))*(`pc'[`i']);
		local glor=(max(0,`glp'[`i'])/(`pc'[`i']))*(`pc'[`i']);
	};

	return scalar qnt  = `qnt';
	return scalar glor = `glor';
	restore;
end;

/*********************************/
/* Main programs                 */
/*********************************/
cap program drop ceqdinineq2;  
program define ceqdinineq2, rclass ;    
	version 9.2;         
	syntax varlist (min=1 max=1) 
		[, 
			HSize(varname) 
			HWeight(varname) 
			HGroup(varname) 
			p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9) 
			index(string)  
			GNumber(int -1) 
			CI(real 5)  CONF(string) LEVEL(real 95) vab(int 0)
		];

	tokenize `varlist';
						qui drop if `1'>=. ;
	if ("`hsize'"!="")   qui drop if `hsize'>=.;
	if ("`hweight'"!="") qui drop if `hweight'>=.;
	tempvar  hs sw fw ;
	gen `sw'=1;
	gen `hs'=1;

	if ("`hsize'"!="")     qui replace `hs' = `hsize';
	tempvar _in;
	if ("`hgroup'" != "")  qui gen    `_in' = (`hgroup' == `gnumber');
	if ("`hgroup'" != "")  qui replace `hs' = `hs' * `_in';
	if ("`hweight'"!="")   qui replace `sw'=`hweight';


	local hweight=""; 
	cap qui svy: total `1'; 
	local hweight=`"`e(wvar)'"'; // " ;
	cap ereturn clear; 
	tempvar fw;
	gen `fw'=`hs';
	if (`"`hweight'"'~="") qui replace `fw'=`fw'*`hweight'; // " ;

	tempvar vec_a vec_b;

	if ( "`index'"=="qr") {;
		ceqdinineq_qua `fw' `1' `p1';
		local q1=`r(qnt)';
		ceqdinineq_qua `fw' `1' `p2';
		local q2=`r(qnt)';
		local est = `q1'/`q2';
		ceqdinineq_den `fw' `1' `q1';
		local fq1=`r(den)';
		ceqdinineq_den `fw' `1' `q2';
		local fq2=`r(den)';
		gen `vec_a' = -`hs'*((`q1'>`1')-`p1')/`fq1' + `hs'*`q1';
		gen `vec_b' = -`hs'*((`q2'>`1')-`p2')/`fq2' + `hs'*`q2';
		qui svy: ratio `vec_a'/`vec_b';
		cap drop matrix _vv;
		matrix _vv=e(V);
		local std = el(_vv,1,1)^0.5;
		global ws1=`q1';
		global ws2=`q2';
	};

	if ( "`index'"=="sr") {;
		ceqdinineq_qua `fw' `1' `p1';
		local q1=`r(qnt)'; local g1=`r(glor)';
		ceqdinineq_qua `fw' `1' `p2';
		local q2=`r(qnt)'; local g2=`r(glor)';
		ceqdinineq_qua `fw' `1' `p3';
		local q3=`r(qnt)'; local g3=`r(glor)';
		ceqdinineq_qua `fw' `1' `p4';
		local q4=`r(qnt)'; local g4=`r(glor)';

		local est = (`g2'-`g1')/(`g4'-`g3');
		global ws1=(`g2'-`g1');
		global ws2=(`g4'-`g3');

		gen `vec_a' = `hs'*(`q2'*`p2'+(`1'-`q2')*(`q2'>`1')) - `hs'*(`q1'*`p1'+(`1'-`q1')*(`q1'>`1')) ;
		gen `vec_b' = `hs'*(`q4'*`p4'+(`1'-`q4')*(`q4'>`1')) - `hs'*(`q3'*`p3'+(`1'-`q3')*(`q3'>`1')) ;;
		qui svy: ratio `vec_a'/`vec_b';
		cap drop matrix _vv;
		matrix _vv=e(V);
		local std = el(_vv,1,1)^0.5;
		
	};

	if (`vab'==1) {; // note that if the two vars come from the same data set, `vab' was set to 1 by ceqdinineq;
		gen __va=`vec_a';
		gen __vb=`vec_b';
	};
	
	qui svydes;
	local fr=`r(N_units)'-`r(N_strata)';
	local lvl=(100-`level')/100;
	if ("`conf'"=="ts") local lvl=`lvl'/2;
	local tt=invttail(`fr',`lvl');

	return scalar est  = `est';
	return scalar std  = `std';
	return scalar lb   = `est' - `tt'*`std';
	return scalar ub   = `est' + `tt'*`std';
	return scalar df   = `fr';

end;     

capture program drop ceqdinineq;
program define ceqdinineq, eclass;
	version 9.2;
	syntax  namelist(min=2 max=2) 
		[, 
			FILE1(string) FILE2(string) 
			p1(real 0.1) p2(real 0.2) p3(real 0.8) p4(real 0.9) 
			index(string)
			HSize1(string) HSize2(string)
			COND1(string)  COND2(string)  
			type(string)  
			LEVEL(real 95) CONF(string) TEST(string) DEC(int 6)
		];

	global indica=3;
	tokenize `namelist';
	if ("`conf'"=="")          local conf="ts";
	if ("`index'"=="") local index = "qr";
	preserve;
	local indep = ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ); // " ;
	local vab=0;
	if ( (`"`file1'"'=="" & `"`file2'"'=="") | (`"`file1'"'==`"`file2'"')  ) local vab=1;  // " ;
	if ("`file1'" !="") use `"`file1'"', replace;  // " ;
	tempvar cd1; 
	tempvar ths1;
	qui gen `ths1'=1;

	if ( "`hsize1'"!="") qui replace `ths1'=`hsize1';

	if ( "`cond1'"!="") {;
		gen `cd1'=`cond1';
		qui replace `ths1'=`ths1'*`cd1';
		qui sum `cd1';
		if (`r(sum)'==0) {;
			dis as error " With the condition(s) of distribution_1, the number of observations is 0.";
			exit;
		};
	};

	qui svyset ;
	if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);

	local hweight1=""; 
	cap qui svy: total `1'; 
	local hweight1=`"`e(wvar)'"';  // " ;
	cap ereturn clear; 

	ceqdinineq2 `1' , 
		hweight(`hweight1') hsize(`ths1')  
		p1(`p1') p2(`p2') p3(`p3') p4(`p4') 
		index(`index') 
		conf(`conf') level(`level') 
		vab(`vab')
	;
	matrix _res_d1  =(`r(est)',`r(std)',`r(lb)',`r(ub)', `r(df)') ;
	
	if (`vab'==1) {; // note that if the two vars come from the same data set, `vab' was set to 1 above;
		tempvar va vb;
		qui gen `va'=__va;
		qui gen `vb'=__vb;
		qui drop __va __vb;
		local sv1=$ws1;
		local sv2=$ws2;
	};

	if ("`file2'" !="" & `vab'!=1) use `"`file2'"', replace; // " ;
	tempvar cd2 ths2;
	qui gen `ths2'=1;
	if ( "`hsize2'"!="") qui replace `ths2'=`hsize2';
	if ( "`cond2'"!="") {;
		gen `cd2'=`cond2';
		qui replace `ths2'=`ths2'*`cd2';
		qui sum `cd2';
		if (`r(sum)'==0) {;
			dis as error " With the condition(s) of distribution_2 the number of observations is 0.";
			exit;
		};
	};
	
	qui svyset ;
	if ( "`r(settings)'"==", clear") qui svyset _n, vce(linearized);
	local hweight2=""; 
	cap qui svy: total `2'; 
	local hweight2=`"`e(wvar)'"'; // " ;
	cap ereturn clear; 

	ceqdinineq2 `2' , 
		hweight(`hweight2') hsize(`ths2') 
		p1(`p1') p2(`p2') p3(`p3') p4(`p4') 
		index(`index')  
		conf(`conf') level(`level') 
		vab(`vab') 
	;
	if (`vab'==1) {;
		tempvar vc vd;
		qui gen `vc'=__va;
		qui gen `vd'=__vb;
		qui drop __va __vb;
		local sv3=$ws1;
		local sv4=$ws2;
	};

	matrix _res_d2 =(`r(est)',`r(std)',`r(lb)',`r(ub)', `r(df)');
	local dif = el(_res_d2,1,1)-el(_res_d1,1,1);
	local std = (el(_res_d1,1,2)^2+el(_res_d2,1,2)^2)^0.5;

	if (`vab'==1) {;
		qui svy: mean `va' `vb' `vc' `vd';
		cap drop matrix mat;
		matrix mat=e(V);
		cap drop matrix gra;
		matrix gra=
			(
				1/`sv2'			\
				-`sv1'/`sv2'^2	\
				-1/`sv4'		\
				`sv3'/`sv4'^2
			);
		cap matrix drop _zz;
		matrix _zz=gra'*mat*gra;
		local std= el(_zz,1,1)^0.5; 
	}; 

	local sdif = `std';
	
	local ind = "Quantile ratio";
	
	local lr = "p1 = `p1'";
	local hr = "p2 = `p2'";
	
	if ("`index'"=="sr") {;
		local ind = "Share ratio";
		local lr = "p1 = `p1' / p2 = `p2'";
		local hr = "p3 = `p3' / p4 = `p4'";
	};
	
	/*
      tempname table;
	.`table'  = ._tab.new, col(5);
	.`table'.width  24|16 16 16 16 ;
	.`table'.strcolor . . yellow . . ;
	.`table'.numcolor yellow yellow . yellow yellow;
	.`table'.numfmt %16.0g  %16.`dec'f  %16.`dec'f %16.`dec'f %16.`dec'f ;
       di _n as text in white "{col 5}Difference: `ind' index of inequality";
       di as text     "{col 5}Lower  rank      :  `lr'";
       di as text     "{col 5}Higher rank      :  `hr'";
	*/
        
	local sdif = `std';
	
	if ("`conf'"!="ts") local lvl=(100-`level')/100;
	if ("`conf'"=="ts") local lvl = (1-(100-`level')/200);
	local zzz=invnorm(`lvl');
	local lb   = `dif' -  `zzz'*`std';
	local ub   = `dif' +  `zzz'*`std';
	matrix _res_di =(`dif',`std',`lb',`ub');
	
	/* added by Sean: calculate p-value */
	qui svydes;
	local fr=`r(N_units)'-`r(N_strata)';
	scalar _p = ttail(`fr',abs(`dif'/`sdif'));

	local est1=el(_res_d1,1,1);
	local est2=el(_res_d2,1,1);
	
	local std1=el(_res_d1,1,2);
	local std2=el(_res_d2,1,2);
	
	local df1=el(_res_d1,1,5);
	local df2=el(_res_d2,1,5);
     
	local tyind1="Dist1";
	local tyind2="Dist2";
	
	/*
	_dasp_dif_table `2' `2', 
	name1("`tyind1'")          name2("`tyind2'")
	m1(`est1')            m2(`est2')
	s1(`std1')            s2(`std2')
	df1(`df1')            df2(`df2')
	dif(`dif') sdif(`sdif')
	level(`level') conf(`conf') indep(`indep') test(`test');
	*/

	restore;
	ereturn clear;
	ereturn matrix d1 = _res_d1;
	ereturn matrix d2 = _res_d2;
	ereturn matrix di = _res_di;
	ereturn scalar p  = _p;
	
	cap matrix drop _res_d1;
	cap matrix drop _res_d2;
	cap matrix drop _res_di;
	cap scalar drop _p;

end;



