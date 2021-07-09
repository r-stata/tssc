#delim ;
prog def cprd_test;
version 13.0;
*
 Create dataset test with 1 obs per test event.
 Add-on packages required:
 chardef, lablist
*!Author: Roger Newson
*!Date: 29 September 2017
*;

syntax using [ , CLEAR DOfile(string) ];

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) `clear';
desc, fu;
char list;

*
 Label variables
*;
cap lab var patid "Patient Identifier";
cap lab var eventdate "Event Date";
cap lab var sysdate "System Date";
cap lab var constype "Consultation Type";
cap lab var consid "Consultation Identifier";
cap lab var medcode "Medical Code";
cap lab var staffid "Staff Identifier";
cap lab var textid "Text Identifier";
cap lab var enttype "Entity Type";
cap lab var data1 "Data 1 (Depends on Entity Type)";
cap lab var data2 "Data 2 (Depends on Entity Type)";
cap lab var data3 "Data 3 (Depends on Entity Type)";
cap lab var data4 "Data 4 (Depends on Entity Type)";
cap lab var data5 "Data 5 (Depends on Entity Type)";
cap lab var data6 "Data 6 (Depends on Entity Type)";
cap lab var data7 "Data 7 (Depends on Entity Type)";
cap lab var data8 "Data 8 (Depends on Entity Type)";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid constype consid medcode staffid enttype {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Label values
*;
if `"`dofile'"'!="" {;
  run `"`dofile'"';
  cap lab val constype sed;
  foreach X in constype {;
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

* Describe dataset *;
desc, fu;

end;
