#delim ;
program predbasesurv, sortpreserve;
version 10.0;
/*
 Compute a variable after stcox
 containing the baseline probability of survival to a user-supplied time
 and/or another variable
 containing the individual probability.of survival to the same time.
*!Author: Roger Newson
*!Date: 29 May 2020
*/

syntax [if] [in], Time(real) [ Generate(name) GSurv(name) TYpe(string) ];
/*
 time() specifies the survival time
   for which the baseline survival probability will be calculated.
 generate() specifies the name of the new baseline survival variable to be generated.
 gsurv() specifies the name of the new individual survival variable to be generated. 
 type() specifies the type of the generated variablse.
*/

*
 Set default output type if necessary
 and check that it is a valid output type
*;
if `"`type'"'=="" {;
  local type "float";
};
if !inlist(`"`type'"',"byte","int","long","float","double") {;
  disp as error `"Illegal type(`type')"';
  error 498;
};

*
 Check that at least 1 generated variable is specified
 and thaat no specified survival variables already exist.
*;
if trim("`generate' `gsurv'")=="" {;
  disp as error "You must specify either generate() or gsurv()";
  error 498;
};
conf new var `generate' `gsurv';

*
 Check that appropriate estimation results are present
*;
if `"`e(cmd2)'"'!="stcox" {;
  disp as error "predbasesurv should only be used after stcox";
  error 498;
};

*
 Check that _st, _t and _t0 are present as numeric variables
*;
cap confirm numeric var _st _t _t0 _d;
if _rc {;
  disp as error "Data not st";
  error 119;
};

*
 Mark sample
*;
marksample touse, novarlist;

*
 Compute bseline survival variable
 and set to missing if time is above the input survival time
*;
tempvar bs_temp gen_temp surv_temp;
qui {;
  predict double `bs_temp' if `touse', basesurv;
  replace `bs_temp'=. if `touse' & _t>`time';
};

*
 Check for strata
 and assign local macro bystrata if present
*;
local strata `"`e(strata)'"';
if `"`strata'"'!="" {;
  local bystrata `"by `strata':"';
  qui sort `strata', stable;
};

*
 Assign generated variables
*;
qui {;
  `bystrata' egen double `gen_temp'=min(`bs_temp') if `touse';
  replace `gen_temp'=min(`gen_temp',1) if `touse';
  predict double `surv_temp' if `touse', hr;
  replace `surv_temp'=`gen_temp'^`surv_temp' if `touse';
  recast `type' `gen_temp', force;
  lab var `gen_temp'  "Baseline S(`time')";
  recast `type' `surv_temp', force;
  lab var `surv_temp' "S(`time')";
};
if "`generate'"!="" {;
  rename `gen_temp' `generate';
};
if "`gsurv'"!="" {;
  rename `surv_temp' `gsurv';
};

end;
