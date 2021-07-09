#delim ;
program define adorestore;
version 10.0;
*
 Restore ado-path in S_ADO from a global macro.
*!Author: Roger Newson
*!Date: 10 November 2017
*;

syntax [ name ];
/*
 name specifies a global macro name to store the ado-path.
*/

*
 Set default macro name if necessary
*;
if "`namelist'"=="" {;
  local namelist "S_ADOSTORE";
};

*
 Check that macro is not empty
*;
if `"$`namelist'"'=="" {;
  disp as error "Nothing to restore in global macro `namelist'";
  error 498;
};

*
 Restore ado-path
*;
global S_ADO `"$`namelist'"';

end;
