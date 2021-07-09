#delim ;
prog def cprdhesae_hrg;
version 13.0;
*
 Create dataset with 1 obs per HES A&E HRG record.
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
cap lab var domproc "Dominant procedure";
cap lab var hrgnhs "Trust derived HRG value";
cap lab var hrgnhsvn "Version number of trust derived HRG";
cap lab var sushrg "SUSgenerated  HRG code";
cap lab var sushrgvers "SUS generated HRG code version number";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid aekey sushrgvers {;
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
  keyby patid aekey, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
