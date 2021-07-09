#delim ;
prog def cprdlink_linkage_eligibility;
version 13.0;
*
 Create dataset with 1 obs per CPRD patient
 and data on eligibility for linkage with other datasets.
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
cap lab var patid "Patient ID";
cap lab var pracid "Practice ID";
cap lab var linkdate "Patient Linkage Date";
cap lab var hes_e "Eligibility for linkage to HES data";
cap lab var death_e "Eligibility for linkage to ONS Death data";
cap lab var cr_e "Eligibility for linkage to Cancer Registry";
cap lab var minap_e "Eligibility for linkage to MINAP Registry";
cap lab var lsoa_e "Eligibility for linkage to patient-level LSOA data";
cap lab var mh_e "Eligibility for linkage to Mental Health data";

*
 Convert string variables to numeric if necessary
*;
cap unab undevars: *_e;
foreach X in patid pracid `undevars' {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Add numeric date variables
*;
foreach X in linkdate {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
lab var linkdate_n "Patient linkage date";

*
 Key dataset if requested
*;
if "`key'"!="nokey" {;
  keyby patid, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
