#delim ;
prog def fvprevar, rclass;
version 11.0;
/*
 Extended version of fvrevar
 generating a list of permanent results variables.
*!Author: Roger Newson
*!Date: 09 February 2011
*/

syntax [varlist(fv ts)] [if] [in] , Generate(name) [ fast noLABel * ];
/*
 generate() specifies a stub for generating names for permanent generated result variables.
 fast specifies that no action will be taken to preserve the original dataset
   (without generated result variables) if the user presses Break.
 noLabel specifies that the generated result variables will not be labelled
   with the characteristic varname[fvrevar].
 Other options are equivalent
   to the options of the same names for fvrevar.
*/

if "`fast'"=="" {;preserve;};

*
 Create list of old variables
 (to protect the user from renaming them later)
*;
unab oldvars: *;

fvrevar `varlist' `if' `in', `options';
local temprevar `"`r(varlist)'"';

*
 Rename generated temporary variables to permanent
*;
local prevar "";
local i1=0;
foreach TV of var `temprevar' {;
  local oldTV: list TV in oldvars;
  if `oldTV' {;
    * Existing variable is present *;
    local prevar "`prevar' `TV'";
  };
  else {;
    * New variable has been generated *;
    local i1=`i1'+1;
    conf new var `generate'`i1';
    rename `TV' `generate'`i1';
    if "`label'"!="nolabel" {;
      lab var `generate'`i1' `"``generate'`i1'[fvrevar]'"';
    };
    local prevar "`prevar' `generate'`i1'";
  };
};
local ngenvar=`i1';
local prevar: list retokenize prevar;

* Return results in r() *;
return scalar ngenvar=`ngenvar';
return local varlist "`prevar'";

if "`fast'"=="" {;restore, not;};

end;
