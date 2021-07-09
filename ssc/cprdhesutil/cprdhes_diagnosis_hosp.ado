#delim ;
prog def cprdhes_diagnosis_hosp;
version 13.0;
*
 Create dataset with 1 obs per unique diagnosis per hospital spell
 and data on diagnosis attributes.
 Add-on packages required:
 chardef
*!Author: Roger Newson
*!Date: 29 January 2019
*;

syntax using [ , CLEAR DELIMiters(passthru) ENCoding(string) ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 delimiters() is passed through to import delimited.
 encoding() is passed through to import delimited as a charset() option.
*/

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) charset(`"`encoding'"') `delimiters' `clear';
desc, fu;

* Label variables *;
cap lab var patid "Patient ID";
cap lab var spno "Spell number";
cap lab var admidate "Date of admission";
cap lab var discharged "Date of discharge";
cap lab var icd "ICD10 diagnosis code";
cap lab var icdx "5th/6th characters of the ICD code (if available)";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid spno {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Add numeric date variables computed from string dates
*;
foreach X in admidate discharged {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
cap lab var admidate_n "Admission date";
cap lab var discharged_n "Discharge date";

*
 Describe dataset
*;
desc, fu;

end;
