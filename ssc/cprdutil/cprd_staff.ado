#delim ;
prog def cprd_staff;
version 13.0;
*
 Create dataset staff with 1 obs per staff member.
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
cap lab var staffid "Staff Identifier";
cap lab var gender "Staff Gender";
cap lab var role "Staff Role";

*
 Convert string variables to numeric if necessary
*;
foreach X in staffid gender role {;
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
  cap lab val gender sex;
  cap lab val role rol;
  foreach X in gender role {;
    cap conf numeric var `X';
    if !_rc {;
      desc `X',fu;
      lablist `X', var;
    };
  };
};

*
 Key dataset if required
*;
if "`key'"!="nokey" {;
  keyby staffid, fast;
};

* Describe dataset *;
desc, fu;

end;
