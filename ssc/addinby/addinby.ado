#delim ;
prog def addinby, sortpreserve;;
version 16.0;
/*
  Add in variables and/or values from a disk dataset
  using a foreign key in the memory master dataset,
  leaving the master dataset in its original sorting order
  and without any new merge-status variable (except if requested).
*! Author: Roger Newson
*! Date: 13 April 2020
*/

syntax varlist using [, Missing UNmatched(string) noCOmplete FAST KEEP(string) GENerate(name)
  sorted noLabel noNOTES UPDATE REPLACE ];
/*
  missing denotes that missing values in key variables are allowed.
  unmatched() specifies actin taken if there are unmatched observations
    in the master dataset.
  nocomplete specifies that observations in the memory dataset
    do not need to have matching observations in the disk dataset.
  fast denotes that keyby will take no action to restore existing dataset
    in the event of failure.
  keep() specifies a list of variables in the using dataset to be kept.
  generate() specifies the name of a new variable to be generated,
    containing match information,
    and coded as the generate() variable created by merge,
    but absent if not specified.
  sorted specifies that the using dataset is already sorted by its foreign key,
    so addinby does not have to do so.
  nolabel, nonotes, update and replace function
    as the options of the same name for merge.
*/

* Set unmatched to its internal value *;
if `"`unmatched'"'=="" {;
  if "`complete'"=="nocomplete" {;
    local unmatched="keep";
  };
  else {;
    local unmatched="fail";
  };
};
if !inlist(`"`unmatched'"',"","drop","keep","fail") {;
  disp as error "Invalid unmatched()";
  error 498;
};

* Check that key variables are nonmissing *;
if "`missing'"=="" {;
  foreach X of var `varlist' {;
    cap assert !missing(`X');
    if _rc!=0 {;
      disp as error "Missing value(s) in key variable: " as result "`X'";
      error 498;
    };
  };
};

if "`fast'"=="" {;preserve;};

* Sort dataset by foreign key *;
sort `varlist', stable;

* Merge in data from the disk dataset *;
tempvar mergstat;
merge m:1 `varlist' `using' , noreport force keep(master match match_update match_conflict) generate(`mergstat') `sorted' keepus(`keep')
  `label' `notes' `update' `replace';

*
 Check for unmatched observations in master dataset if required
*;
if "`unmatched'"=="fail" {;
  tempname nunmatch;
  qui count if `mergstat'==1;
  scal `nunmatch'=r(N);
  if `nunmatch'>0 {;
    disp as error "No matching observations in using dataset for "
      `nunmatch' " observations in master dataset";
    error 498;
  };
};
else if "`unmatched'"=="drop" {;
  drop if `mergstat'==1;
};

*
 Rename merge status variable if wanted
*;
if "`generate'"!="" {;
  rename `mergstat' `generate';
};

if "`fast'"=="" {;restore, not;};

end;
