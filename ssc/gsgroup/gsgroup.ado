#delim ;
prog def gsgroup, sortpreserve;
version 10.0;
/*
 Generate a new variable
 containing sequence numbers for groups
 defined by a generalized varlist recognized by gsort,
 and (optionally) a new output dataset (or resultsset)
 with 1 obs per non-missing value of the new grouping variable
 and data on the values of the variables in the varlist
 corresponding to the value of the grouping variable in that observation.
*! Author: Roger Newson
*! Date: 27 September 2012
*/

syntax anything [if] [in], Generate(name) [ SAving(string asis) noMISSing ] *;
/*
 generate() specifies the name of the new grouping variable.
 saving() specifies the output dataset (or resultsset)
  with 1 obs per value of the new grouping variable.
 nomissing specifies that observations with missing values
  for variables in the input key
  will have missing values in the output group variable.
 Other options are passed to gsort.
*/

marksample touse;

*
 Confirm that inputs are well-formed
 and extract varlist
*;
confirm new variable `generate';
local varlist: list retokenize anything;
local varlist: subinstr local varlist "-" "", all;
local varlist: subinstr local varlist "+" "", all;
cap conf var `varlist';
if _rc {;
  disp as error "Input gsort key does not specify a valid varlist";
  error 498;
};

*
 Mark out observations with missing key values if requested
*;
if "`missing'"=="nomissing" {;
  markout `touse' `varlist', strok;
};

*
 Generate temporary output grouping variable
*;
tempvar tempgen;
gsort -`touse' `anything', gene(`tempgen') `options';
qui replace `tempgen'=. if !`touse';
char `tempgen'[varlist] "`varlist'";

*
 Create output dataset if required
*;
if `"`saving'"'!="" {;
  preserve;
  qui {;
    rename `tempgen' `generate';
    keep if `touse';
    keep `generate' `varlist';
    sort `generate' `varlist';
    by `generate' `varlist': keep if _n==1;
    order `generate' `varlist';
  };
  _parse comma outfname outfopts: saving;
  if `"`outfname'"'=="" {;
    disp as error "filename must be present in saving() option";
    error 498;
  };
  save `outfname' `outfopts';
  restore;
};

*
 Rename temporary output grouping variable to permanent
 if program has worked
*;
rename `tempgen' `generate';

end;
