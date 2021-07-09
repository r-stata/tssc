#delim ;
prog def cprd_bnfcodes;
version 13.0;
*
 Create dataset bnfcodes with 1 obs per BNF code.
 Add-on packages required:
 keyby, chardef
*!Author: Roger Newson
*! Date: 29 September 2017
*;

syntax using [ , CLEAR ];

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) `clear';
desc, fu;

* Add variable labels *;
cap lab var bnfcode "BNF Code";
cap lab var bnf "BNF code representing the chapter and section for the prescribed product";

*
 Convert string variables to numeric if necessary
*;
foreach X in bnfcode {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Remove BNF codes with missing bnfcode
 (after justifying this)
*;
qui count if missing(bnfcode);
disp as text "Observations with missing bnfcode: " as result r(N)
  _n as text "List of observations with missing bnfcode (to be discarded):";
list if missing(bnfcode), abbr(32);
drop if missing(bnfcode);
* bnfcode should now be non-missing *;

* Key and save dataset *;
keyby bnfcode, fast;
desc, fu;

end;
