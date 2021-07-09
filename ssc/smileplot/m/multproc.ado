#delim ;
prog def multproc,rclass byable(onecall) sortpreserve;
version 10.0;
/*
  Multiple test procedures.
  Take, as input, a data set with 1 obs per null hypothesis tested
  and a variable containing the correspoding P-values,
  and a specified multiple test procedure method
  and a specified uncorrected P-value threshold.
  Create, as output, new variables containing P-value ranks,
  corresponding critical P-values, and null hypothesis credibility indicators,
  and also an overall corrected P-value r(pcor),
  such that a null hypothesis with p-value p is incredible
  if and only if p<=r(pcor).
*! Author: Roger Newson
*! Date: 08 October 2012
*/

syntax [if] [in] [,
 RAnk(string) GPUncor(string) CRitical(string) GPCor(string)
 NHcred(string) REJect(string)
 FLOAT FAST * ];
/*
 -rank- is a new variable generated to contain the ranks of the P-values
  (from lowest to highest, with ties sorted in original order).
 -gpuncor- is a new variable generated to contain the uncorrected P-value threshold used.
 -critical- is a new variable generated to contain critical P-value thresholds
  corresponding to the P-values in -pvalue-
  (for use in a one-step, step-up or step-down procedure).
 -gpcor- is a new variable generated to contain, for all observations in each by-group,
  the overall corrected P-value threshold calculated for that by-group.
 -nhcred- is a new variable generated to contain an indicator
  that the null hypothesis for that observation is credible,
  given the choice of uncorrected P-threshold and method.
 -reject- is a new variable generated to contain an indicator
  that the null hypothesis for that observation is rejected,
  given the choice of uncorrected P-threshold and method.
 -float- specifies that the critical P-values
  in the variables -gpuncor-, -critical- and -gpcor-
  will be saved as -float- variables (instead of -double- variables).
 -fast- is an option for programmers,
  specifying that -multproc- will take no action to restore the pre-existing data set
  if the user presses -break-.
 All other options are passed to -_multproc- to process each by-group.
*/

if "`fast'"=="" {;preserve;};

*
 Define temporary output variables if necessary,
 otherwise confirm validity of user-defined output variable names,
 and initialise output variables to missing
*;
foreach X of any rank gpuncor critical gpcor nhcred reject {;
  if "``X''"=="" {;tempvar `X';};
  else {;confirm new variable ``X'';};
};
qui {;
  gene long `rank'=.;
  gene double `gpuncor'=.;
  gene double `critical'=.;
  gene double `gpcor'=.;
  gene byte `nhcred'=.;
  gene byte `reject'=.;
};

*
 Call _multproc to do multiple test procedure for each by-group
*;
if !_by() {;local bypref="";};
else {;
  local bypref "by `_byvars' `_byrc0':";
};
`bypref' _multproc `if' `in' ,
  rank(`rank') gpuncor(`gpuncor') critical(`critical') gpcor(`gpcor')
  nhcred(`nhcred') reject(`reject')
  `options';
return add;

*
 Complete calculation of output variables if processing last by-group
*;
* Convert -double- P-values to -float- if specified *;
if ("`float'"!="") {;
  foreach X of var `gpuncor' `critical' `gpcor' {;
    qui recast float `X',force;
  };
};
* Compress to save space if possible *;
qui compress `rank' `gpuncor' `critical' `gpcor' `nhcred' `reject';

if "`fast'"=="" {;restore,not;};

end;

prog def _multproc,rclass byable(recall);
/*
  Do multiple test procedure for each by-group,
  assuming that the output variables are already -generate-d
  and now only need to be replaced in each by-group.
*/

syntax [if] [in] ,
  RAnk(varname) GPUncor(varname) CRitical(varname) GPCor(varname)
  NHcred(varname) REJect(varname)
  [ PValue(varname numeric) PUncor(string) PCor(string)
  MEthod(string)
  ];
/*
 -rank- is a variable generated to contain the ranks of the P-values
  (from lowest to highest, with ties sorted in original order).
 -gpuncor- is a variable generated to contain the uncorrected P-value threshold used.
 -critical- is a variable generated to contain critical P-value thresholds
  corresponding to the P-values in -pvalue-
  (for use in a one-step, step-up or step-down procedure).
 -gpcor- is a variable generated to contain, for all observations in each by-group,
  the overall corrected P-value threshold calculated for that by-group.
 -nhcred- is a variable generated to contain an indicator
  that the null hypothesis for that observation is credible,
  given the choice of uncorrected P-threshold and method.
 -reject- is a variable generated to contain an indicator
  that the null hypothesis for that observation is rejected,
  given the choice of uncorrected P-threshold and method.
 -pvalue- is the variable containing the P-values.
 -puncor- is the uncorrected P-value threshold, possibly specified in a variable,
  set to $S_level if absent or out of range [0,1].
 -pcor- is the corrected P-value threshold, possibly specified in a variable,
  set according to -method- option if absent or out of range [0,1]
 -method- specifies the method used to calculate corrected P-values
  and is overridden and set to userspecified if -pcor- is in range [0,1]
*/

*
 Default variable name for P-value
 (assumed to be from a -parmest- or -parmby- output data set)
*;
if "`pvalue'"=="" {;
  confirm numeric variable p;
  local pvalue "p";
};

*
 Select marked sample of P-values
 and count the P-values in -npvalue-
*;
local varlist `pvalue';
marksample touse;
qui count if `touse';
local npvalue=r(N);
if `npvalue'==0 {;error 2000;};

* Screen out invalid P-values in -pvalue- *;
cap assert (`pvalue'>=0)&(`pvalue'<=1) if `touse';
if _rc!=0 {;
  disp as error "Invalid P-values outside range 0<=P<=1 in P-value variable: `pvalue'";
  error 498;
};

*
 Calculate -puncor- and -pcor-
 (resetting if out of range [0,1])
 and store in scalars,
 overriding -method- if -pcor- is provided and in range [0,1]
*;
tempname puscal pcscal;
* Uncorrected P-value *;
cap confirm numeric variable `puncor';
local isvar=_rc==0;
cap confirm number `puncor';
local isnum=_rc==0;
cap confirm name `puncor';
local isname=_rc==0;
if "`puncor'"=="" {;
  scal `puscal'=.;
};
else if `isvar' {;
 qui summ `puncor' if `touse';
 scal `puscal'=r(min);
 if r(min)!=r(max) {;
   disp as error "puncor(`puncor') has multiple values";
   error 498;
 };
};
else if `isnum'|`isname' {;
  scal `puscal'=`puncor';
};
if (`puscal'<0)|(`puscal'>1) {;
  if !missing(`puscal') {;
    disp as error "Invalid puncor() value: " `puscal';
    error 498;
  };
  scal `puscal'=1-$S_level/100;
};
* Corrected P-value *;
cap confirm numeric variable `pcor';
local isvar=_rc==0;
cap confirm number `pcor';
local isnum=_rc==0;
cap confirm name `pcor';
local isname=_rc==0;
if "`pcor'"=="" {;
  scal `pcscal'=.;
};
else if `isvar' {;
 qui summ `pcor' if `touse';
 scal `pcscal'=r(min);
 if r(min)!=r(max) {;
   disp as error "pcor(`pcor') has multiple values";
   error 498;
 };
 local method "userspecified";
};
else if `isnum'|`isname' {;
  scal `pcscal'=`pcor';
 local method "userspecified";
};
if (`pcscal'<0)|(`pcscal'>1) {;
  if !missing(`pcscal') {;
    disp as error "Invalid pcor() value: " `pcscal';
    error 498;
  };
  scal `pcscal'=.;
  if lower("`method'")=="userspecified" {;
    local method="";
    disp "Note: pcor() not specified. Default method assumed.";
  };
};
local puncor=`puscal';local pcor=`pcscal';

*
 Correct case of -method- (substituting default if necessary)
*;
if "`method'"=="" {;local method "bonferroni";};
local method=lower("`method'");

*
 Carry out multiple testing procedure
*;

*
 Sort by ascending P-value (preserving pre-existing sort order in -seqnum-)
 and define P-value ranks, with ties in pre-existing order
*;
tempvar seqnum;
qui {;
  gene long `seqnum'=_n;
  compress `seqnum';
  sort `touse' `pvalue' `seqnum';
  by `touse':replace `rank'=_n if `touse';
};

*
 Generate critical values, null hypothesis credibility,
 and overall corrected P-value threshold
 by the multiple test procedure method specified in -method()-
*;
if inlist("`method'","userspecified","bonferroni","sidak") {;
  *
   One-step procedure is specified
  *;
  * Procedure-specific section for one-step procedures *;
  if "`method'"=="userspecified" {;
    qui replace `critical'=`pcscal' if `touse';
  };
  else if "`method'"=="bonferroni" {;
    qui replace `critical'=`puscal'/`npvalue' if `touse';
  };
  else if "`method'"=="sidak" {;
    tempvar inflevel;
    qui gene double `inflevel'=(1-`puscal')^(1/`npvalue') if `touse';
    qui replace `critical'=1-`inflevel' if `touse' & `inflevel'<1;
    qui replace `critical'=`puscal'/`npvalue' if `touse' & `inflevel'>=1;
    drop `inflevel';
  };
  * Common section for all one-step procedures *;
  qui {;
    replace `nhcred'=`pvalue'>`critical' if `touse';
    * Calculate corrected P-value threshold *;
    summ `critical' if `touse';
    scal `pcscal'=r(min);
  };
};
else if inlist("`method'","holm","holland","liu1","liu2") {;
  *
   Step-down procedure is specified
  *;
  * Procedure-specific section for step-down procedures *;
  if "`method'"=="holm" {;
    qui replace `critical'=`puscal'/(`npvalue'-`rank'+1) if `touse';
  };
  else if "`method'"=="holland" {;
    tempvar inflevel;
    qui gene double `inflevel'=(1-`puscal')^(1/(`npvalue'-`rank'+1)) if `touse';
    qui replace `critical'=1-`inflevel' if `touse' & `inflevel'<1;
    qui replace `critical'=`puscal'/(`npvalue'-`rank'+1) if `touse' & `inflevel'>=1;
    drop `inflevel';
  };
  else if "`method'"=="liu1" {;
    qui {;
      tempvar revrank;
      gene long `revrank'=`npvalue'-`rank'+1 if `touse';
      compress `revrank';
      replace `critical' = 1 - ( 1 - min( 1 , (`npvalue'/`revrank')*`puscal') )^(1/`revrank')
       if `touse';
      drop `revrank';
    };
  };
  else if "`method'"=="liu2" {;
    qui {;
      tempvar revrank;
      gene long `revrank'=`npvalue'-`rank'+1 if `touse';
      compress `revrank';
      replace `critical' = min( 1 , (`npvalue'/(`revrank'*`revrank'))*`puscal' )
       if `touse';
      drop `revrank';
    };
  };
  * Common section for all step-down procedures *;
  qui {;
    replace `nhcred'=sum(`pvalue'<=`critical')<`rank' if `touse';
    * Calculate corrected P-value threshold *;
    count if `touse'&`nhcred';
    if r(N)==0 {;
      summ `critical' if `touse';
      scal `pcscal'=r(max);
    };
    else {;
      summ `critical' if `touse'&`nhcred';
      scal `pcscal'=r(min);
    };
  };
};
else if inlist("`method'","hochberg","rom")|inlist("`method'","simes","yekutieli","krieger") {;
  *
   Step-up procedure is specified
  *;
  * Procedure-specific section for step-up procedures *;
  if "`method'"=="hochberg" {;
    qui replace `critical'=`puscal'/(`npvalue'-`rank'+1) if `touse';
  };
  else if "`method'"=="rom" {;
    qui{;
      tempvar tmptuse tmprank tmpterm;
      *
       -tmptuse- is temporary to-use indicator
       -tmprank- is temporary rank
       -tmpterm- is temporary variable containing terms to be added
        when calculating c_{1:n} from c_{2:n} to c_{n:n}
      *;
      gene byte `tmptuse'=.;
      gene long `tmprank'=.;
      gene double `tmpterm'=.;
      replace `critical'=`puscal' if `touse'&(`rank'==`npvalue');
      local npvm1=`npvalue'-1;
      forv rankcur=`npvm1'(-1)1 {;
        local tmpnpv=`npvalue'-`rankcur'+1;
        replace `tmptuse'=`touse'&(`rank'>=`rankcur');
        replace `tmprank'=`rank'-`rankcur'+1 if `tmptuse';
        replace `tmpterm'=0 if `tmptuse';
        replace `tmpterm'=`tmpterm'+`puscal'^(`tmprank'-1) if `tmptuse'&(`tmprank'>=2)&(`tmprank'<=`tmpnpv');
        replace `tmpterm'=`tmpterm'
          - exp(lnfactorial(`tmpnpv')-lnfactorial(`tmprank')-lnfactorial(`tmpnpv'-`tmprank'))*`critical'^`tmprank'
          if `tmptuse'&(`tmprank'>=2)&(`tmprank'<=`tmpnpv'-1);
        summ `tmpterm' if `tmptuse';
        replace `critical'=r(mean) if `tmptuse'&(`tmprank'==1);
      };
    };
  };
  else if "`method'"=="simes" {;
    qui replace `critical'=`puscal'*`rank'/`npvalue' if `touse';
  };
  else if "`method'"=="yekutieli" {;
    qui {;
      tempvar invrank;tempname suminvr;
      gene double `invrank'=1/`rank' if `touse';
      summ `invrank' if `touse';
      scal `suminvr'=r(sum);
      replace `critical'=`puscal'*`rank'/`npvalue' if `touse';
      replace `critical'=`critical'/`suminvr' if `touse';
      drop `invrank';
      scal drop `suminvr';
    };
  };
  else if "`method'"=="krieger" {;
    qui {;
      tempname pprime;
      scal `pprime'=`puscal'/(1+`puscal');
      replace `critical'=`pprime'*`rank'/`npvalue' if `touse';
      gsort +`touse' -`pvalue' -`seqnum';
      replace `nhcred'=sum(`pvalue'<=`critical')==0 if `touse';
      sort `touse' `pvalue' `seqnum';
      count if `touse'&`nhcred';
      local mzero=r(N);
      if (`mzero'>0)&(`mzero'<`npvalue') {;
        replace `critical'=`pprime'*`rank'/`mzero' if `touse';
      };
    };
  };
  * Common section for all step-up procedures *;
  qui {;
    gsort +`touse' -`pvalue' -`seqnum';
    replace `nhcred'=sum(`pvalue'<=`critical')==0 if `touse';
    sort `touse' `pvalue' `seqnum';
    * Calculate corrected P-value threshold *;
    count if `touse'&(!`nhcred');
    if r(N)==0 {;
      summ `critical' if `touse';
      scal `pcscal'=r(min);
    };
    else {;
      summ `critical' if `touse'&(!`nhcred');
      scal `pcscal'=r(max);
    };
  };
};
else {;
  *
   Unrecognised procedure is specified
  *;
  disp as error `"Unrecognised method(`method')"';
  error 498;
};

*
 Assign uncorrected and corrected overall critical P-values
 to variables -gpuncor- and -gpcor- respectively
 and assign rejection status to variable -reject-
*;
qui{;
  replace `gpuncor'=`puscal' if `touse';
  replace `gpcor'=`pcscal' if `touse';
  replace `reject'=!`nhcred' if `touse';
};

* Label output variables (specifying method) *;
lab var `rank' "P-value rank";
lab var `gpuncor' "Uncorrected overall critical P by method(`method')";
lab var `critical' "Critical P by method(`method')";
lab var `gpcor' "Corrected overall critical P by method(`method')";
lab var `nhcred' "H0 credible by method(`method')";
lab var `reject' "H0 rejected by method(`method')";

* Sort back to original order *;
sort `seqnum';

* Test that -pcscal- has the required properties *;
cap assert `nhcred'==(`pvalue'>`pcscal') if `touse';
if _rc!=0 {;
  disp as text "Corrected overall critical P-value (" `pcscal'
   ") does not separate credible and incredible null hypotheses";
};

* Count rejected P-values *;
qui count if `touse'&`reject';
tempname nreject;
scal `nreject'=r(N);

* Output uncorrected and corrected overall critical P-value thresholds *;
disp _n as text "Method: " as result "`method'"
 _n as text "Uncorrected overall critical P-value: " as result `puscal'
 _n as text "Number of P-values: " as result `npvalue'
 _n as text "Corrected overall critical P-value: " as result `pcscal'
 _n as text "Number of rejected P-values: " as result `nreject';

* Save results to be returned *;
return scalar puncor=`puscal';
return scalar npvalue=`npvalue';
return scalar pcor=`pcscal';
return scalar nreject=`nreject';
return local method "`method'";

end;
