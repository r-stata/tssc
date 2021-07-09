#delim ;
prog def cprd_scoremethod;
version 13.0;
*
 Create dataset scoremethod with 1 obs per scoring methodology code.
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
lab var code "Coded value associated with the scoring methodology used";
lab var scoringmethod "Scoring methodology";

*
 Convert string variables to numeric if necessary
*;
foreach X in code {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Remove score methods with missing code
 (after justifying this)
*;
qui count if missing(code);
disp as text "Observations with missing code: " as result r(N)
  _n as text "List of observations with missing code (to be discarded):";
list if missing(code), abbr(32);
drop if missing(code);
* code should now be non-missing *;

* Key and save dataset *;
keyby code, fast;
desc, fu;

end;
