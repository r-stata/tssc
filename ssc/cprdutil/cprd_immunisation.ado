#delim ;
prog def cprd_immunisation;
version 13.0;
*
 Create dataset immunisation with 1 obs per immunisation.
 Add-on packages required:
 lablist, chardef
*!Author: Roger Newson
*!Date: 29 September 2017
*;

syntax using [ , CLEAR DOfile(string) ];

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) `clear';
desc, fu;

* Add variable labels *;
cap lab var patid "Patient Identifier";
cap lab var eventdate "Event Date";
cap lab var sysdate "System Date";
cap lab var constype "Consultation Type";
cap lab var consid "Consultation Identifier";
cap lab var medcode "Medical Code";
cap lab var staffid "Staff Identifier";
cap lab var textid "Text Identifier";
cap lab var immstype "Type";
cap lab var stage "Stage";
cap lab var status "Status";
cap lab var compound "Compound";
cap lab var source "Source";
cap lab var reason "Reason";
cap lab var method "Method";
cap lab var batch "Batch";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid constype consid medcode staffid immstype stage status compound source reason method batch {;
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
if `"`dofile'"'!="" {;
  run `"`dofile'"';
  cap lab val constype sed;
  cap lab val immstype imt;
  cap lab val stage ist;
  cap lab val status imm;
  cap lab val compound imc;
  cap lab val source inp;
  cap lab val reason rin;
  lab val method ime;
  foreach X in constype immstype stage status compound source reason method {;
    cap conf numeric var `X';
    if !_rc {;
      lablist `X', var noun;
    };
  };
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

* Desccribe dataset *;
desc, fu;

end;
