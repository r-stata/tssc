#delim ;
prog def cprdlsoa_patient_index;
version 13.0;
*
 Create dataset with 1 obs per CPRD patient
 and data on LSOA deprivation index linkage information about the patient.
 Add-on packages required:
 keyby, chardef
*!Author: Roger Newson
*!Date: 14 January 2019
*;

syntax using [ , CLEAR noKEY DELIMiters(passthru) INdex(string) YEar(numlist integer min=1 max=1 >=0) ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 nokey specifies that the new dataset will not be keyed by patid, spno, epikey and d_order.
 delimiters() is passed through to import delimited.
 index() specifies the index to be used.
 year() specifies the year of the index to be used.
*/

*
 Check index and year, setting defaults if necessary
*;
local index=lower(`"`index'"');
if "`index'"=="" {;
  local index "imd";
};
if "`year'"=="" {;
  local year 2004;
};

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) `delimiters' `clear';
desc, fu;

*
 Label variables
*;
cap lab var patid "Patient ID";
cap lab var pracid "Practice ID";
if `"`index'"'=="imd" {;
  cap lab var `index'`year'_5 "IMD `year' quintile";
  cap lab var `index'`year'_10 "IMD `year' decile";
  cap lab var `index'`year'_20 "IMD `year' twentile";
};
else if `"`index'"'=="townsend" {;
  cap lab var `index'`year'_5 "Townsend `year' quintile";
  cap lab var `index'`year'_10 "Townsend `year' decile";
  cap lab var `index'`year'_20 "Townsend `year' twentile";
};
else {;
  cap lab var `index'`year'_5 "`index' `year' quintile";
  cap lab var `index'`year'_10 "`index' `year' decile";
  cap lab var `index'`year'_20 "`index' `year' twentile";
};

*
 Convert string variables to numeric if necessary
*;
foreach X in patid pracid `index'`year'_5 `index'`year'_10 `index'`year'_20 {;
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
  keyby patid, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
