* ADO FILE FOR EXTENDED INCOME CONCEPTS DOMINANCE SHEET OF CEQ OUTPUT TABLES

** VERSION AND NOTES (changes between versions described under CHANGES)
*! v1.7 01jun2017 For use with July 2017 version of Output Tables
** v1.6 01jun2017 For use with May 2017 version of Output Tables
** v1.5 06apr2017 For use with Oct 2016 version of Output Tables
** v1.4 18mar2017 For use with Oct 2016 version of Output Tables
** v1.3 12jan2017 For use with Oct 2016 version of Output Tables
** v1.2 30sep2016 
** (beta version; please report any bugs), written by Rodrigo Aranda raranda@tulane.edu

** CHANGES
**   06-29-2017 Replacing covcon with improved version by Paul Corral
**   06-01-2017 Add additional options to print meta-information and including title inputs
**   04-06-2017 Remove the warning about negative tax values
**   03-18-2017 Change bootstrap ksmirnov to ksmorniv 
** 	 01-12-2017 Set the data type of all newly generated variables to be double
** 				Add a check of the data type of income and fiscal variables and issue a warning if
**				 they are not double
** v1.1 changed reps option bug and set version to Stata 13   
* v1.2 Fixed bootstrapp test for no crossings

** NOTES
**  Uses uses domineq command from DASP to see number of intersections between concentration/lorenz curves, if 
*there are no intersections, then a Ksmirnov test for equality of distributions is done to test whether there 
*is stochastic dominance, the Ksmirnov test is bootstrapped because we cannot include svy options for the 
*estimation of this test
*uses glcurve command


** TO DO

*************************
** PRELIMINARY PROGRAMS *
*************************
// BEGIN returncol (Higgins 2015) 
//  Returns Excel column corresponding to a number
cap program drop returncol
program define returncol, rclass
	confirm integer number `1'
	mata: st_strscalar("col",numtobase26(`1'))
	return local col = col
end // END returncol


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

tempvar y2 w2;
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
gen double _fp=0;
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
gen _flp2=0;
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


#delimit cr
**********************
** ceqdomext PROGRAM *
**********************
** Quick and dirty way to fix too many variables problem: 
**  run the command separately for each income concep
capture program drop ceqdomext
program define ceqdomext
	#delimit ;
	syntax 
		[using]
		[if] [in] [pweight] 
		[, 
			/** INCOME CONCEPTS: */
			Market(varname)
			Mpluspensions(varname)
			Netmarket(varname) 
			Gross(varname)
			Taxable(varname)
			Disposable(varname) 
			Consumable(varname)
			Final(varname)
			OPEN
			*
		]
	;
	#delimit cr
	
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit display as text in smcl
	local die display as error in smcl
	local command ceqdomext
	local version 1.7
	`dit' "Running version `version' of `command' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to raranda@tulane.edu)"
	
	** income concept options
	#delimit ;
	local inc_opt
		market
		mpluspensions
		netmarket
		gross
		taxable
		disposable
		consumable
		final
	;
	#delimit cr
	local inc_opt_used ""
	foreach incname of local inc_opt {
		if "``incname''"!="" local inc_opt_used `inc_opt_used' `incname' 
	}
	local list_opt2 ""
	foreach incname of local inc_opt_used {
		local `incname'_opt "`incname'(``incname'')" // `incname' will be e.g. market
			// and ``incname'' will be the varname 
		local list_opt2 `list_opt2' `incname'2(``incname'') 
	}
	
	** negative incomes
	foreach v of local inc_opt {
		if "``v''"!="" {
			qui count if ``v''<0 // note `v' is e.g. m, ``v'' is varname
			if r(N) `dit' "Warning: `r(N)' negative values of ``v''"
		}
	}	
	
	** Check if all income variables are in double format
	local inctypewarn
	foreach var of local inc_opt {         /* varlist2 so that all income concepts will be checked and displayed once */
		if "``var''"!="" {
			local vartype: type ``var''
			if "`vartype'"!="double" {
				if wordcount("`inctypewarn'")>0 local inctypewarn `inctypewarn', ``var''
				else local inctypewarn ``var''
			}
		}
	}
	if wordcount("`inctypewarn'")>0 noi `dit' "Warning: Income variable(s) `inctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	if wordcount("`inctypewarn'")>0 local warning `warning' "Warning: Income variable(s) `inctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	
	local counter=1
	local n_inc_opts = wordcount("`inc_opt_used'")
	foreach incname of local inc_opt_used {
		// preliminary: 
		//	to open only on last iteration of _ceqdomext,
		//  only print warnings and messages once
		if "`open'"!="" & `counter'==`n_inc_opts' {
			local open_opt "open"
		}
		else {
			local open_opt ""
		}
		if `counter'==1 {
			local nodisplay_opt "" 
		}
		else {
			local nodisplay_opt "nodisplay"
		}
		
		local ++counter
	
		_ceqdomext `using' `if' `in' [`weight' `exp'], ///
			``incname'_opt' `list_opt2' `options' `open_opt' `nodisplay_opt' ///
			_version("`version'") 
	}
end

** For sheet E17. Dominance with Extended Income Concepts
// BEGIN _ceqdomext (Aranda 2016)
capture program drop _ceqdomext  
program define _ceqdomext, rclass 
	version 13.0
	#delimit ;
	syntax 
		[using/]
		[if] [in] [pweight/] 
		[, 
			INCNAME(string)
			/** INCOME CONCEPTS: */
			Market(varname)
			Mpluspensions(varname)
			Netmarket(varname) 
			Gross(varname)
			Taxable(varname)
			Disposable(varname) 
			Consumable(varname)
			Final(varname)
			/** REPEAT FOR CONCENTRATION MATRIX */
			/** (temporary hack-y patch) */
			market2(varname)
			mpluspensions2(varname)
			netmarket2(varname) 
			gross2(varname)
			taxable2(varname)
			disposable2(varname) 
			consumable2(varname)
			final2(varname)
			/** FISCAL INTERVENTIONS: */
			Pensions   (varlist)
			DTRansfers (varlist)
			DTAXes     (varlist) 
			COntribs(varlist)
			SUbsidies  (varlist)
			INDTAXes   (varlist)
			HEALTH     (varlist)
			EDUCation  (varlist)
			OTHERpublic(varlist)
			/** SURVEY INFORMATION */
			HHid(varname)
			HSize(varname) 
			PSU(varname) 
			Strata(varname)	
			/** EXPORTING TO CEQ MASTER WORKBOOK: */
			sheetm(string)
			sheetmp(string)
			sheetn(string)
			sheetg(string)
			sheett(string)
			sheetd(string)
			sheetc(string)
			sheetf(string)
			OPEN
			/** INFORMATION CELLS */
			COUNtry(string)
			SURVeyyear(string) /** string because could be range of years */
			AUTHors(string)		
			BASEyear(real -1)
			SCENario(string)
			GROUp(string)
			PROJect(string)
			/** OTHER OPTIONS */			
			NODIsplay
			_version(string)
			/** IGNOREMISSING */
			IGNOREMissing
			/*Domineq options*/
			reps(string)
		]
	;
	#delimit cr
		
	***********
	** LOCALS *
	***********
	** general programming locals
	local dit if "`nodisplay'"=="" display as text in smcl
	local die display as error in smcl
	local command ceqdomext
	local version `_version'
	
	
	** income concepts
	local m `market'
	local mp `mpluspensions'
	local n `netmarket'
	local g `gross'
	local t `taxable'
	local d `disposable'
	local c `consumable'
	local f `final'
	local m2 `market2'
	local mp2 `mpluspensions2'
	local n2 `netmarket2'
	local g2 `gross2'
	local t2 `taxable2'
	local d2 `disposable2'
	local c2 `consumable2'
	local f2 `final2'
	local alllist m mp n g t d c f
	local alllist2 m2 mp2 n2 g2 t2 d2 c2 f2
	local incomes = wordcount("`alllist'")
	
	local origlist m mp n g d
	tokenize `alllist' // so `1' contains m; to get the variable you have to do ``1''
	local varlist ""
	local varlist2 ""
	local counter = 1
	
	foreach y of local alllist {
		local varlist `varlist' ``y'' // so varlist has the variable names
		local varlist2 `varlist2' ``y'2'
		// reverse tokenize:
		local _`y' = `counter' // so _m = 1, _mp = 2 (regardless of whether these options included)
		if "``y''"!="" local `y'__ `y' // so `m__' is e.g. m if market() was specified, "" otherwise
		local ++counter
	}
	
	local d_m      = "Market Income"
	local d_mp     = "Market Income + Pensions"
	local d_n      = "Net Market Income"
	local d_g      = "Gross Income"
	local d_t      = "Taxable Income"
	local d_d      = "Disposable Income"
	local d_c      = "Consumable Income"
	local d_f      = "Final Income"
	
	foreach y of local alllist {
		if "``y''"!="" {
			scalar _d_``y'' = "`d_`y''"
		}
	}
	
	
	** transfer and tax categories
	local taxlist dtaxes contribs indtaxes
	local transferlist pensions dtransfers subsidies health education otherpublic
	local programlist  pensions dtransfers dtaxes contribs subsidies indtaxes health education otherpublic
	foreach x of local programlist {
		local allprogs `allprogs' ``x'' // so allprogs has the actual variable names
	}
	
	** weight (if they specified hhsize*hhweight type of thing)
	if strpos("`exp'","*")> 0 { // TBD: what if they premultiplied w by hsize?
		`die' "Please use the household weight in {weight}; this will automatically be multiplied by the size of household given by {bf:hsize}"
		exit
	}
	
	** hsize and hhid
	if wordcount("`hsize' `hhid'")!=1 {
		`die' "Must exclusively specify {bf:hsize} (number of household members for household-level data) or "
		`die' "{bf:hhid} (unique household identifier for individual-level data)"
		exit 198
	}
	
	************************
	** PRESERVE AND MODIFY *
	************************
	preserve
	if wordcount("`if' `in'")!=0 quietly keep `if' `in'
	
	** make sure all newly generated variables are in double format
	set type double 
	
	** collapse to hh-level data
	if "`hsize'"=="" { // i.e., it is individual-level data
		tempvar members
		sort `hhid'
		qui bys `hhid': gen `members' = _N // # members in hh 
		qui bys `hhid': drop if _n>1 // faster than duplicates drop
		local hsize `members'
	}
	
	***********************
	** SVYSET AND WEIGHTS *
	***********************
	cap svydes
	scalar no_svydes = _rc
	if !_rc qui svyset // gets the results saved in return list
	if "`r(wvar)'"=="" & "`exp'"=="" {
		`dit' "Warning: weights not specified in svydes or the command"
		`dit' "Hence, equal weights (simple random sample) assumed"
	}
	else {
		if "`exp'"=="" & "`r(wvar)'"!="" local w `r(wvar)'
		if "`exp'"!="" local w `exp'
		if "`w'"!="" {
			tempvar weightvar
			qui gen double `weightvar' = `w'*`hsize'
			local w `weightvar'
		}
		else local w "`hsize'"
		
		if "`w'"!="" {
			local pw "[pw = `w']"
			local aw "[aw = `w']"
		}
		if "`exp'"=="" & "`r(wvar)'"!="" {
			local weight "pw"
			local exp "`r(wvar)'"
		}
	}
	else if "`r(su1)'"=="" & "`psu'"=="" {
		di as text "Warning: primary sampling unit not specified in svydes or the d1 command's psu() option"
		di as text "P-values will be incorrect if sample was stratified"
	}
	if "`psu'"=="" & "`r(su1)'"!="" {
		local psu `r(su1)'
	}
	if "`strata'"=="" & "`r(strata1)'"!="" {
		local strata `r(strata1)'
	}
	if "`strata'"!="" {
		local opt strata(`strata')
	}
	** now set it:
	if "`exp'"!="" qui svyset `psu' `pw', `opt'
	else           qui svyset `psu', `opt'
	
	************************
	** PRESERVE AND MODIFY *
	************************
	local relevar `varlist2' `allprogs' ///
				  `w' `psu' `strata' ///
				  `pl_tokeep' 
	quietly keep `relevar' 
	
	** missing income concepts
	foreach var of local varlist2 {
		qui count if missing(`var')  
		if "`ignoremissing'"=="" {
			if r(N) {
				`die' "Missing values not allowed; `r(N)' missing values of `var' found" 
				exit 198
			}
		}
		else {
			if r(N) {
				qui drop if missing(`var')
				`dit' "Warning: `r(N)' observations that are missing `var' were dropped because the user specified {bf:ignoremissing}"
			}
		}
	}
	
	** missing fiscal interventions 
	foreach var of local allprogs {
		if "`varlist'"=="`market'" {   // so that it only runs once 
			qui count if missing(`var') 
			if "`ignoremissing'"=="" {
				if r(N) {
					`die' "Missing values not allowed; `r(N)' missing values of `var' found"
					`die' "For households that did not receive/pay the tax/transfer, assign 0"
					exit 198
				}
			}
			else {
				if r(N) {
				qui drop if missing(`var')
				di "Warning: `r(N)' observations that are missing `var' were dropped because the user specified {bf:ignoremissing}"
				}
			}
		} 
	}
	
	** columns including disaggregated components and broader categories
	local broadcats dtransfersp dtaxescontribs inkind alltaxes alltaxescontribs alltransfers 
	local dtransfersp `pensions' `dtransfers' 
	local dtaxescontribs `dtaxes' `contribs'
	local inkind `health' `education' `otherpublic' // these contain the variables, or blank if not specified
	local alltransfers `dtransfers' `subsidies' `inkind'
	local alltransfersp
	local alltaxes `dtaxes' `indtaxes'
	local alltaxescontribs `dtaxes' `contribs' `indtaxes'
	
	
	
	foreach cat of local programlist {
		if "``cat''"!="" {
			tempvar v_`cat' // in the locals section despite creating vars
			qui gen `v_`cat''=0 // because necessary for local programcols
			foreach x of local `cat' {
				qui replace `v_`cat'' = `v_`cat'' + `x' // so e.g. v_dtaxes will be sum of all vars given in dtaxes() option
			}
				// so suppose there are two direct taxes dtr1, dtr2 and two direct taxes dtax1, dtax2
				// then `programcols' will be dtr1 dtr2 dtransfers dtax1 dtax2 dtaxes
		}	
	}
	foreach bc of local broadcats {
		if wordcount("``bc''")>0 { // i.e. if any of the options were specified; for bc=inkind this says if any options health education or otherpublic were specified
			tempvar v_`bc'
			qui gen `v_`bc'' = 0
			foreach var of local `bc' { // each element will be blank if not specified
				qui replace `v_`bc'' = `v_`bc'' + `var'
			}
		}
	}	

	#delimit ;
	local programcols 
		`pensions' `v_pensions'
		`dtransfers' `v_dtransfers' `v_dtransfersp'
		`dtaxes' `contribs' `v_dtaxescontribs'
		`subsidies' `v_subsidies' `indtaxes' `v_indtaxes'
		`v_alltaxes' `v_alltaxescontribs'
		`health' `education' `otherpublic' `v_inkind'
		`v_alltransfers' `v_alltransfersp'
	;
	local transfercols 
		`pensions' `v_pensions'
		`dtransfers' `v_dtransfers' `v_dtransfersp'
		`subsidies' `v_subsidies'
		`health' `education' `otherpublic' `v_inkind'
		`v_alltransfers' `v_alltransfersp'
	;
	local taxcols: list programcols - transfercols; // set subtraction;
	#delimit cr

	** labels for fiscal intervention column titles
	foreach pr of local allprogs { // allprogs has variable names already
		local d_`pr' : var label `pr'
		if "`d_`pr''"=="" { // ie, if the var didnt have a label
			local d_`pr' `pr'
			`dit' "Warning: variable `pr' not labeled"
		}
		scalar _d_`pr' = "`d_`pr''"
	}
	scalar _d_`v_pensions'         = "All contributory pensions"
	scalar _d_`v_dtransfers'       = "All direct transfers excluding contributory pensions"
	scalar _d_`v_dtransfersp'      = "All direct transfers including contributory pensions"
	scalar _d_`v_contribs'         = "All contributions"
	scalar _d_`v_dtaxes'           = "All direct taxes"
	scalar _d_`v_dtaxescontribs'   = "All direct taxes and contributions"
	scalar _d_`v_subsidies'        = "All indirect subsidies"
	scalar _d_`v_indtaxes'         = "All indirect taxes"
	scalar _d_`v_health'           = "All health"
	scalar _d_`v_education'        = "All education"
	scalar _d_`v_otherpublic'      = "All other public spending" // LOH need to fix that this is showing up even when I don't specify the option
	scalar _d_`v_inkind'           = "All in-kind"
	scalar _d_`v_alltransfers'     = "All transfers and subsidies excluding contributory pensions"
	scalar _d_`v_alltransfersp'    = "All transfers and subsidies including contributory pensions"
	scalar _d_`v_alltaxes'         = "All taxes"
	scalar _d_`v_alltaxescontribs' = "All taxes and contributions"
	
	** results
	local supercols totLCU 
	foreach y of local alllist {
		if "``y''"!="" local supercols `supercols' fi_`y'
	}
	
	** titles 
	local _totLCU   = "LORENZ TOTALS (LCU)"
	
	foreach v of local alllist {
		local uppered = upper("`d_`v''")
		local _fi_`v' = "DOMINANCE TEST WITH RESPECT TO `uppered'"
	}
	
	******************
	** PARSE OPTIONS *
	******************
	** Check if all fisc variables are in double format
	local fisctypewarn
	foreach var of local allprogs {
		if "`var'"!="" {
			local vartype: type `var'
			if "`vartype'"!="double" {
				if wordcount("`fisctypewarn'")>0 local fisctypewarn `fisctypewarn', `var'
				else local fisctypewarn `var'
			}
		}
	}
	if wordcount("`fisctypewarn'")>0 `dit' "Warning: Fiscal intervention variable(s) `fisctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	if wordcount("`fisctypewarn'")>0 local warning `warning' "Warning: Fiscal intervention variable(s) `fisctypewarn' not stored in double format. This may lead to substantial discrepancies in the MWB due to rounding error."
	
	* make sure -domineq- is installed
	cap which domineq
	if _rc {
		`dit' `"Warning: {bf:domineq} not installed, Dominance results not produced"'
		`dit' `"To install: {Install from DASP, from(http://dasp.ecn.ulaval.ca/)"}"'
	}
	* make sure -glcurve- is installed
	cap which glcurve
	if _rc {
		`dit' "Warning: {bf:glcurve} not installed, Dominance results not produced"	
	}

	
	** ado file specific
	foreach vrank of local alllist {
		if "`sheet`vrank''"=="" {
			if "`vrank'"=="mp" local sheet`vrank' "E17.m+p Dominance"
			else {
				local sheet`vrank' "E17.`vrank' Dominance" // default name of sheet in Excel files
			}
		}
	}
	
	** make sure using is xls or xlsx
	ceq_parse_using using `"`using'"', cmd("ceqdomext") open("open")

	** create new variables for program categories

	if wordcount("`allprogs'")>0 ///
	foreach pr of local taxcols {
		qui summ `pr', meanonly
		if r(mean)>0 {
			if wordcount("`postax'")>0 local postax `postax', `x'
			else local postax `x'
			qui replace `pr' = -`pr' // replace doesnt matter since we restore at the end
		}
	}
	/*if wordcount("`postax'")>0 {
		`dit' "Taxes appear to be positive values for variable(s) `postax'; replaced with negative for calculations"
	}*/
	
	foreach y of local alllist {
		local marg`y' ``y''
	}	
	** create extended income variables
	foreach pr in `pensions' `v_pensions' { // did it this way so if they're missing loop is skipped over, no error
		foreach y in `m__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `mp__' `n__' `g__' `d__' `c__' `f__' { // t excluded bc unclear whether pensions included
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `dtransfers' `v_dtransfers' {
		foreach y in `m__' `mp__' `n__' {
			tempvar `y'_`pr' 
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr' 
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `g__' `d__' `c__' `f__' { // t excluded bc unclear whether dtransfers included
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `v_dtransfersp' {
		foreach y in `m__' { // can't include mp or n here bc they incl pens but not dtransfers
			tempvar `y'_`pr' 
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr' 
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `g__' `d__' `c__' `f__' { // t excluded bc unclear whether dtransfers included
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''			
		}
	}
	foreach pr in `dtaxes' `v_dtaxes' `contribs' `v_contribs' `v_dtaxescontribs' {
		foreach y in `m__' `mp__' `g__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr' // written as minus since taxes thought of as positive values
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `n__' `t__' `d__' `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `subsidies' `v_subsidies' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' {
			tempvar `y'_`pr' 
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `indtaxes' `v_indtaxes' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr' 
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `v_alltaxes' `v_alltaxescontribs' {
		foreach y in `m__' `mp__' `g__' `t__' { // omit n, d which have dtaxes subtr'd but not indtaxes
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr' // plus because you already made taxes negative!
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''			
		}
		foreach y in `c__' `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr' 
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `health' `education' `otherpublic' ///
	`v_health' `v_education' `v_otherpublic' `v_inkind' {
		foreach y in `m__' `mp__' `n__' `g__' `t__' `d__' `c__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''
		}
	}
	foreach pr in `v_alltransfers' {
		foreach y in `m__' `mp__' `n__' { // omit g, t, d, c which have some transfers
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''		
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''		
		}
	}
	foreach pr in `v_alltransfersp' {
		foreach y in `m__' { // omit mplusp, n which have pensions, g, t, d, c which have some transfers
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' + `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' + " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''		
		}
		foreach y in `f__' {
			tempvar `y'_`pr'
			qui gen ``y'_`pr'' = ``y'' - `pr'
			scalar _d_``y'_`pr'' = "`d_`y'' - " + _d_`pr'
			local marg`y' `marg`y'' ``y'_`pr''		
		}		
	}
	
	** get length of marg`y'
	local maxlength = 0
	foreach v of local alllist {
		if "``v''"!="" {
			local length = wordcount("`marg`v''")
			local maxlength = max(`maxlength',`length')
		}
	}
	local colsneeded = (wordcount("`supercols'"))*`maxlength'*2 // *2 is for crossings and p-values
	
	
	** temporary variables
	tempvar one
	qui gen `one' = 1
	
	
	#delimit;
	*****REPS*****;
	if "`reps'"==""{;
	local reps=10;
	};
	
	*Temporary dataset from which to run results;
	tempfile orig;
	save `orig',replace;
	
	*****Lorenz curves;
	local rowc=0;
	*noisily di in red "`alllist'";
	foreach y of local alllist {;
	*noisily di in red "``y''";
	};

	foreach y of local alllist {;
		if "``y''"!="" {;
			local row = 0;
			local cols = (wordcount("`marg`y''"))*2;
			matrix inc_`y'=J(1,`cols',.);
			matrix conc_`y'=J(8,`cols',.);
			local col = 0;
			local colc=0;
				foreach ext of local marg`y' {;
			local col=`col'+1;
				local row = `row'+1;			
				*noisily di in red "``y'' `ext'";
				qui sum ``y'' `ext';
				
				*Estimates for INCOME;
				
				qui domineq ``y'' `ext', rank1(``y'') rank2(`ext');
				matrix inc_`y'[1,`col'] = r(inters);
				local col=`col'+1;
				
				if r(inters)==0{;
					tempvar x1 y1 x2 y2 num ;		
					glcurve ``y'' `aw', sortvar(``y'') lorenz pvar(`x1') glvar(`y1')  replace nograph;
					gen `num'=1;//identifier;
					keep `x1' `y1' `num';
					tempfile temp1;
					save "`temp1'",replace;
					use "`orig'",clear;
					glcurve `ext' `aw', sortvar(``ext'') lorenz pvar(`x1') glvar(`y1')  replace nograph;
					gen `num'=2;//identifier;
					keep `x1' `y1' `num';
					append using "`temp1'";
					/*qui bootstrap  r(p_cor),reps(`reps') seed(12345):  ksmirnov `y1',by(`num');
					matrix res=r(table);
					local pval=res[4,1];*/
					ksmirnov `y1',by(`num');
					matrix inc_`y'[1,`col']= `r(p)';
					
					use "`orig'",clear;	
					
				};
				else{;
					matrix inc_`y'[1,`col']= .;
				};
				*noisily matrix list inc_`y';
			};
			
				*Results for CONCENTRATION CURVES;
			local rowc = 0;			
				
			foreach z of local alllist2 {;
			local rowc = `rowc'+1;			
			local colc = 0;	
			if "``z''"!="" {;
				foreach ext of local marg`y' {;
					local colc=`colc'+1;

					domineq ``y'' `ext', rank1(``z'') rank2(``z'');
					matrix conc_`y'[`rowc',`colc'] = r(inters);
					local colc=`colc'+1;
						if r(inters)==0{;
							tempvar x1 y1 x2 y2 num ;
		
							glcurve ``y'' `aw', sortvar(``z'') lorenz pvar(`x1') glvar(`y1')  replace nograph;
							gen `num'=1;//identifier;
							keep `x1' `y1' `num';
							tempfile temp1;
							save "`temp1'",replace;
							use "`orig'",clear;
							glcurve `ext' `aw', sortvar(``z'') lorenz pvar(`x1') glvar(`y1')  replace nograph;
							gen `num'=2;//identifier;
							keep `x1' `y1' `num';
							append using "`temp1'";
							/*qui bootstrap  r(p_cor),reps(`reps') seed(12345):  ksmirnov `y1',by(`num');
							matrix res=r(table);
							local pval=res[4,1];*/
							ksmirnov `y1',by(`num');
							matrix conc_`y'[`rowc',`colc']= `r(p)';
							use "`orig'",clear;	
						};
						else{;
							matrix conc_`y'[`rowc',`colc']= .;

						};
						*di in red "INCOMEE `y', row `rowc' col `colc' z `z'";
				*noisily matrix list conc_`y';
				};
				};
			};
		};
		};
			
#delimit cr	
	*****************
	** SAVE RESULTS *
	*****************
	if `"`using'"'!="" {
		qui di "
		`dit' `"Writing to "`using'"; may take several minutes"'
		local startcol_o = 2 // this one will stay fixed (column B)

		// Print information
		local date `c(current_date)'
		local titlesprint
		local titlerow = 3
		local trow = 7
		local titlecol = 1
		local titlelist country surveyyear authors date scenario group project
		
		foreach title of local titlelist {
			returncol `titlecol'
			if "``title''"!="" & "``title''"!="-1"  ///
				local  titlesprint `titlesprint' `r(col)'`titlerow'=("``title''")
			local titlecol = `titlecol' + 1
			
		}
		
		foreach y of local alllist {
			local startcol = `startcol_o'
			local titles`y'
			if "``y''"!="" {
				*noisily matrix list inc_`y'
				*noisily matrix list conc_`y'

				putexcel B9=matrix(inc_`y') using `"`using'"',keepcellformat modify sheet("`sheet`y''")
				
				putexcel B11=matrix(conc_`y') using `"`using'"',keepcellformat modify sheet("`sheet`y''") 
				putexcel A4=("Results produced by version `version' of `command' on `c(current_date)' at `c(current_time)'") using `"`using'"',keepcellformat modify sheet("`sheet`y''") 
				
					foreach ext of local marg`y' {
						returncol `startcol'
						local titles`y' `titles`y'' `r(col)'`trow'=(_d_`ext')
						local startcol=`startcol'+1 //for p-val columns too
						returncol `startcol'
						local titles`y' `titles`y'' `r(col)'`trow'=(_d_`ext')
						local startcol=`startcol'+1
					}
				#delimit;
				*di `" `titlesprint' `versionprint' `titles`y'' "' ;
				qui putexcel `titlesprint' `versionprint' `titles`y'' 
				using `"`using'"', modify keepcellformat sheet("`sheet`y''");
				#delimit cr
				
			}
		}
		}
    *********
    ** OPEN *
    *********
    if "`open'"!="" & "`c(os)'"=="Windows" {
         shell start `using' // doesn't work with "" or `""' so I already changed `open' to "" if using has spaces, 
    }
    else if "`open'"!="" & "`c(os)'"=="MacOSX" {
         shell open `using'
    }
    else if "`open'"!="" & "`c(os)'"=="Unix" {
         shell xdg-open `using'
    }
	
	*************
	** CLEAN UP *
	*************
	quietly putexcel clear
	restore // note this also restores svyset
	
end	// END ceqdomext
