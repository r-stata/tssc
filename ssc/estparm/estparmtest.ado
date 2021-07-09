#delim ;
prog def estparmtest, rclass byable(recall);
version 11.0;
/*
  Call estparm and test equality of parameters.
*!Author: Roger Newson
*!Date: 27 August 2009
*/

*
 Parse syntax, mark sample, and call estparm
*;
syntax varlist(numeric min=2 max=3) [if] [in] , [ * ];
marksample touse;
estparm `varlist' if(`touse') `in', `options';

*
 Equality test
*;
disp _n as text "Test of H0: All parameters are equal";
local eqlist: coleq e(b), quote;
local neq: word count `eqlist';
if `neq'<2 {;
  disp as error "Less than 2 parameters available for comparison";
  error 498;
};
local hyptest: word 1 of `eqlist';
forv i1=2(1)`neq' {;
  local eqcur: word `i1' of `eqlist';
  local hyptest `"`hyptest'=`eqcur'"';
};
test [`hyptest']:_cons;

return add;
end;
