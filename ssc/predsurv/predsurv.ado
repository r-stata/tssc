#delim ;
program predsurv;
version 10.0;
/*
 Compute a variable after streg
 containing the probability of survival to a user-supplied time.
*!Author: Roger Newson
*!Date: 25 March 2020
*/

syntax [if] [in], Time(real) Generate(name) [ TYpe(string) CUMinc FAST ];
/*
 time() specifies the survival time
   for which the survival probability will be calculated.
 generate() specifies the name of the new variable to be generated.
 type() specifies the type of the generated variable.
 cuminc specifies that the generated variable will be a predicted cumulative incidence
   instead of a predicted survival probability.
 cuminc specifies that the generated variable
 fast specifies that no extra work shall be done to restore original data
   if the user presses Break.
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
 Check that appropriate estimation results are present
*;
if `"`e(cmd2)'"'!="streg" {;
  disp as error "predsurv should only be used after streg";
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
 Mark and count sample
*;
marksample touse, novarlist;

*
 Preserve if requested
*;
if "`fast'"=="" {;
  preserve;
};

*
 Compute output variable
*;
tempvar t_temp s_temp;
local ttype: type _t;
qui {;
  clonevar `t_temp'=_t;
  replace _t=`time' if `touse';
  predict `type' `s_temp' if `touse', surv;
  replace `s_temp'=1 if `touse' & !missing(_t0) & !missing(`time') & _t0>=`time';
  replace `s_temp'=1-`s_temp' if "`cuminc'"!="";
  replace _t=`t_temp';
  recast `ttype' _t;
  if "`cuminc'"=="" {;
    lab var `s_temp' "S(`time'|_t0)";
  };
  else {;
   lab var `s_temp' "1-S(`time'|_t0)";  
  };
  rename `s_temp' `generate';
};

*
 Restore if requested
*;
if "`fast'"=="" {;
  restore, not;
};

end;
