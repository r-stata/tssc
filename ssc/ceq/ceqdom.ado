* ADO FILE FOR DOMINANCE SHEET OF CEQ OUTPUT TABLES

* VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.4 01jun2017 For use with July 2017 version of Output Tables
** v1.3 29OCT2016 For use with Jul 2016 version of Output Tables
** (beta version; please report any bugs), written by Rodrigo Aranda raranda@tulane.edu

* CHANGES
** 06-01-2017 Add additional options to print meta-information
* v1.1 added Version 13.0 for putexcel and fixed reps option bug
* v1.2 Fixed bootstrapp test for no crossings
* v1.3 Add set type double and data format check
*      Change bootstrap ksmirnov to ksmorniv 


* NOTES
* Uses uses domineq command from DASP to see number of intersections between concentration/lorenz curves, if 
*there are no intersections, then a Ksmirnov test for equality of distributions is done to test whether there 
*is stochastic dominance, the Ksmirnov test is bootstrapped because we cannot include svy options for the 
*estimation of this test
*uses glcurve command

* TO DO

************************
* PRELIMINARY PROGRAMS *
************************

#delimit cr

#delimit cr
// BEGIN returncol (Higgins 2015) 
//  Returns Excel column corresponding to a number
cap program drop returncol
program define returncol, rclass
	confirm integer number `1'
	mata: st_strscalar("col",numtobase26(`1'))
	return local col = col
end // END returncol


* Program to compute first-order stochastic dominance under CEQ Methodology 
*Estimates:
*First uses domineq command from DASP to see number of intersections between concentration/lorenz curves, if there are no intersections, then 
*a Ksmirnov test for equality of distributions is done to test whether there is stochastic dominance, the Ksmirnov test is bootstrapped because we
*cannot include svy options for the estimation of this test;



*v1.0 11/22/2015 Rodrigo Aranda, raranda@tulane.edu

*I include the code for domineq to have a return scalar for the number of crossings;
/*************************************************************************/
/* DASP  : Distributive Analysis Stata Package  (version 2.3)            */
/*************************************************************************/
/* Conceived and programmed by Dr. Araar Abdelkrim   (2006-2012)          */
/* Universite Laval, Quebec, Canada                                       */
/* email : aabd@ecn.ulaval.ca                                            */
/* Web   : www.dasp.ecn.ulaval.ca                                        */
/* Phone : 1 418 656 7507                                                */
/*************************************************************************/
/* module  : domineq                                                     */
/*************************************************************************/


set more off
capture program drop domineq
program define domineq, rclass
version 9.2
#delimit ;
syntax namelist(min=2 max=2) 
[, 
FILE1(string)   
HSize1(string) 
RANK1(string)
COND1(string)

FILE2(string) 
HSize2(string) 
RANK2(string)
COND2(string) 

TYPE(string)
zmin(string) 
zmax(string)
step(string)  
DEC(int 3)
];

qui{;
tokenize `namelist';


local bool1=((`"`file1'"'=="") & (`"`file2'"'==""));
local bool2=(`"`file1'"'!=`"`file2'"');

preserve;
if (`"`file1'"'!="") use `"`file1'"', replace;
cap qui svy: total;
local srt ="`r(settings)'";

local wname1="";
if ( "`srt'"==", clear")   qui svyset _n, vce(linearized);
if ( "`srt'"~=", clear") {;
qui svy: total `1';
qui estat svyset;
local wname1=`"`e(wvar)'"';
};

tempvar y1 w1;
cap drop `w1';
cap drop `y1';
qui gen  `y1'=`1';
if ( "`wname1'" == "" )    qui gen `w1' = 1;
if ( "`wname1'" ~= "" )    qui gen `w1' =`wname1';
if ("`hsize1'" ~= "")      qui replace `w1' =  `w1'*`hsize1';
qui gen _cd1=1;
if ("`cond1'" ~= "")     qui replace _cd1=`cond1';
if ("`cond1'" ~= "")     qui replace `w1' =  `w1'*_cd1;


keep `rank1' `y1' `w1';


if ("`rank1'"=="") sort `y1' , stable;
if ("`rank1'"~="") sort `rank1' `y1', stable;




if ("`type'"=="abs") {;
qui sum `y1' [aw=`w1'];
qui replace `y1' = `y1' - `r(mean)';
};

qui gen _p=0;
qui gen      _sw1  = sum(`w1');
qui gen      _lp1  = sum(`w1'*`y1');
if ("`type'"!="gen") qui replace  _lp1  = sum(`w1'*`y1')/_lp1[_N];
if ("`type'"=="gen" | "`type'"=="abs") qui replace  _lp1  = sum(`w1'*`y1')/_sw1[_N];

qui replace  _p    =_sw1/_sw1[_N];
keep _lp1 _p;
tempfile mas1;
qui save `mas1', replace;
restore;

preserve;
if (`"`file2'"'!="") use `"`file2'"', replace;
cap qui svy: total `2';
local wname2="";
if ( "`srt'"==", clear")   qui svyset _n, vce(linearized);
if ( "`srt'"~=", clear") {;
qui svy: total `2';
qui estat svyset;
local wname2=`"`e(wvar)'"';
};

qui tempvar y2 w2;
cap drop `w2';
cap drop `y2';
qui gen `y2'=`2';
if ( "`wname2'" == "" )    qui gen `w2' = 1;
if ( "`wname2'" ~= "" )    qui gen `w2' =`wname2';
if ("`hsize2'" ~= "")      qui replace `w2' =  `w2'*`hsize2';
qui gen _cd2=1;
if ("`cond2'" ~= "")     qui replace _cd2=`cond2';
if ("`cond2'" ~= "")     qui replace `w2' =  `w2'*_cd2;


keep `rank2' `y2' `w2';


if ("`rank2'"=="") sort `y2' , stable;
if ("`rank2'"~="") sort `rank2' `y2' , stable;



if ("`type'"=="abs") {;
qui sum `y2' [aw=`w2'];
qui replace `y2' = `y2' - `r(mean)';
};

qui gen _p=0;
qui gen      _sw2  = sum(`w2');
qui gen      _lp2  = sum(`w2'*`y2');
if ("`type'"!="gen") qui replace  _lp2  = sum(`w2'*`y2')/_lp2[_N];
if ("`type'"=="gen" | "`type'"=="abs") qui replace  _lp2  = sum(`w2'*`y2')/_sw2[_N];

qui replace  _p    =_sw2/_sw2[_N];
keep _lp2 _p;
tempfile mas2;
keep _lp2 _p ;
qui save `mas2', replace;



qui append using `mas1';
qui sort _p, stable;

collapse (sum) _lp1 _lp2, by(_p);

qui count;
local obs1=`r(N)'+1;
qui set obs `obs1';
qui gen double _fp=0;
qui count;
local chk = `r(N)' - 1;
forvalues i=2/`r(N)' {;
qui replace _fp = _p[`i'-1] in `i';
};

keep _fp;


merge using `mas1';
qui gen _flp1=0;
qui count; 
local i = 1;
local aa=`r(N)'-1;
forvalues j=0/`aa' {;
local pcf=_fp[`j'+1];
local av=`j'+1;

while (`pcf' > _p[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lpi=_lp1[`ar']+((_lp1[`i']-_lp1[`ar'])/(_p[`i']-_p[`ar']))*(`pcf'-_p[`ar']);
if (`i'==1) local lpi=0+((_lp1[`i'])/(_p[`i']))*(`pcf');
qui replace _flp1= `lpi' in `av';

};

cap drop _p _lp1;
drop _merge;
merge using `mas2';
qui gen _flp2=0;
qui count; 
local i = 1;
local aa=`r(N)'-1;



forvalues j=0/`aa' {;
local pcf=_fp[`j'+1];
local av=`j'+1;

while (`pcf' > _p[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lpi=_lp2[`ar']+((_lp2[`i']-_lp2[`ar'])/(_p[`i']-_p[`ar']))*(`pcf'-_p[`ar']);
if (`i'==1) local lpi=0+((_lp2[`i'])/(_p[`i']))*(`pcf');
qui replace _flp2= `lpi' in `av';
};




/* list _*; */
qui gen double dif = _flp2-_flp1;



qui count;
local chk=`r(N)'-1;
qui gen _num=0;
qui gen _irange_perc=0;
qui gen _arange_perc=0;
qui gen _perc=0;
qui gen _case="";local bnodif=1;
local ninter=0;


local   ran=0;
local   eran=0;
local   strr1=0;

forvalues i=2/`chk' {;

if (dif[`i']>0)  local _case="A";
if (dif[`i']<0)  local _case="B";
local bnodif =`bnodif'*(dif[`i']==0);
if (`bnodif'==1)  local _case="C";

if ((dif[`i']>0 & dif[`i'+1]<0) | (dif[`i']<0 & dif[`i'+1]>0)) {;

if (dif[`i']>0)  local _case="A";
if (dif[`i']<0)  local _case="B";

local b=(dif[`i'+1]-dif[`i'])/(_fp[`i'+1]-_fp[`i']);
local p_et=_fp[`i']-(dif[`i']/`b');


if ( `p_et' < .99999999){;
local ninter=`ninter'+1;
qui replace _num  =    `ninter'      in `ninter' ;
qui replace _perc =    `p_et'        in `ninter' ;
qui replace _case =    "`_case'"     in `ninter' ;
qui replace _irange_perc  =  .   in `ninter' ;
qui replace _arange_perc  =  .   in `ninter' ;
};
};


if ( dif[`i'-1]!=0 & dif[`i'+1]!=0 & dif[`i']==0 ) {;
if (dif[`i'-1]>0)  local _case="A";
if (dif[`i'+1]<0)  local _case="B";
local p_et=_fp[`i'];
if ( `p_et' < .99999999){;
local ninter=`ninter'+1;
qui replace _num  =    `ninter'    in `ninter' ;
qui replace _perc =    `p_et'      in `ninter' ;
qui replace _case =    "`_case'"    in `ninter' ;
qui replace _irange_perc  =  .   in `ninter' ;
qui replace _arange_perc  =  .   in `ninter' ;
};
};



 
if (dif[`i']==0) {;


if (dif[`i'-1]!=0 & dif[`i']==0 ) {;
local strr1=round(_fp[`i']*1000000)/1000000;
if (dif[`i'-1]>0)  local _case="A";
if (dif[`i'-1]<0)  local _case="B";
};


if (dif[`i'-1]==0 ) local ran = 1;
if (dif[`i'-1]==0 & dif[`i'+1]!=0 ) {;
local eran=1;
local strr2=_fp[`i'];
local strr="`strr1' - `strr2'";
};


local p_et=_fp[`i'];

if (`ran'==1 & `eran'==1 ) {;
local ninter=`ninter'+1;
qui replace _num         =  `ninter'   in `ninter' ;
qui replace _irange_perc  =  `strr1'   in `ninter' ;
qui replace _arange_perc  =  `strr2'   in `ninter' ;
qui replace _perc =.                   in `ninter' ;
qui replace _case        =  "`_case'"  in `ninter' ;
local nonint=0;
local eran=0;
local ran=0;
};

};

};



if (`bnodif' == 0 & `ninter'>=1) {;
tempname table;
	.`table'  = ._tab.new, col(5)  separator(0) lmargin(0);
	.`table'.width  16 16 16 16 16 ;
	.`table'.strcolor . . yellow . .;
	.`table'.numcolor yellow yellow . yellow  yellow ;
	.`table'.numfmt %16.0g  %16.`dec'f %16.`dec'f %16.`dec'f   %16s;

       
      .`table'.sep, top;
      .`table'.titles "Number of   " "Critical  "  "Min. range of" "Max. range of"	"Case";
	.`table'.titles "intersection" "percentile"  "percentiles  " "percentiles  "	"    ";
	
	.`table'.sep, mid;
	local nalt = "ddd";
	forvalues i=1/`ninter'{;
           		.`table'.row `i' _perc[`i'] _irange_perc[`i'] _arange_perc[`i'] _case[`i']; 
	};
   .`table'.sep,bot;
*disp in white " Notes :    ";
*disp in white " _case A: Curve_1 is below Curve_2 before the intersection.";
*disp in white " _case B: Curve_1 is above  Curve_2 before the intersection.";  
*disp in white " _case C: # of intersections before.";  
 
};



*if (`ninter'==0) {;
*disp in green _newline "{hline 70}";
*disp in white                          "Notes : No intersection found. ";
*     if ("`_case'"=="A") disp in white "        Curve_1 is below Curve_2.";
*else if ("`_case'"=="B") disp in white "        Curve_1 is above  Curve_2.";  
*else if ("`_case'"=="C") disp in white "        Identical curves.";  
*disp in green "{hline 70}" ; 

*};
return scalar inters=`ninter';
};
end;


#delimit;
cap program drop ceqdom ;

program define ceqdom, rclass sortpreserve;//General program for dominance;
 version 13.0;
	syntax [using/]  [if] [in] [pweight/] [, 
			/* INCOME CONCEPTS: */
			Market(varname)
			Mpluspensions(varname)
			Netmarket(varname) 
			Gross(varname)
			Taxable(varname)
			Disposable(varname) 
			Consumable(varname)
			Final(varname)
			OPEN
			/* SURVEY INFORMATION */
			HHid(varname)
			HSize(varname) 
			PSU(varname) 
			Strata(varname)
			/*Domineq options*/
			reps(string)
			/* INFORMATION CELLS */
			COUNtry(string)
			SURVeyyear(string) /* string because could be range of years */
			AUTHors(string)
			SCENario(string)
			GROUp(string)
			PROJect(string) 
			*
		];
	
	


*****General Options;
* general programming locals;
	local dit display as text in smcl;
	local die display as error in smcl;
	local command ceqdom;
	local version 1.4;
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to raranda@tulane.edu)";
	qui{;
	* weight (if they specified hhsize*hhweight type of thing);
	if strpos("`exp'","*")> 0 { ;
		noisily `die' "Please use the household weight in {weight}, this will automatically be multiplied by the size of household given by {bf:hsize}";
		exit;
	};
	
	* hsize and hhid;
	if wordcount("`hsize' `hhid'")!=1 {;
		noisily `die' "Must exclusively specify {bf:hsize} (number of household members for household-level data) or ";
		noisily `die' "{bf:hhid} (unique household identifier for individual-level data)";
		exit 198;
	};
	
	** Check if all income and fisc variables are in double format;
	local inctypewarn;
	foreach var of local varlist {;
		if "`var'"!="" {;
			local vartype: type `var';
			if "`vartype'"!="double" {;
				if wordcount("`inctypewarn'")>0 local inctypewarn `inctypewarn', `var';
				else local inctypewarn `var';
			};
		};
	};
	if wordcount("`inctypewarn'")>0 `dit' "Warning: Income variable(s) `inctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error.";
	if wordcount("`inctypewarn'")>0 local warning `warning' "Warning: Income variable(s) `inctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error.";
	
	* make sure using is xls or xlsx;
	ceq_parse_using using `"`using'"', cmd("ceqdom") open("open");
	
	
	* make sure -domineq- is installed;
	cap which domineq;
	if _rc {;
		noisily `die' `"Warning: {bf:domineq} not installed, Dominance results not produced"';
		noisily `die' `"To install: {Install from DASP, from(http://dasp.ecn.ulaval.ca/)"}"';
		exit 198;
	};
	* make sure -glcurve- is installed;
	cap which glcurve;
	if _rc {;
		noisily `die' "Warning: {bf:glcurve} not installed, Dominance results not produced";
		noisily `die' "to install: {stata ssc install glcurve:ssc install glcurve}";
		exit 198;
	};
	
	***********************
	* PRESERVE AND MODIFY *
	***********************;
	preserve;
	if wordcount("`if' `in'")!=0 quietly keep `if' `in';
	
	** make sure all newly generated variables are in double format;
	set type double;
	
	* collapse to hh-level data;
	if "`hsize'"=="" { ;// i.e., it is individual-level data;
		qui tempvar members;
		sort `hhid';
		qui bys `hhid': gen `members' = _N; // # members in hh ;
		qui bys `hhid': drop if _n>1; // faster than duplicates drop;
		local hsize `members';
	};
		* temporary variables;
	qui tempvar one;
	qui gen `one' = 1;
	**********************
	* SVYSET AND WEIGHTS *
	**********************;
	cap svydes;
	scalar no_svydes = _rc;
	if !_rc qui svyset ;// gets the results saved in return list;
	if "`r(wvar)'"=="" & "`exp'"=="" {;
		noisily `dit' "Warning: weights not specified in svydes or the command";
		noisily `dit' "Hence, equal weights (simple random sample) assumed";
	};
	else {;
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)';
		if "`exp'"!="" local w `exp';
		if "`w'"!="" {;
			qui tempvar weightvar;
			qui gen double `weightvar' = `w'*`hsize';
			local w `weightvar';
		};
		else local w "`hsize'";
		
		if "`w'"!="" {;
			local pw "[pw = `w']";
			local aw "[aw = `w']";
		};
		if "`exp'"=="" & "`r(wvar)'"!="" {;
			local weight "pw";
			local exp "`r(wvar)'";
		};
	};
	else if "`r(su1)'"=="" & "`psu'"=="" {;
		di as text "Warning: primary sampling unit not specified in svydes or the d1 command's psu() option";
		di as text "P-values will be incorrect if sample was stratified";
	};
	if "`psu'"=="" & "`r(su1)'"!="" {;
		local psu `r(su1)';
	};
	if "`strata'"=="" & "`r(strata1)'"!="" {;
		local strata `r(strata1)';
	};
	if "`strata'"!="" {;
		local opt strata(`strata');
	};
	* now set it:;
	if "`exp'"!="" qui svyset `psu' `pw', `opt';
	else           qui svyset `psu', `opt';

	

	
	
	**********
	* LOCALS *
	**********;
	
	* income concepts;
	local m `market';
	local mp `mpluspensions';
	local n `netmarket';
	local g `gross';
	local t `taxable';
	local d `disposable';
	local c `consumable';
	local f `final';
	local alllist m mp n g t d c f;
	
	local incomes = wordcount("`alllist'");
	local origlist m mp n g d;
	tokenize `alllist'; // so `1' contains m; to get the variable you have to do ``1'';
	local varlist "";
	local varlist2 "";
	local counter = 1;
	foreach y of local alllist {;
		local varlist `varlist' ``y''; // so varlist has the variable names;
		local varlist2 `varlist' ``y'2';
		// reverse tokenize:;
		local _`y' = `counter'; // so _m = 1, _mp = 2 (regardless of whether these options included);
		if "``y''"!="" local `y'__ `y' ;// so `m__' is e.g. m if market() was specified, "" otherwise;
		local ++counter;
	};

	local d_m      = "Market Income";
	local d_mp     = "Market Income + Pensions";
	local d_n      = "Net Market Income";
	local d_g      = "Gross Income";
	local d_t      = "Taxable Income";
	local d_d      = "Disposable Income";
	local d_c      = "Consumable Income";
	local d_f      = "Final Income";
	foreach y of local alllist {;
		if "``y''"!="" {;
			scalar _d_``y'' = "`d_`y''";
		};
	};
	
	* negative incomes;
	*set trace on
	foreach v of local alllist {;
		if "``v''"!="" {;
			qui count if ``v''<0; 
			if r(N) noisily `dit' "Warning: `r(N)' negative values of ``v''";
		};
	};	
	*set trace off
			*******General Options*********;
	if `"`weight'"' != "" {;
		local wgt `"[`weight'`exp']"';
    };
	
	if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)';
	if "`exp'"!="" local w `exp';
	if "`w'"!="" {;
		tempvar weightvar;
		qui gen `weightvar' = `w'*`hsize';
		local w `weightvar';
	};
	else local w "`hsize'";
		if "`w'"!="" {;
		local pw "[pw = `w']";
		local aw "[aw = `w']";
	};
	
	
	*Income matrices;
	matrix inc_cross = J(8,8,.);
	matrix inc_p = J(8,8,.);

	foreach y of local 	alllist{;//generate matrices for results;
		matrix `y'_cross = J(8,8,.);
		matrix `y'_p = J(8,8,.);
	};
	
	*****REPS*****;
	if "`reps'"==""{;
	local reps=10;
	};
	
	*Temporary dataset from which to run results;
	qui tempfile orig;
	qui save `orig',replace;
	
	*****Lorenz curves;
	local a=0;
	foreach y of local 	alllist{;
	local a=`a'+1;
	local b=0;
		if "``y''"!=""{;
		foreach z of local alllist{;
			if `_`y''>`_`z''{;
			local b=`b'+1;
			if "``z''"!=""{;
			qui domineq ``y'' ``z'', rank1(``y'') rank2(``z'');
			matrix inc_cross[`_`y'',`_`z''] = r(inters);
			
			if r(inters)==0{;
				*if (`_`y''>= `_`z'' & `_`y''<=5) | (`_`y''< `_`z'' & `_`y''>5){;
				qui tempvar x1 y1 x2 y2 num ;
		
				qui glcurve ``y'' `aw', sortvar(``y'') lorenz pvar(`x1') glvar(`y1')  replace nograph;
				qui gen `num'=1;//identifier;
				keep `x1' `y1' `num';
				qui tempfile temp1;
				qui save "`temp1'",replace;
				use "`orig'",clear;
				qui glcurve ``z'' `aw', sortvar(``z'') lorenz pvar(`x1') glvar(`y1')  replace nograph;

				qui gen `num'=2;//identifier;
				qui keep `x1' `y1' `num';
				qui append using "`temp1'";
				qui ksmirnov `y1',by(`num');
				/* bootstrap  r(p_cor),reps(`reps') seed(12345):  ksmirnov `y1',by(`num'); */
				/* matrix res=r(table); 
				local pval=res[4,1]; */ 
				matrix inc_p[`_`y'',`_`z''] = `r(p)';
				use "`orig'",clear;
			*};
			};
			};
		} ;
		};
		};
	
	
	};
	*****Concentration curves;
	local a=0;
	
	foreach w of local alllist{;//Ranking income;
	foreach y of local 	alllist{;
	local a=`a'+1;
	local b=0;
	if "``y''"!=""{;
		foreach z of local alllist{;
		if `_`y''>`_`z''{;
			local b=`b'+1;
			if "``z''"!=""{;
			qui domineq ``y'' ``z'', rank1(``w'') rank2(``w'');
			matrix `w'_cross[`_`y'',`_`z''] = r(inters);
			
			if r(inters)==0{;
				*if (`_`y''>= `_`z'' & `_`y''<=5) | (`_`y''< `_`z'' & `_`y''>5){;

				qui tempvar x1 y1 x2 y2 num ;
		
				qui glcurve ``y'' `aw', sortvar(``w'') lorenz pvar(`x1') glvar(`y1')  replace nograph;
				qui gen `num'=1;//identifier;
				keep `x1' `y1' `num';
				qui tempfile temp1;
				qui save "`temp1'",replace;
				use "`orig'", clear;
				qui glcurve ``z'' `aw', sortvar(``w'') lorenz pvar(`x1') glvar(`y1')  replace nograph;

				qui gen `num'=2;//identifier;
				keep `x1' `y1' `num';
				qui append using "`temp1'";
				/* bootstrap  r(p_cor),reps(`reps') seed(12345):  ksmirnov `y1',by(`num');
				matrix res=r(table);
				local pval=res[4,1]; */
				qui ksmirnov `y1',by(`num');
				matrix `w'_p[`_`y'',`_`z''] = `r(p)';
				use "`orig'",clear;
				};
			*};
			};
		};
		};
		};
	
	};
	*noisily matrix list `w'_cross;
	*noisily matrix list `w'_p;
	};
	
	
	****************
	* SAVE RESULTS *
	****************;
	if `"`using'"'!="" {;
		`dit' `"Writing to "`using'", may take several minutes"';
		
	local sheet=`"E8. Dominance Tests"';	
	*Rows for concentration curves results;
	
	local r_m=23;
	local r_mp=36;
	local r_n=49;
	local r_g=62;
	local r_t=75;
	local r_d=88;
	local r_c=101;
	local r_f=114;

	putexcel C9=matrix(inc_cross) using `"`using'"',keepcellformat modify sheet("`sheet'") ;
	putexcel M9=matrix(inc_p) using `"`using'"',keepcellformat modify sheet("`sheet'") ;
	
	foreach y of local 	alllist{;
		putexcel C`r_`y''=matrix(`y'_cross) using `"`using'"',keepcellformat modify sheet("`sheet'") ;
		putexcel M`r_`y''=matrix(`y'_p) using `"`using'"',keepcellformat modify sheet("`sheet'") ;
	};
	local date `c(current_date)';		
		local titlesprint;
		local titlerow = 3;
		local titlecol = 1;
		local titlelist country surveyyear authors date scenario group project ;

		foreach title of local titlelist {;
			returncol `titlecol';
			if "``title''"!="" & "``title''"!="-1" 
				local  titlesprint `titlesprint' `r(col)'`titlerow'=("``title''");
			local titlecol = `titlecol' + 1;
		};
				qui putexcel `titlesprint'  using `"`using'"', modify keepcellformat sheet("`sheet'");

	
		// Print version number on Excel sheet;
		local versionprint A4=("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'");
		
	};
    ********
    * OPEN *
    ********;
    if "`open'"!="" & "`c(os)'"=="Windows" {;
         shell start `using'; // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, ;
    };
    else if "`open'"!="" & "`c(os)'"=="MacOSX" {;
         shell open `using';
    };
    else if "`open'"!="" & "`c(os)'"=="Unix" {;
         shell xdg-open `using';
    };
	
	************
	* CLEAN UP *
	************;
	quietly putexcel clear;
	restore;

	
	end;	// END ceqdom;
