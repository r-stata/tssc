#delim ;
prog def fraddinby, sortpreserve;;
version 16.0;
/*
  Add in variables and/or values from a dataset in a data frame
  using a foreign key in the memory master dataset,
  leaving the master dataset in its original sorting order
  and without any new linkage variable (except if requested).
*! Author: Roger Newson
*! Date: 13 April 2020
*/


syntax varlist , FRAme(name) [ Missing UNmatched(string) noCOmplete FAST KEEP(string) GENerate(name) ];
/*
  frame() specifies the frame from which new variables are to be merged.
  missing denotes that missing values in key variables are allowed.
  unmatched() specifies action taken if there are unmatched observations
    in the master dataset.
  nocomplete specifies that observations in the memory dataset
    do not need to have matching observations in the disk dataset.
  keep() specifies a list of variables in the linked data frame to be kept.
  generate() specifies the name of a new linkage variable to be generated
    for the linkage between the current dataframe and the linked data frame,
    but absent if not specified.
*/


*
 Check that frame() option specifies an existing frame
*;
confirm frame `frame';


*
 Set defaults for generate() and keep() options
*;
if "`generate'"=="" {;
  tempvar generate;
};
if "`keep'"=="" {;
  local keep "*";
};


*
 Expand keep option to full varlist with no wildcards
 and eliminate foreign key variables
 and check that the wanted fariables from frame()
 are not in current frame.
*;
frame `frame' {;
  unab expkeep: `keep';
  local expkeep: list expkeep - varlist;
  local Nexpkeep: word count `expkeep';
  if `Nexpkeep'0 {;
    conf var `expkeep';
  };
};
if `Nexpkeep'0{;
  conf new var `expkeep';
};


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


*
 Create linkage to frame()
*;
qui frlink m:1 `varlist', frame(`frame') gene(`generate');


*
 Check for unmatched observations in master dataset if required
*;
if "`unmatched'"=="fail" {;
  tempname nunmatch;
  qui count if missing(`generate');
  scal `nunmatch'=r(N);
  if `nunmatch'>0 {;
    disp as error "No matching observations in using dataset for "
      `nunmatch' " observations in master dataset";
    error 498;
  };
};
else if "`unmatched'"=="drop" {;
  drop if missing(`generate');
};


*
 Get required variables from frame()
*;
if `Nexpkeep'>0 {;
  qui foreach X in `expkeep' {;
    frget `X'=`X', from(`generate');
  };
};


end;
