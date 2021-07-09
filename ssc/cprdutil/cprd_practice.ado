#delim ;
prog def cprd_practice;
version 13.0;
*
 Create dataset practice
 with 1 obs per practice in the retrieval.
 Add-on files required:
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
cap lab var pracid "Practice Identifier";
cap lab var region "Region";
cap lab var lcd "Last Collection Date";
cap lab var uts "Up To Standard Date";

*
 Convert string variables to numeric if necessary
*;
foreach X in pracid region {;
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
  keyby pracid, fast;
};

*
 Add value labels for variables
*;
if `"`dofile'"'!="" {;
  run `"`dofile'"';
  lab val region prg;
  foreach X in region {;
    cap conf numeric var `X';
    if !_rc {;
      lablist `X', var;
    };
  };
};

*
 Add numeric date variables
*;
foreach X in lcd uts {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
cap lab var lcd_n "Last collection date for practice";
cap lab var uts_n "Up to standard date for practice";

desc, fu;

end;
