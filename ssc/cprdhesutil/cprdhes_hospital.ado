#delim ;
prog def cprdhes_hospital;
version 13.0;
*
 Create dataset with 1 obs per hospitalisation
 and data on hospitalisation attributes.
 Add-on packages required:
 keyby, chardef
*!Author: Roger Newson
*!Date: 11 January 2019
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
cap lab var admidate "Date of admission";
cap lab var discharged "Date of discharge";
cap lab var admimeth "Method of admission";
cap lab var admisorc "Source of admission";
cap lab var disdest "Destination on discharge";
cap lab var dismeth "Method of discharge";
cap lab var duration "Duration of hospitalisation spell in days";
cap lab var elecdate "Date of decision to admit patient";
cap lab var elecdur "Waiting time (difference in days between elecdate and admidate)";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid spno admimeth admisorc disdest dismeth duration elecdur {;
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

*
 Add numeric date variables computed from string dates
*;
foreach X in admidate discharged elecdate {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
cap lab var admidate_n "Admission date";
cap lab var discharged_n "Discharge date";
cap lab var elecdate_n "Patient admission decision date";

*
 Key dataset if requested
*;
if "`key'"!="nokey" {;
  keyby patid spno, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
