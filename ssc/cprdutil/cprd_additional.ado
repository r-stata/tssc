#delim ;
prog def cprd_additional;
version 13.0;
*
 Create datasets additional
 with 1 obs per set of additional clinical details.
 Add-on packages needed:
 keyby, chardef
*!Author: Roger Newson
*!Date: 29 September 2017
*;

syntax using [ , CLEAR DOfile(string) noKEY ];
*
 clear specifies that existing data will be cleared.
 dofile specifies name of do-file setting the value labels.
 nokey specifies that dataset should not be keyed.
*;

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) `clear';
desc, fu;

*
 Add variable labels
*;
cap lab var patid "Patient Identifier";
cap lab var enttype "Entity Type";
cap lab var adid "Additional Details Identifier";
cap lab var data1 "Data 1 (Depends on Entity Type)";
cap lab var data2 "Data 2 (Depends on Entity Type)";
cap lab var data3 "Data 3 (Depends on Entity Type)";
cap lab var data4 "Data 4 (Depends on Entity Type)";
cap lab var data5 "Data 5 (Depends on Entity Type)";
cap lab var data6 "Data 6 (Depends on Entity Type)";
cap lab var data7 "Data 7 (Depends on Entity Type)";
cap lab var data8 "Data 8 (Depends on Entity Type)";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid enttype adid {;
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
  keyby patid adid, fast;
};

* Describe dataset *;
desc, fu;

end;
