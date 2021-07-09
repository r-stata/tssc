#delim ;
prog def cprdlink_linked_practices;
version 13.0;
*
 Create dataset with 1 obs per linked practice.
  Add-on packages required:
 keyby, chardef
*!Author: Roger Newson
*!Date: 10 December 2018
*;

syntax using [ , CLEAR noKEY ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 nokey specifies that the new dataset will not be keyed by patid.
*/

*
 Input data
*;
import delimited `using', varnames(1) delim(tab) stringcols(_all) `clear';
desc, fu;

* Add variable labels *;
cap lab var pracid "Practice ID";

*
 Convert string variables to numeric if necessary
*;
foreach X in pracid {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Key dataset if requested
*;
if "`key'"!="nokey" {;
  keyby pracid, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
