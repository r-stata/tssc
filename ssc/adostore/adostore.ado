#delim ;
program define adostore;
version 10.0;
*
 Store aso-path in S_ADO to a global macro.
*!Author: Roger Newson
*!Date: 10 November 2017
*;

syntax [ name ] [ , replace ];
/*
 name specifies a global macro name to store the ado-path.
 replace specifies that any existing contents of the global macro
   will be overwritten.
*/

*
 Set default macro name if necessary
*;
if "`namelist'"=="" {;
  local namelist "S_ADOSTORE";
};

*
 Check that macro is empty unless replace is specified
*;
if "`replace'"=="" & `"$`namelist'"'!="" {;
  disp as error "Global macro `namelist' is not empty"
    _n "Use replace to overwrite any existing value";
  error 498;
};

*
 Store ado-path
*;
global `namelist' `"$S_ADO"';

end;

