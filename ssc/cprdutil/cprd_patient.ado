#delim ;
prog def cprd_patient;
version 13.0;
*
 Create dataset patient with 1 obs per patient in the retrieval.
 Add-on do-files required:
 keyby, lablist, chardef
*!Author: Roger Newson
*!Date: 29 September 2017
*;

syntax using [ , CLEAR DOfile(string) noKEY ];
*
 clear specifies that existing data will be cleared.
 dofile specifies name of do-file setting the value labels.
 nokey specifies that dataset should not be keyed.
*;

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) `clear';
desc, fu;
cap lab var patid "Patient Identifier";
cap lab var vmid "VAMP Identifier";
cap lab var gender "Patient Gender";
cap lab var yob "Birth Year";
cap lab var mob "Birth Month";
cap lab var marital "Marital Status";
cap lab var famnum "Family Number";
cap lab var chsreg "CHS Registered";
cap lab var chsdate "CHS Registration Date";
cap lab var prescr "Prescription Exemption";
cap lab var capsup "Capitation Supplement";
cap lab var ses "Socio-Economic Status";
cap lab var frd "First Registration Date";
cap lab var crd "Current Registration Date";
cap lab var regstat "Registration Status";
cap lab var reggap "Registration Gaps";
cap lab var internal "Internal Transfer";
cap lab var tod "Transfer Out Date";
cap lab var toreason "Transfer Out Reason";
cap lab var deathdate "Death Date";
cap lab var accept "Acceptable Patient Flag";
cap lab var pracid "Practice Identifier";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid vmid gender yob mob marital famnum chsreg prescr capsup ses regstat reggap internal toreason accept pracid {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Key dataset if required
*;
if "`key'"!="nokey" {;
  keyby patid, fast;
};

*
 Add value labels for variables
*;
if `"`dofile'"'!="" {;
  run `"`dofile'"';
  cap lab val gender sex;
  cap lab val marital mar;
  cap lab val chsreg y_n;
  cap lab val prescr pex;
  cap lab val capsup cap;
  cap lab val toreason tra;
  foreach X in gender marital chsreg prescr capsup toreason {;
    cap conf numeric var `X';
    if !_rc {;
      lablist `X', var;
    };
  };
};

*
 Add practice ID variable
 (computed from patient ID variable)
*;
cap conf var pracid;
if _rc {;
  gene long pracid=mod(patid-1,1000)+1;
  compress pracid;
  lab var pracid "Practice Identifier";
};

*
 Add numeric date variables computed from string dates
*;
foreach X in chsdate frd crd tod deathdate {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
cap lab var chsdate_n "Child Health Surveillance registration date";
cap lab var frd_n "First registration date with practice";
cap lab var crd_n "Current registration date with practice";
cap lab var tod_n "Date of transfer out of practice";
cap lab var deathdate_n "Patient death date (CPRD Gold)";

*
 Add earliest possible birth date
*;
cap conf numeric var yob mob;
if !_rc {;
  gene long yob2=cond(yob>=1000,yob,yob+1800) if !missing(yob);
  gene long mob2=mob+(mob==0);
  compress yob2 mob2;
  gene long ebdate_n=mdy(mob2,01,yob2);
  compress ebdate_n;
  format ebdate_n  %tdCCYY/NN/DD;
  lab var ebdate_n "Earliest possible birth date";
  drop yob2 mob2;
};

desc, fu;

end;
