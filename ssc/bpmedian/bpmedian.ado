#delim ;
prog def bpmedian, eclass sortpreserve byable(recall);
version 10.0;
/*
 Estimate a median with its Bonett-Price variance
 and store the results as estimation results.
*!Author: Roger Newson
*!Date: 06 October 2016
*/

if replay() {;
/*
 Beginning of unindented replay section
*/

if `"`e(cmd)'"'!="bpmedian" error 301;
syntax [, Level(cilevel) EForm ];
/*
 level() specifies the confidence interval level.
 eform specifies that the confidence intreval is to be displayed
   in an exponentioted form.
*/

/*
 End of unindented replay section
*/
};
else {;
/*
 Beginning of unindented non-replay section
*/

syntax varname(numeric) [if] [in] [, Level(cilevel) EForm fast ];
/*
 level() specifies the confidence interval level.
 eform specifies that the confidence intreval is to be displayed
   in an exponentiated form.
 fast specifies that no action is taken to restore the original data
   if the program fails or if the user presses Break.
*/

local yvar `varlist';

marksample touse;
qui count if `touse';
if r(N)==0 error 2000;

if "`fast'"=="" {;preserve;};

sort `touse' `yvar', stable;

*
 Create temporary variables containing sequence order
 in the full dataset and in the estimation sample
 and local macros containing the position of the first observation of the estimation sample
*;
tempvar seqord fullseqord;
gene long `fullseqord'=_n;
by `touse': gene long `seqord'=_n;
qui summ `fullseqord' if `touse' & (`seqord'==1);
local fullseq1=r(min);
local nobs=_N-`fullseq1'+1;

*
 Create temporary scalars
 containing estimate, lower and upper bound, and variance
 of rank-based CI for median
*;
tempname alpha z median lbmedian ubmedian varmedian;
if mod(`nobs',2) {;
  scal `median'=`yvar'[(`fullseq1'+_N)/2];
};
else {;
  local imin=`nobs'/2;
  local imax=`imin'+1;
  scal `median'=(`yvar'[`fullseq1'+`imin'-1]+`yvar'[`fullseq1'+`imax'-1])/2;
};
local c=round((`nobs'+1)/2 + sqrt(`nobs'));
if `c'==0 {;local c=1;};
else if `c'>`nobs' {;local c=`nobs';};
scal `lbmedian'=`yvar'[`fullseq1'+`c'-1];
scal `ubmedian'=`yvar'[_N-`c'+1];
scal `alpha'=2*binomial(`nobs',`c'-1,0.5);
scal `z'=invnormal(1-`alpha'/2);
scal `varmedian'=(`ubmedian'-`lbmedian')/(2*`z');
scal `varmedian'=`varmedian'*`varmedian';

if "`fast'"=="" {;restore;};

*
 Create matrix results
*;
tempname bmat Vmat;
matr def `bmat'=J(1,1,`median');
matr def `Vmat'=J(1,1,`varmedian');
matr rownames `bmat'="y1";
matr colnames `bmat'="_cons";
matr rownames `Vmat'="_cons";
matr colnames `Vmat'="_cons";

*
 Return estimation results
*;
ereturn post `bmat' `Vmat', depname("`yvar'") obs(`nobs') esample(`touse') properties("b V");
ereturn local depvar "`yvar'";
ereturn local cmd "bpmedian";
ereturn local cmdline `"bpmedian `0'"';
ereturn scalar c=`c';

/*
 End of unindented non-replay section
*/
};

*
 Display results
*;
if "`eform'"!="" {;
  local eformopt `"eform("exp(median)")"';
  disp _n as text "Bonett-Price confidence interval for exp(median) of: " as result "`e(depvar)'";  
};
else {;
  disp _n as text "Bonett-Price confidence interval for median of: " as result "`e(depvar)'";
};
disp as text "Number of observations: " as result `e(N)';
ereturn display, `eformopt' level(`level');

end;
