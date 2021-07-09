#delim ;
prog def cprd_packtype;
version 13.0;
*
 Create dataset packtype with 1 obs per pack size or type code.
 Add-on packages required:
 keyby, chardef
*!Author: Roger Newson
*!Date: 29 September 2017
*;

syntax using [ , CLEAR ];

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) `clear';
desc, fu;

* Add variable labels *;
cap lab var packtype "Pack Type";
cap lab var packtype_desc "Pack size or type of the prescribed product";

*
 Convert string variables to numeric if necessary
*;
foreach X in packtype {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Remove pack types with missing packtype
 (after justifying this)
*;
qui count if missing(packtype);
disp as text "Observations with missing packtype: " as result r(N)
  _n as text "List of observations with missing packtype (to be discarded):";
list if missing(packtype), abbr(32);
drop if missing(packtype);
* packtype should now be non-missing *;

* Key and save dataset *;
keyby packtype, fast;
desc, fu;

end;
