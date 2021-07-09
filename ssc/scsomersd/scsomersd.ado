#delim ;
prog def scsomersd, eclass byable(onecall) sortpreserve;
version 16.0;
/*
 Use somersd
 for a scenario comparison enabled by expgen.
*!Author: Roger Newson
*!Date: 16 April 2020
*/

syntax anything(name=ylist) [if] [in] [fweight iweight pweight /] [ , 
  NYVar(name) NWEIght(name) NCFWeight(name) NOBS(name) NSCEn(name) SWEight(string asis)
  CFWeight(string) CLuster(varname) fast *
  ];
/*
 nyvar() specifies the name of the temporary Y-variable for the analysis,
 nweight() specifies the name of the temporary weight variable for the analysis.
 ncfweight() specifies the name of the temporary cluster frequency weight variable
  for the analysis.
 nobs() specifies the name of the temporary observation variable for the analysis.
 nscen() specifies name of scenario indicator variable for the analysis.
 sweight() specifies Scenario 1 weight expression.
 cluster() specifies a cluster variable,
   to be replaced by the nobs() variable if absent.
 fast specifies that no work will be done to restore the original dataset
   if the user presses Break.
 Other options are to be passed on.
*/

*
 Set defaults
*;
if "`weight'"=="" {;local weight "fweight";};
if `"`exp'"'=="" {;local exp 1;};
if `"`sweight'"'=="" {;local sweight `"`exp'"';};
if "`nyvar'"=="" {;local nyvar "_yvar";};
if "`nweight'"=="" {;local nweight "_weight";};
if "`ncfweight'"=="" {;local ncfweight "_cfweight";};
if "`nobs'"=="" {;local nobs "_obs";};
if "`cluster'"=="" {;local cluster "`nobs'";};
local ny: word count `ylist';
if !inlist(`ny',1,2) {;
  disp as error "ylist may only contain 1 or 2 y-elements";
  error 498;
};
foreach Y in `ylist' {;
  cap conf numeric var `Y';
  if _rc {;
    cap conf num `Y';
    if _rc {;
      disp as error "y-elements must be numeric variables or numbers";
      error 498;
    };
  };
};
local y0: word 1 of `ylist';
local y1: word 2 of `ylist';
if "`y1'"=="" {;
  local y1 "`y0'";
};

*
 Evaluate bybyvars macro and weight expressions
*;
if "`_byvars'"!="" {;
  local bybyvars "by `_byvars' `_byrc0':";
};
tempvar wexpval0 wexpval1 cfwexpval;
* Scenario 0 ordinary weights *;
if "`weight'"=="fweight" {;
  qui `bybyvars' gene long `wexpval0'=`exp';
};
else {;
  qui `bybyvars' gene double `wexpval0'=`exp';
};
* Scenario 1 ordinary weights *;
if `"`sweight'"'=="" {;
  qui `bybyvars' gene byte `wexpval1'=`exp';
};
else if "`weight'"=="fweight" {;
  qui `bybyvars' gene long `wexpval1'=`sweight';
};
else {;
  qui `bybyvars' gene double `wexpval1'=`sweight';
};
* Cluster frequency weights *;
if `"`cfweight'"'=="" {;
  qui `bybyvars' gene byte `cfwexpval'=1;
};
else {;
  cap qui `bybyvars' gene long `cfwexpval'=`cfweight';
  if _rc!=0 {;
    disp as error "Invalid cfweight()";
    error 498;
  };
};
* Compress temporary weight value variables *;
qui compress `wexpval0' `wexpval1' `cfwexpval';

*
 Mark sample for use
*;
marksample touse, zeroweight;
markout `touse' `wexpval0' `wexpval1' `cfwexpval';
foreach Y in `y0' `y1' {;
  qui replace `touse'=0 if missing(`Y');
};

if "`fast'"=="" {;preserve;};

*
 Store changed indicator and sorted-by list
*;
local changed=c(changed);
local soby: sortedby;

*
 Create dataset with 1 obs per scenario per old observation
*;
tempvar scenseq;
expgen =2, oldseq(`nobs') copyseq(`scenseq') sortedby(group);
qui {;
  lab var `nobs' "Observation sequence number";
  gene double `nweight'=.;
  replace `nweight'=(`exp') if `touse' & `scenseq'==1;
  replace `nweight'=(`sweight') if `touse' & `scenseq'==2;
  compress `nweight';
  lab var `nweight' "Value of weight expression";
  gene double `ncfweight'=`cfwexpval' if `touse';
  compress `ncfweight';
  lab var `ncfweight' "Value of cfweight() expression";
  gene double `nyvar'=.;
  replace `nyvar'=(`y0') if `touse' & `scenseq'==1;
  replace `nyvar'=(`y1') if `touse' & `scenseq'==2;
  compress `nyvar';
  lab var `nyvar' "Y-variable";
};

*
 Call somersd.
 THIS PART OF THE PROGRAM IS SPECIFIC TO scsomersd
 AND IS DIFFERENT FROM THE CORRESPONDING PARTS OF THE OTHER MODULES.
*;
if "`nscen'"=="" {;local nscen "_scen0";};
qui gene byte `nscen'=2-`scenseq';
lab var `nscen' "Scenario 0 indicator";
`bybyvars' somersd `nscen' `nyvar' [`weight'=`nweight'] , cluster(`cluster') cfweight(`ncfweight') funtype(vonmises) `options';

*
 Drop Scenario 1 observations
 and temporary variables with non-temporary names
 and restore changed indicator
 to its value before the temporary changes
*;
qui keep if `scenseq'==1;
drop `nobs' `nscen' `nweight' `ncfweight' `nyvar';
mata: st_updata(`changed');

if "`fast'"=="" {;restore, not;};

end;
