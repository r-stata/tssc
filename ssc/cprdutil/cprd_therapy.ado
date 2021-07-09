#delim ;
prog def cprd_therapy;
version 13.0;
*
 Create dataset therapy with 1 obs per therapy event.
 Add-on packages required:
 chardef
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
cap lab var consid "Consultation Identifier";
cap lab var prodcode "Product Code";
cap lab var staffid "Staff Identifier";
* New format dosage ID *;
cap lab var dosageid "Dosage Identifier";
* Old format text ID *;
cap lab var textid "Text Identifier";
cap lab var bnfcode "BNF Code";
cap lab var qty "Total Quantity";
cap lab var ndd "Numeric Daily Dose";
cap lab var numdays "Number of Days";
cap lab var numpacks "Number of Packs";
cap lab var packtype "Pack Type";
cap lab var issueseq "Issue Sequence Number";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid consid prodcode staffid bnfcode qty ndd numdays numpacks packtype issueseq {;
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

* Describe variables *;
desc, fu;

end;
