#delim ;
prog def keybygen;
version 10.0;
/*
  Sort dataset by a varlist,
  preserving the original order within by-groups,
  and generate a new variable,
  containing the sequential order of the observation within its by-group.
*! Author: Roger Newson
*! Date: 28 July 2014
*/

syntax [ varlist(default=none) ] , Generate(name) [ REPLACE DROPconstant FAST * ];
/*
 generate() gives the name of a new variable to be created,
   containing the sequential order of the observation within its by-group.
 replace denotes that any existing variable of the same name as the generate() option
   will be replaced.
 dropconstant denotes that the generated key variable will be dropped if constant,
   because then it is not really necessary.
 fast denotes that keybygen will take no action to restore existing dataset
    in the event of failure.
 Other options are passed to keyby.
*/

*
 Check that generate is not a by-variable
*;
if "`varlist'"!="" {;
  local genclash: list generate in varlist;
  if `genclash' {;
    disp as error "generate() option may not be in the varlist";
    error 498;
  };
};

if "`fast'"=="" {;preserve;};

*
 Sort and create generated variable
*;
if "`replace'"!="" {;cap drop `generate';};
else {;confirm new variable `generate';};
if "`varlist'"=="" {;
  qui gene long `generate'=_n;
};
else {;
  sort `varlist', stable;
  qui by `varlist': gene long `generate'=_n;
};
qui compress `generate';
keyby `varlist' `generate', fast `options';

*
 Label generated variable
*;
local maxlablen=80;
local prefix "Order within: ";
if "`varlist'"=="" {;
  lab var `generate' "Order within dataset";
};
else if length("`prefix'")+length("`varlist'")<=`maxlablen' {;
  lab var `generate' "`prefix'`varlist'";
};
else {;
  lab var `generate' "Order within by-group";
};

*
 Drop generated variable if constant
 (if dropconstant is specified)
*;
if "`dropconstant'"!="" {;
  cap assert `generate'==1;
  if _rc==0 {;
    drop `generate';
    disp as text "Note: generated key variable `generate' is constant and has been dropped.";
  };
};

if "`fast'"=="" {;restore, not;};

end;
