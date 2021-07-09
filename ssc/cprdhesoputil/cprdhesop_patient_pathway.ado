#delim ;
prog def cprdhesop_patient_pathway;
version 13.0;
*
 Create dataset with 1 obs per HES/OP patient pathway.
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
cap lab var attendkey "Attendance record key";
cap lab var perend "RTT period end date";
cap lab var perstart "RTT period start date";
cap lab var subdate "Submission date";
cap lab var hes_yr "HES year (fiscal year beginning)";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid attendkey hes_yr {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Add numeric date variables computed from string dates
*;
foreach X in perend perstart subdate {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
cap lab var perend_n "Referral to treatment period end date";
cap lab var perstart_n "Referral to treatment period start date";
cap lab var subdate_n "Submission date";

*
 Key dataset if required
*;
if "`key'"!="nokey" {;
  keyby patid attendkey, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
