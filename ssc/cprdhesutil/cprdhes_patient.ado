#delim ;
prog def cprdhes_patient;
version 13.0;
*
 Create dataset with 1 obs per CPRD patient
 and data on HES information about the patient.
 Add-on packages required:
 keyby, chardef, lablist
*!Author: Roger Newson
*!Date: 11 October 2019
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
cap lab var pracid "Practice ID";
cap lab var ethnos "Patient ethnicity derived from HES records";
cap lab var gen_ethnicity "Patient ethnicity derived from all HES data";
cap lab var gen_hesid "Generated unique identifier for patient in HES";
cap lab var n_patid_hes "Number of CPRD patients assigned the same gen_hesid";
cap lab var match_rank "Matching quality rank between HES and CPRD";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid pracid gen_hesid n_patid_hes match_rank  {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Label values
*;
lab def match_rank
  1 "Exact match on NHS number, date of birth, sex and post code"
  2 "Exact match on NHS number, date of birth and sex"
  3 "Exact match on NHS number, partial match on date of birth, exact match on sex and post code"
  4 "Exact match on NHS number, partial match on date of birth, exact match on sex"
  5 "Exact match on NHS number and post code"
  , modify;
cap lab val match_rank match_rank;
foreach X in match_rank {;
  cap conf numeric var `X';
  if !_rc {;
    lablist `X', var noun;
  };
};

*
 Key dataset if required
*;
if "`key'"!="nokey" {;
  keyby patid, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
