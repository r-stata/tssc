#delim ;
prog def cprd_browser_medical;
version 13.0;
*
 Create dataset with 1 obs per medical code
 and data on CPRD browser output.
 Add-on packages required:
 keyby, chardef
*!Author: Roger Newson
*!Date: 12 October 2017
*;

syntax using [ , CLEAR noKEY ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 nokey specifies that the new dataset will not be keyed by prodcode.
*/

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) `clear';
cap lab var medcode "Medical Code";
* Old-format names *;
cap lab var clinicalevents "Clinical Events";
cap lab var referralevents "Referral Events";
cap lab var testevents "Test Events";
cap lab var immunisationevents "Immunisation Events";
cap lab var readcode "Read Code";
cap lab var readterm "Read Term";
cap lab var databasebuild "Database Build";
* New-format names *;
cap lab var read_code "Read Code";
cap lab var clinical_events "Clinical Events";
cap lab var immunisations "Immunisation Events";
cap lab var referrals "Referral Events";
cap lab var tests "Test Events";
cap lab var read_term "Read Term";
cap lab var database_build "Database Build";
* Describe dayaset *;
desc, fu;

*
 Convert string variables to numeric if necessary
*;
foreach X in medcode clinicalevents referralevents testevents immunisationevents clinical_events immunisations referrals tests {;
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

*
 Add numeric database build variable
*;
foreach X in databasebuild database_build {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=monthly(`X',"MY",2099);
    compress `X'_n;
    format `X'_n %tmCCYY/NN;
    lab var `X'_n "Database build (monthly date)";
  };
};

*
 Key dataset if requested
*;
if "`key'"!="nokey" {;
  keyby medcode;
};

*
 Describe dataset
*;
desc, fu;
char list;

end;
