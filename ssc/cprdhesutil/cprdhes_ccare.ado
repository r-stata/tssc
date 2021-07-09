#delim ;
prog def cprdhes_ccare;
version 13.0;
*
 Create dataset with 1 obs per critical care event
 and data on critical care event attributes.
 Add-on packages required:
 chardef
*!Author: Roger Newson
*!Date: 29 January 2019
*;

syntax using [ , CLEAR DELIMiters(passthru) ENCoding(string) ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 delimiters() is passed through to import delimited.
 encoding() is passed through to import delimited as a charset() option.
*/

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) charset(`"`encoding'"') `delimiters' `clear';
desc, fu;

* Label variables *;
cap lab var patid "Patient ID";
cap lab var spno "Spell number";
cap lab var epikey "Episode key";
cap lab var admidate "Date of admission";
cap lab var discharged "Date of discharge";
cap lab var epistart "Date of start of episode";
cap lab var epiend "Date of end of episode";
cap lab var eorder "Order of episode within spell";
cap lab var ccstartdate "Date on which the critical care period started";
cap lab var ccstarttime "Time at which the critical care period started";
cap lab var ccdisrdydate "Critical care discharge ready date";
cap lab var ccdisrdytime "Critical care discharge ready time";
cap lab var ccdisdate "Critical care discharge date";
cap lab var ccdistime "Critical care discharge time";
cap lab var ccadmitype "Critical care admission type";
cap lab var ccadmisorc "Critical care admission source";
cap lab var ccsorcloc "Specific location in the admission source";
cap lab var ccdisstat "Patient’s status at time of discharge";
cap lab var ccdisdest "Critical care discharge destination";
cap lab var ccdisloc "Principle location the patient is being discharged to for further care";
cap lab var cclev2days "Total calendar days during which level 2 care alone was provided during period";
cap lab var cclev3days "Total calendar days during which level 3 care was provided during period";
cap lab var bcardsupdays "Number of days of basic cardiovascular support";
cap lab var acardsupdays "Number of days of advanced cardiovascular support";
cap lab var bressupdays "Number of days of basic respiratory support";
cap lab var aressupdays "Number of days of advanced respiratory support";
cap lab var gisupdays "Number of days of gastrointestinal support";
cap lab var liversupdays "Number of days of liver support";
cap lab var neurosupdays "Number of days of neurological support";
cap lab var rensupdays "Number of days of renal support";
cap lab var dermsupdays "Number of days of dermatological support";
cap lab var orgsupmax "Maximum number of organ systems supported at any one time in CCP";
cap lab var ccunitfun "Critical care unit function";
cap lab var unitbedconfig "Critical care unit bed configuration";
cap lab var bestmatch "Flag stating whetherrow represents best match";
cap lab var ccapcrel "Comparison of dates of critical care period and associated inpatient episode";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid spno epikey eorder ccadmitype ccadmisorc ccsorcloc ccdisstat ccdisdest ccdisloc
  cclev2days cclev3days bcardsupdays acardsupdays bressupdays aressupdays gisupdays liversupdays neurosupdays rensupdays dermsupdays
  orgsupmax ccunitfun unitbedconfig bestmatch ccapcrel {;
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
foreach X in admidate discharged epistart epiend ccstartdate ccdisrdydate ccdisdate {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
cap lab var admidate_n "Admission date";
cap lab var discharged_n "Discharge date";
cap lab var epistart_n "Episode start date";
cap lab var epiend_n "Episode end date";
cap lab var ccstartdate_n "Critical care period start date";
cap lab var ccdisrdydate_n "Critical care discharge ready date";
cap lab var ccdisdate_n "Critical care discharge date";

*
 Add numeric time variables computed from string times
*;
foreach X in ccstarttime ccdisrdytime ccdistime {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=clock(`X',"hms");
    compress `X'_n;
    format `X'_n %tcHH:MM:SS;    
  };
};
cap lab var ccstarttime_n "Critical care perion start time";
cap lab var ccdisrdytime_n "Critical care discharge ready time";
cap lab var ccdistime_n "Critical care discharge time";

*
 Describe dataset
*;
desc, fu;
char list;

end;
