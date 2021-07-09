#delim ;
prog def cprdons_death_patient;
version 13.0;
*
 Create dataset with 1 obs per dead CPRD patient
 and data on ONS death information about the patient.
 Add-on packages required:
 keyby, chardef, lablist
*!Author: Roger Newson
*!Date: 25 January 2019
*;

syntax using [ , CLEAR noKEY DELIMiters(passthru) ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 nokey specifies that the new dataset will not be keyed by patid, spno, epikey and d_order.
 delimiters() is passed through to import delimited.
*/

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) `delimiters' `clear';
desc, fu;

*
 Label variables
*;
cap lab var patid "Patient ID";
cap lab var pracid "Practice ID";
cap lab var gen_death_id "Unique key assigned to patient in death registration data";
cap lab var n_patid_death "Number of CPRD GOLD patients assigned the same gen_death_id";
cap lab var match_rank "Matching quality rank between ONS and CPRD GOLD";
cap lab var dor "Date of registration of death";
cap lab var dod "Date of death";
cap lab var dod_partial "Partial date of death";
cap lab var nhs_indicator "NHS establishment indicator for place of death";
cap lab var pod_category "Category indicator for place of death";
lab var cause "Underlying cause of death";
cap unab causevars: cause? cause??;
if !_rc {;
  foreach X of var `causevars' {;
    local causevid=subinstr("`X'","cause","",1);
    cap lab var `X' "Non-neonatal cause of death `causevid'";
  };
};
cap unab nncausevars: cause_neonatal?;
if !_rc {;
  foreach X of var `nncausevars' {;
    local nncausevid=subinstr("`X'","cause_neonatal","",1);
    cap lab var `X' "Neonatal cause of death `nncausevid'";
  };
};

*
 Convert string variables to numeric if necessary
*;
foreach X in patid pracid gen_death_id n_patid_death match_rank nhs_indicator {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Label values if necessary
*;
lab def match_rank
  1 "Exact match on NHS number, date of birth, sex and post code"
  2 "Exact match on NHS number, date of birth and sex"
  3 "Exact match on NHS number, partial match on date of birth, exact match on sex and post code"
  4 "Exact match on NHS number, partial match on date of birth, exact match on sex"
  5 "Exact match on NHS number and post code"
  ;
lab def nhs_indicator
  0 "Elsewhere/at home"
  1 "NHS establishment"
  2 "Non-NHS  establishment"
  ;
foreach X in match_rank nhs_indicator {;
  cap conf numeric var `X';
  if !_rc {;
    lab val `X' `X';
    lablist `X', var noun;
  };
};

*
 Add numeric date variables computed from string dates
*;
foreach X in dor dod {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
cap lab var dor_n "Death registration date";
cap lab var dod_n "Death date";

*
 Compute earliest possible death date
*;
cap conf string var dod dod_partial;
if !_rc {;
  tempvar pddate_s yd md dd;
  qui {;
    gene `pddate_s'=subinstr(dod_partial,"-"," ",.);
    gene `yd'=word(`pddate_s',1);
    gene `md'=word(`pddate_s',2);
    gene `dd'=word(`pddate_s',3);
  };
  foreach X of var `yd' `md' `dd' {;
    cap conf string var `X';
    if !_rc {;
      destring `X', replace force;
      charundef `X';
      replace `X'=1 if `X'==0;
     };
  };
  charundef _dta;
  qui {;
    gene eddate=mdy(`md',`dd',`yd');
    replace eddate=dod_n if !missing(dod_n);
    compress eddate;
    drop `pddate_s' `yd' `md' `dd';
    format eddate %tdCCYY/NN/DD;
    lab var eddate "Earliest possible death date";
  };
};

*
 Key dataset if required
*;
if "`key'"!="nokey" {;
  keyby patid, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
