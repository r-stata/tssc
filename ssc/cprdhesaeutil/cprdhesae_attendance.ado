#delim ;
prog def cprdhesae_attendance;
version 13.0;
*
 Create dataset with 1 obs per HES A&E patient attendance.
 Add-on packages required:
 keyby, chardef.
*!Author: Roger Newson
*!Date: 29 January 2019
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
cap lab var aekey "A&E attendance record key";
cap lab var arrivaldate "Arrival date";
cap lab var aepatgroup "Reason for A&E episode";
cap lab var aeattendcat "AE attendance category (initial or follow-up)";
cap lab var aearrivalmode "A&E arrival mode";
cap lab var aedepttype "A&E department type";
cap lab var aerefsource "Referral source for A&E episode";
cap lab var aeincloctype "A&E incident location type";
cap lab var aeattenddisp "A&E attendance end mode";
cap lab var initdur "Time (minutes) between arrival and initial assessment";
cap lab var tretdur "Time (minutes) between arrival and start of treatment";
cap lab var concldur "Time (minutes) between arrival and conclusion of attendance or treatment";
cap lab var depdur "Time (minutes) between arrival and conclusion of A&E attendance";
cap lab var ethnos "Ethnic category recorded at attendance";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid aekey aepatgroup aeattendcat aearrivalmode
  aedepttype aerefsource aeincloctype aeattenddisp initdur tretdur concldur depdur {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Add value labels
*;
lab def aedepttype
  01 "Consultant led 24-hour service"
  02 "Consultant-led mono specialty accident and emergency service"
  03 "Other type of A&E/minor injury activity with designated accommodation"
  04 "NHS walk-in centre"
  99 "Not known"
  ;
lab def aerefsource
  00 "General medical practitioner"
  01 "Self referral"
  02 "Local authority social services"
  03 "Emergency services"
  04 "Work"
  05 "Educational establishment"
  06 "Police"
  07 "Health care provider: same or other"
  08 "Other"
  92 "General dental practitioner"
  93 "Community dental service"
  99 "Not known"
  ;
lab def aeincloctype
  10 "Home"
  40 "Work"
  50 "Educational establishment"
  60 "Public place"
  91 "Other"
  99 "Not known";
  ;
lab def aeattenddisp
  01 "Admitted to hospital bed / became a lodged patient"
  02 "Discharged - follow-up treatment to be provided by GP"
  03 "Discharged - did not require any follow-up treatment"
  04 "Referred to A&E clinic"
  05 "Referred to fracture clinic"
  06 "Referred to other outpatient clinic"
  07 "Transferred to other healthcare provider"
  10 "Died in department"
  11 "Referred to other healthcare professional"
  12 "Left department before being treated"
  13 "Left department having refused treatment"
  14 "Other"
  99 "Not known"
  ;
foreach X in aedepttype aerefsource aeincloctype aeattenddisp {;
  cap conf numeric var `X';
  if !_rc {;
    cap lab val `X' `X';
    lablist `X', noun var;
  };
};

*
 Add numeric date variables computed from string dates
*;
foreach X in arrivaldate {;
  cap conf string var `X';
  if !_rc {;
    local Xlab: var lab `X';
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
    lab var `X'_n `"`Xlab'"';
  };
};

*
 Key dataset if required
*;
if "`key'"!="nokey" {;
  keyby patid aekey, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
