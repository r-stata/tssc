#delim ;
prog def cprdhesae_investigation;
version 13.0;
*
 Create dataset with 1 obs per HES A&E investigation record.
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
cap lab var aekey "A&E attendance record key";
cap lab var invest "A&E investigation code (6 characters)";
cap lab var invest2 "A&E investigation code (2 characters)";
cap lab var invest_order "Ordering of investigation at attendance";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid aekey invest_order {;
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
  keyby patid aekey invest_order, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
