#delim ;
prog def cprdhes_episodes;
version 13.0;
*
 Create dataset with 1 obs per episode of care
 and data on care episode attributes.
 Add-on packages required:
 keyby, chardef
*!Author: Roger Newson
*!Date: 11 October 2019
*;

syntax using [ , CLEAR noKEY DELIMiters(passthru) ENCoding(string) ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 nokey specifies that the new dataset will not be keyed by patid, spno, epikey and d_order.
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
cap lab var epistart "Date of start of episode";
cap lab var epiend "Date of end of episode";
cap lab var discharged "Date of discharge";
cap lab var eorder "Order of episode within spell";
cap lab var epidur "Duration of episode in days";
cap lab var epitype "Type of episode";
cap lab var admimeth "Method of admission";
cap lab var admisorc "Source of admission";
cap lab var disdest "Destination on discharge";
cap lab var dismeth "Method of discharge";
cap lab var mainspef "Speciality under which consultant is contracted";
cap lab var tretspef "Speciality under which consultant is working under period of care";
cap lab var pconsult "Consultant code (pseudonymised)";
cap lab var intmanig "Intended management";
cap lab var classpat "Patient classification";
cap lab var firstreg "First regular day or night admission?";
cap lab var ethnos "Patient ethnicity from HES episode records";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid spno epikey eorder epidur epitype admimeth admisorc disdest dismeth intmanig classpat {;
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
cap lab def classpat
  1 "Ordinary admission"
  2 "Day case admission"
  3 "Regular day attendee"
  4 "Regular night attendee"
  5 "Mothers and babies using only delivery facilities"
  8 "Not applicable (other maternity event)",
  modify;
cap lab val classpat classpat;

*
 Add numeric date variables computed from string dates
*;
foreach X in admidate epistart epiend discharged {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
cap lab var admidate_n "Admission date";
cap lab var epistart_n "Episode start date";
cap lab var epiend_n "Episode end date";
cap lab var discharged_n "Discharge date";

*
 Key dataset if requested
*;
if "`key'"!="nokey" {;
  keyby patid spno epikey, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
