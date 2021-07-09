#delim ;
prog def creplace;
version 11.0;
/*
 Exchange values cyclically between a list of variables
*!Author: Roger Newson
*!Date: 09 December 2010
*/

syntax [ varlist(min=2) ] [if] [in] [, PRevious ];
/*
 previous specifies that values in each variable will be replaced
   with values from the previous variable in the cyclic list
   (instead of with values from the next variable in the cyclic list).
*/

*
 Check that varlist is all numeric or all string
*;
cap confirm numeric variable `varlist';
if _rc {;
  cap confirm string variable `varlist';
  if _rc {;
    disp as error "Variables must be all numeric or all string";
    error 498;
  };
};

* Mark sample for use *;
marksample touse, novarlist strok;

*
 Exchange values cyclically between variables variables
*;
local nvar: word count `varlist';
tempvar totrash;
if "`previous'"=="" {;
  * Replace values with values from next variable *;
  local xold: word 1 of `varlist';
  qui {;
    gene `totrash'=`xold' if `touse';
    forv i1=2(1)`nvar' {;
      local xnew: word `i1' of `varlist';
      replace `xold'=`xnew' if `touse';
      local xold "`xnew'";
    };
    replace `xold'=`totrash' if `touse';
  };
};
else {;
  * Replace values with values from previous variable *;
  local xold: word `nvar' of `varlist';
  qui {;
    gene `totrash'=`xold' if `touse';
    forv i1=`=`nvar'-1'(-1)1 {;
      local xnew: word `i1' of `varlist';
      replace `xold'=`xnew' if `touse';
      local xold "`xnew'";
    };
    replace `xold'=`totrash' if `touse';
  };
};

*
 Compress variables to save space if possible
*;
qui compress `varlist';

end;
