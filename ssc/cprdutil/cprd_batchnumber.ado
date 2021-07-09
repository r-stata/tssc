#delim ;
prog def cprd_batchnumber;
version 13.0;

*
 Create dataset batchnumber with 1 obs per immunisation batch number.
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
cap lab var batch "Batch";
cap lab var batch_number "Immunisation batch number";

*
 Convert string variables to numeric if necessary
*;
foreach X in batch {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Remove entities with missing batch
 (after justifying this)
*;
qui count if missing(batch);
disp as text "Observations with missing batch: " as result r(N)
  _n as text "List of observations with missing batch (to be discarded):";
list if missing(batch), abbr(32);
drop if missing(batch);
* batch should now be non-missing *;

* Key and save dataset *;
keyby batch, fast;
desc, fu;

end;
