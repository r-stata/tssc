#delim ;
prog def cprd_common_dosages;
version 13.0;
*
 Create dataset common_dosages with 1 obs per common dosage.
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

*
 Add variable labels
*;
* New format dosage ID and dosage text *;
cap lab var dosageid "Dosage Identifier";
cap lab var dosage_text "Anonymised dosage text associated with dosageid";
* Old format dosage text and textual dose *;
cap lab var textid "Identifier allowing freetext dosage on therapy events to be retrieved";
cap lab var text "Anonymised textual dose associated with the therapy textid";
* Other variables *;
cap lab var daily_dose "Numerical equivalent of the given textual dose given in a per day format";
cap lab var dose_number "Amount in each dose";
cap lab var dose_unit "Unit of each dose";
cap lab var dose_frequency "How often a dose is taken in a day";
cap lab var dose_interval "Number in days that the dose is over, e.g. 1 every 2 weeks = 14, 4 a day = 0.25";
cap lab var choice_of_dose "Indicates if there is a choice the user can make as to how much they can take";
cap lab var dose_max_average "If dose was averaged, value = 2, if maximum was taken, value = 1, otherwise 0";
cap lab var change_dose "If an option between 2 parts of the dose was available, indicates the part used";
cap lab var dose_duration "If specified, the number of days the prescription is for";

*
 Convert string variables to numeric if necessary
*;
foreach X in daily_dose dose_number dose_frequency dose_interval choice_of_dose dose_max_average change_dose dose_duration {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Identify dose ID variable
*;
cap conf var dosageid;
if _rc {;
  local idvar "textid";
};
else {;
  local idvar "dosageid";
};

*
 Remove common dosages with missing ID variable
 (after justifying this)
*;
qui count if missing(`idvar');
disp as text "Observations with missing `idvar': " as result r(N)
  _n as text "List of observations with missing `idvar' (to be discarded):";
list if missing(`idvar'), abbr(32);
drop if missing(`idvar');
* ID variable should now be non-missing *;

* Key and save dataset *;
keyby `idvar', fast;
desc, fu;

end;
