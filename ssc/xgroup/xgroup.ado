#delim ;
prog def xgroup;
version 10.0;
/*
 Generate a new variable
 containing group sequence numbers defined by a varlist,
 and/or a new output dataset (or resultsset)
 with 1 obs per non-missing value of the new grouping variable
 and data on the values of the variables in the varlist
 corresponding to the value of the grouping variable in that observation.
*! Author: Roger Newson
*! Date: 03 February 2009
*/

syntax varlist(min=1) [if] [in] , [ Generate(name) SAving(string asis) ] *;
/*
 generate() specifies the name of the new grouping variable.
 saving() specifies the output dataset (or resultsset)
  with 1 obs per value of the new grouping variable.
 Other options are passed to the egen function group.
*/

if `"`generate'"'=="" & `"`saving'"'=="" {;
  disp as error "You must specify generate() or saving()";
  error 498;
};

if "`generate'"!="" {;
  confirm new variable `generate';
};

*
 Generate temporary output grouping variable
*;
tempvar tempgen;
egen double `tempgen'=group(`varlist') `if' `in' , `options';
qui compress `tempgen';

*
 Create output dataset if required
*;
if `"`saving'"'!="" {;
  preserve;
  qui {;
    keep if !missing(`tempgen');
    if "`generate'"=="" {;
      drop `tempgen';
    };
    else {;
         rename `tempgen' `generate';
    };
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
if "`generate'"!="" {;
  rename `tempgen' `generate';
};

end;
