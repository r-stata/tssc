#delim ;
prog def cprd_clinical;
version 13.0;
*
 Create dataset clinical with 1 obs per clinical event.
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

*
 Add variable labels
*;
cap lab var patid "Patient Identifier";
cap lab var eventdate "Event Date";
cap lab var sysdate "System Date";
cap lab var constype "Consultation Type";
cap lab var consid "Consultation Identifier";
cap lab var medcode "Medical Code";
cap lab var staffid "Staff Identifier";
cap lab var textid "Text Identifier";
cap lab var episode "Episode";
cap lab var enttype "Entity Type";
cap lab var adid "Additional Details Identifier";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid constype consid medcode staffid episode enttype adid {;
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
  cap lab val episode epi;
  foreach X in constype episode {;
    cap conf numeric var `X';
    if !_rc {;
      lablist `X', var;
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

* Describe dataset *;
desc, fu;

end;
