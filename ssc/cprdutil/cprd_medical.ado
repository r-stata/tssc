#delim ;
prog def cprd_medical;
version 13.0;
*
 Create dataset medical with 1 obs per medical code.
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
cap lab var medcode "Medical Code";
cap lab var readcode "Read Code";
cap lab var desc "Description of the medical term";

*
 Convert string variables to numeric if necessary
*;
foreach X in medcode {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Remove entities with missing medical code
 (after justifying this)
*;
qui count if missing(medcode);
disp as text "Observations with missing medcode: " as result r(N)
  _n as text "List of observations with missing medcode (to be discarded):";
list if missing(medcode), abbr(32);
drop if missing(medcode);
* medcode should now be non-missing *;

* Key and save dataset *;
keyby medcode, fast;
desc, fu;

end;
