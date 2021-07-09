/**************************************/
/* By   : Araar Abdelkrim  (2005)     */
/* Laval University, Quebec, Canada   */
/* email : aabd@ecn.ulaval.ca         */
/* Phone : 1 418 656 7507             */
/* module: clorenz, version 1         */
/* Date  : 18-12-2005                 */
/**************************************/

#delim ;
capture program drop nargs;
program define nargs, rclass;
version 8.0;
syntax varlist(min=0);
quietly {;
tokenize `varlist';
local k = 1;
mac shift;
while "``k''" ~= "" {; 
local k = `k'+1;
};
};
global indica=`k';
end;

capture program drop lorenz2;
program define lorenz2, rclass;
version 8.0;
args www yyy rank generalised gr ng;
preserve;
if ("`gr'" ~="") qui keep if (`gr'==gn1[`ng']);
if ("`rank'" == "-1") sort `yyy';
if ("`rank'" ~= "-1") sort `rank';
cap drop if `yyy'>=.;
cap drop if `www'>=.;
if (_N<101) qui set obs 101;
cap drop _ww;
cap drop _wy;
cap drop _lp;
gen _ww = sum(`www');
gen _wy = sum(`www'*`yyy');
local suma = _wy[_N];
cap drop _pc;
qui sum _ww;
gen _pc=_ww/r(max);
if ("`generalised'"~="yes") qui sum `yyy' [aw=`www'];
if ("`generalised'"=="yes") qui sum `www';
local suma = `suma'/`r(sum)';
gen _lp=_wy/r(sum);
cap drop _finlp;
gen _finlp=0;
local i = 1;
forvalues j=1/99 {;
local pcf=`j' /100;
local av=`j'+1;
while (`pcf' > _pc[`i']) {;
local i=`i'+1;
};
local ar=`i'-1;
if (`i'> 1) local lpi=_lp[`ar']+((_lp[`i']-_lp[`ar'])/(_pc[`i']-_pc[`ar']))*(`pcf'-_pc[`ar']);
if (`i'==1) local lpi=0+((_lp[`i'])/(_pc[`i']))*(`pcf');
qui replace _finlp=`lpi' in `av';
};
if ("`generalised'"~="yes") qui replace _finlp = 1 in 101;
if ("`generalised'"=="yes") qui replace _finlp = `suma' in 101;
qui keep in 1/101;
set matsize 101;
cap matrix drop _xx;
mkmat _finlp, matrix (_xx);
restore;
end;

capture program drop clorenz;
program define clorenz, rclass;
version 8.0;
syntax varlist(min=1)[, HWeight(varname) HSize(varname) HGroup(varname) RANK(varname) GENERalised(string) CTItle(string) DIF(string) LRES(string) SRES(string) DGRaph(string)];
if ("`hgroup'"!="") {;
preserve;
capture {;
uselabel `hgroup' , clear;
qui count;
forvalues i=1/`r(N)' {;
local grlab`i' = label[`i'];
};
};
restore;
preserve;
qui tabulate `hgroup', matrow(gn);
svmat int gn;
global indica=r(r);
tokenize `varlist';
};
if ("`hgroup'"=="") {;
tokenize `varlist';
nargs    `varlist';
preserve;
};
tempvar fw;
local l45=$indica+1;
local _cory  = "";
local label = "";
if ("`dif'"=="" & "`generalised'"~="yes") local label1 =  "line_45°";
quietly{;
gen `fw'=1;
local tit1="Lorenz"; 
local tit2="L"; 
local tit3="";
local tit4="";
if ("`rank'"!="") {;
local tit1="Concentration";
local tit2="C";
};
if ("`generalised'"=="yes") {;
local tit3="Generalised ";
local tit4="G";
};
local ftitle = "`tit3'"+"`tit1' Curve(s)";
local ytitle = "`tit4'`tit2'(p)";
if (("`dif'"=="yes") & ("`generalised'"~="yes")) {;
local ftitle = "Deficit share curve(s): p - `tit4'`tit2'(p)";
local ytitle = "p-`tit4'`tit2'(p)";
};
if ("`ctitle'"  ~="")     local ftitle ="`ctitle'";
if ("`hsize'"  ~="")     replace `fw'=`fw'*`hsize';
if ("`hweight'"~="")     replace `fw'=`fw'*`hweight';
};
qui count;
if (r(N)<101) set obs 101;
if ("`dif'"=="" & "`generalised'"~="yes" ) local _cory = "`_cory'" + " _corx";
forvalues k = 1/$indica {;
local _cory  = "`_cory'" + " _cory`k'";
local f=`k'+1;
if ("`dif'"!="" | "`generalised'"=="yes")  local f =`k';
if ("`rank'"=="") local rank = -1;
if ("`generalised'"=="") local generalised = "no";
if ("`hgroup'"=="") {;
local label`f'  =  "``k''";
lorenz2 `fw' ``k''   `rank' `generalised' ;
};

if ("`hgroup'"!="") {;
if ( "`grlab`k''" == "") local grlab`k' = "Group `k'";
local label`f'  =  "`grlab`k''";
lorenz2 `fw' `1' `rank' `generalised' `hgroup' `k';
};
svmat float _xx;
cap matrix drop _xx;
rename _xx1 _cory`k';
};
gen _corx = (_n-1)/100;
qui keep in 1/101;
if ("`dif'"!="" & "`generalised'"~="yes" ) {;
foreach var of varlist _cory* {;
if ("`dif'"=="yes")  qui replace `var' =  _corx - `var';
};
};
if( "`lres'" == "yes") {;
set more off;
list _corx _cory*;
};

if ("`dgraph'"~="no") {; 
line `_cory'  _corx, 
legend(
label(1 `label1')
label(2 `label2')
label(3 `label3')
label(4 `label4')
label(5 `label5')
label(6 `label6')
label(7 `label7')
label(8 `label8')
label(9 `label9')
label(10 `label10')
label(11 `label11')
label(12 `label12')
)
title(`ftitle')
ytitle(`ytitle')
xtitle(Percentiles (p)) 
xscale(range(0 1))
plotregion(margin(zero))
;
};
cap matrix drop _xx;
if( "`sres'" ~= "") {;
keep _corx _cory*;
save `sres', replace;
};
restore;
end;
