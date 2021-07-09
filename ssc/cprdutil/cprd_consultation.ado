#delim ;
prog def cprd_consultation;
version 13.1;
*
 Create dataset consultation with 1 obs per consultation.
 Add-on packages required:
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

*
 Add variable labels
*;
cap lab var patid "Patient Identifier";
cap lab var eventdate "Event Date";
cap lab var sysdate "System Date";
cap lab var constype "Consultation Type";
cap lab var consid "Consultation Identifier";
cap lab var staffid "Staff Identifier";
cap lab var duration "Duration";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid constype consid staffid duration {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

* Add value labels *;
if `"`dofile'"'!="" {;
  run `"`dofile'"';
  cap lab val constype cot;
  foreach X in constype {;
    cap conf numeric var `X';
    if !_rc {;
      desc `X', fu;
      lablist `X', var;
    };
  };
};

*
 Key dataset if required
*;
if "`key'"!="nokey" {;
  keyby patid consid, fast;
};

*
 Add numeric date variables
*;
foreach X in eventdate sysdate {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
cap lab var eventdate_n "Event date";
cap lab var sysdate_n "Event system entry date";

* Describe dataset *;
desc, fu;

end;
