#delim ;
prog def cprdhesop_clinical;
version 13.0;
*
 Create dataset with 1 obs per HES/OP clinical event.
 Add-on packages required:
 keyby, chardef.
*!Author: Roger Newson
*!Date: 29 January 2019
*;

syntax using [ , CLEAR noKEY DELIMiters(passthru) ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 nokey specifies that the new dataset will not be keyed by patid, spno, epikey and d_order.
 delimiters() is passed through to import delimited.
*/

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) `delimiters' `clear';
desc, fu;

*
 Label variables
*;
cap lab var patid "Patient ID";
cap lab var attendkey "Attendance record key";
cap lab var diag_01 "Primary diagnosis";
forv i1=2(1)12 {;
  local i1form=string(`i1',"%02.0f");
  cap lab var diag_`i1form' "Secondary diagnosis `i1form'";
};
cap lab var opertn_01 "Main (i.e. most resource intensive) operation";
forv i1=2(1)24 {;
  local i1form=string(`i1',"%02.0f");
  cap lab var opertn_`i1form' "Secondary operation/procedure `i1form'";
};
cap lab var operstat "Operation status code";
cap lab var tretspef "Treatment speciality";
cap lab var mainspef "Main speciality";
cap lab var hes_yr "HES year (fiscal year beginning)";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid attendkey hes_yr {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Key dataset if required
*;
if "`key'"!="nokey" {;
  keyby patid attendkey, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
