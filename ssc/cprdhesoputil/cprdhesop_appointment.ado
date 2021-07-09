#delim ;
prog def cprdhesop_appointment;
version 13.0;
*
 Create dataset with 1 obs per HES/OP appointment.
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
cap lab var ethnos "Ethnic category as recorded at appointment";
cap lab var admincat "Administrative category";
cap lab var apptdate "Appointment date";
cap lab var apptage "Age on day of appointment";
cap lab var atentype "Attendance type";
cap lab var attended "Attended or did not attend";
cap lab var dnadate "Last DNA or patient cancelled date";
cap lab var firstatt "First attendance";
cap lab var outcome "Outcome of attendance";
cap lab var priority "Priority type";
cap lab var refsourc "Source of referral";
cap lab var reqdate "Referral request received date";
cap lab var servtype "Service type requested";
cap lab var stafftyp "Medical staff type seeing patient";
cap lab var wait_ind "Waiting calculation indicator";
cap lab var waiting "Days waiting";
cap lab var hes_yr "HES year (fiscal year beginning)";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid attendkey
  admincat apptage atentype attended outcome priority
  refsourc servtype stafftyp wait_ind waiting hes_yr {;
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
foreach X in apptdate dnadate reqdate {;
  cap conf string var `X';
  if !_rc {;
    local Xlab: var lab `X';
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
    lab var `X'_n "`Xlab'";
  };
};

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
