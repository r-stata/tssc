#delim ;
prog def senspec, rclass sortpreserve;
version 10.0;
/*
 Input a classification variable containing results for a quantitative diagnostic test
 and a reference variable with 2 values of which the higher value indicates a condition,
 and output generated variables containing, in each observation,
 the numbers and/or rates of true positives, true negatives, false positives and false negatives
 expected if the classification variable is used to define a diagnostic test
 with a threshold equal to the value of the classification variable for that observation.
*! Author: Roger Newson
*! Date: 31 May 2017
*/

syntax varlist( numeric min=2 max=2 ) [if] [in] [fweight aweight pweight iweight] [, Posif(string)
    NFNeg(namelist min=1 max=1) NFPos(namelist min=1 max=1) NTNeg(namelist min=1 max=1) NTPos(namelist min=1 max=1)
    SEnsitivity(namelist min=1 max=1) SPecificity(namelist min=1 max=1) FPos(namelist min=1 max=1) FNeg(namelist min=1 max=1)
    float
  ];

/*
posif specifies whether a class variable value is considered positive
  if it is >threshold, <threshold, >=threshold or <=threshold.
nfneg names a generated variable containing, in each observation, the number of false negatives
  if the value of the class variable in that observation is used as the threshold.
nfpos names a generated variable containing, in each observation, the number of false positives
  if the value of the class variable in that observation is used as the threshold.
ntneg names a generated variable containing, in each observation, the number of true negatives
  if the value of the class variable in that observation is used as the threshold.
ntpos names a generated variable containing, in each observation, the number of true positives
  if the value of the class variable in that observation is used as the threshold.
sensitivity names a generated variable containing, in each observation, the sensitivity
  if the value of the class variable in that observation is used as the threshold.
specificity names a generated variable containing, in each observation, the specificity
  if the value of the class variable in that observation is used as the threshold.
fpos names a generated variable containing, in each observation, the false positive rate
  if the value of the class variable in that observation is used as the threshold.
fneg names a generated variable containing, in each observation, the false negative rate
  if the value of the class variable in that observation is used as the threshold.
float specifies that the derived quantities will be generated as type float
  (instead of type double).
*/

preserve;

*
 Assign local macros and temporary variables
 arising from the syntax
*;
marksample touse, zeroweight;
local refvar: word 1 of `varlist';
local classvar: word 2 of `varlist';
if `"`exp'"'=="" {;local exp "=1";};
tempvar wgt;
tempname sumwgt;
qui gene double `wgt' `exp' if `touse';
qui compress `wgt';
cap assert `wgt'>=0 if `touse';
if _rc!=0 {;
  disp as error "Negative weights not allowed";
  error 498;
};
qui summ `wgt';
scal `sumwgt'=r(sum);

*
 Check that reference variable has exactly 2 non-missing values
 and create binary variable indicating positive status
*;
tempname minref maxref;
qui summ `refvar' if `touse';
scal `minref'=r(min);
scal `maxref'=r(max);
if `minref'==`maxref' {;
  disp as error "Two non-missing values required for reference variable";
  error 498;
};
else {;
  cap assert inlist(`refvar',`minref',`maxref') if `touse';
  if _rc!=0 {;
    disp as error "More than two non-missing values in reference variable `refvar'";
    error 498;
  };
};
tempvar posi;
qui gene byte `posi'=`refvar'==`maxref' if `touse';

*
 Recode posif to be equal to the operator
 used to compare class variable value to threshold
*;
if `"`posif'"'=="" {;local posif=">=";};
local posif=lower(`"`posif'"');
local posif=subinstr(`"`posif'"'," ","",.);
if `"`posif'"'=="gt" {;local posif=">";};
else if `"`posif'"'=="lt" {;local posif="<";};
else if `"`posif'"'=="ge" {;local posif=">=";};
else if `"`posif'"'=="le" {;local posif="<=";};
if !inlist(`"`posif'"',"<",">","<=",">=") {;
  disp as error `"Invalid posif(`posif')"';
  error 498;
};

*
 Generate numbers of true positives, false positives,
 true negatives and false negatives
 using threshold at each observation
*;
tempvar classgp neqsame firneg firpos;
if "`ntpos'"=="" {;tempvar ntpos;};
if "`nfpos'"=="" {;tempvar nfpos;};
if "`ntneg'"=="" {;tempvar ntneg;};
if "`nfneg'"=="" {;tempvar nfneg;};
if inlist("`weight'","aweight","pweight","iweight") {;
  local npostype "double";
};
else {;
  local npostype "long";
};
qui {;
  *
   Numbers of true and false positives
  *;
  if inlist(`"`posif'"',">=",">") {;
    gsort `touse' -`classvar', gene(`classgp');
  };
  else {;
    gsort `touse' `classvar', gene(`classgp');
  };
  bysort `touse' `classgp' `posi': egen double `neqsame'=total(`wgt') if `touse';
  by `touse' `classgp' `posi': gene byte `firneg'=(_n==1)*(1-`posi') if `touse';
  by `touse' `classgp' `posi': gene byte `firpos'=(_n==1)*`posi' if `touse';
  gsort `touse' `classgp' -`posi' -`firpos';
  gene double `ntpos'=sum(`neqsame'*`firpos') if `touse';
  gsort `touse' `classgp' `posi' -`firneg';
  gene double `nfpos'=sum(`neqsame'*`firneg') if `touse';
  if inlist("`posif'","<",">") {;
    *
     Class variable values equal to threshold test negative
    *;
    tempvar neqpos neqneg neqtemp;
    gene double `neqtemp'=`neqsame'*`posi' if `touse';
    by `touse' `classgp': egen double `neqpos'=max(`neqtemp') if `touse';
    drop `neqtemp';
    gene double `neqtemp'=`neqsame'*(1-`posi') if `touse';
    by `touse' `classgp': egen double `neqneg'=max(`neqtemp') if `touse';
    drop `neqtemp';
    replace `ntpos'=`ntpos'-`neqpos';
    replace `nfpos'=`nfpos'-`neqneg';
  };
  *
   Numbers of true and false negatives
  *;
  tempname sumwgtpos sumwgtneg;
  summ `wgt' if `touse' & !`posi';
  scal `sumwgtneg'=r(sum);
  gene double `ntneg'=`sumwgtneg'-`nfpos';
  summ `wgt' if `touse' & `posi';
  scal `sumwgtpos'=r(sum);
  gene double `nfneg'=`sumwgtpos'-`ntpos';
  *
   Compress all 4 generated variables
  *;
  compress `ntpos' `nfpos' `ntneg' `nfneg';
  foreach X of var `ntpos' `nfpos' `ntneg' `nfneg' {;
    recast `npostype' `X', force;
  };
};
lab var `ntpos' "Number of true positives";
lab var `nfpos' "Number of false positives";
lab var `ntneg' "Number of true negatives";
lab var `nfneg' "Number of false negatives";

*
 Calculate derived quantities from ntpos, ntneg, nfpos and nfneg
*;
if "`float'"=="" {;
  local dertype="double";
};
else {;
  local dertype="float";
};
if "`sensitivity'"!="" {;
  qui gene `dertype' `sensitivity'=`ntpos'/(`ntpos'+`nfneg') if `touse';
  qui compress `sensitivity';
  lab var `sensitivity' "Sensitivity";
};
if "`specificity'"!="" {;
  qui gene `dertype' `specificity'=`ntneg'/(`ntneg'+`nfpos') if `touse';
  qui compress `specificity';
  lab var `specificity' "Specificity";
};
if "`fpos'"!="" {;
  qui gene `dertype' `fpos'=`nfpos'/(`ntneg'+`nfpos') if `touse';
  qui compress `fpos';
  lab var `fpos' "False positive rate";
};
if "`fneg'"!="" {;
  qui gene `dertype' `fneg'=`nfneg'/(`ntpos'+`nfneg') if `touse';
  qui compress `fneg';
  lab var `fneg' "False negative rate";
};

restore, not;

*
 Saved results
*;
return scalar N=`sumwgt';
return scalar N_pos=`sumwgtpos';
return scalar N_neg=`sumwgtneg';

end;
