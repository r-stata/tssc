#delim ;
prog def cprdhes_procedures_epi;
version 13.0;
*
 Create dataset with 1 obs per OPCS procedure per episode
 and data on OPCS procedure attributes.
 Add-on packages required:
 keyby, chardef
*!Author: Roger Newson
*!Date: 11 January 2019
*;

syntax using [ , CLEAR noKEY DELIMiters(passthru) ENCoding(string) ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 nokey specifies that the new dataset will not be keyed by patid, spno, epikey and d_order.
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
cap lab var epikey "Episode key";
cap lab var admidate "Date of admission";
cap lab var epistart "Date of start of episode";
cap lab var epiend "Date of end of episode";
cap lab var discharged "Date of discharge";
cap lab var opcs "OPCS 4 procedure code";
cap lab var evdate "Date of operation or procedure";
cap lab var p_order "Order of OPCS code within episode";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid spno epikey p_order {;
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
foreach X in admidate epistart epiend discharged evdate {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
cap lab var admidate_n "Admission date";
cap lab var epistart_n "Episode start date";
cap lab var epiend_n "Episode end date";
cap lab var discharged_n "Discharge date";
cap lab var evdate_n "Operation/procedure date";

*
 Key dataset if requested
*;
if "`key'"!="nokey" {;
  keyby patid spno epikey p_order, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
