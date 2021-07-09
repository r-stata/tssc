#delim ;
prog def subsave;
version 9.0;
/*
 Save a subset of the dataset in memory
*! Author: Roger Newson
*! Date: 30 November 2005
*/

syntax [varlist] [if] [in] using/ [, REName(string) GSort(string asis) * ];
/*
REName contains a list of alternating old and new variable names,
  so the user can rename variables in the output data set.
GSort specifies a gsort list as recognised by gsort,
  together with gsort options.
*/

*
 Check that rename list is valid
 and record number of renamings
*;
if `"`rename'"'!="" {;
  cap confirm names `rename';
  if _rc!=0 {;
    disp as error "Invalid namelist in rename() option";
    error 498;
  };
};
local nrenlist: word count `rename';
if mod(`nrenlist', 2) {;
  disp as error "Odd number of names in rename() list";
  error 498;
};
local nrename=`nrenlist'/2;

preserve;

*
 Create and save output dataset
*;
marksample touse, novarlist strok;
qui keep if `touse';
qui keep `varlist';
* Rename variables if necessary *;
forv i1=1(1)`nrename' {;
  local i2=`i1'+`i1';
  local i3=`i2'-1;
  local oldcur: word `i3' of `rename';
  local newcur: word `i2' of `rename';
  rename `oldcur' `newcur';
};
* Sort if requested *;
if `"`gsort'"'!="" {;
  gsort `gsort';
};
* Save dataset *;
save `"`using'"', `options';

restore;

end;
