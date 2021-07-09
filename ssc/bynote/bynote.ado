#delim ;
prog def bynote, rclass;
version 10.0;
/*
  Create a note for a graph with a by-option
  from the labels of a list of by-variables.
*!Author: Roger Newson
*!Date: 08 May 2008
*/

syntax varlist (min=1) [ , PRefix(string) SEparator(string) LSEparator(string) SUffix(string) LOcal(name) ];
/*
  prefix() specifies the prefix.
  separator() specifies the separator.
  lseparator() specifies the last separator.
  suffix() specifies the suffix.
  local() specifies a local macro in which the by-note is stored.
*/

*
 Set defaults
*;
if `"`prefix'"'=="" {;local prefix "Graphs by: ";};
if `"`separator'"'=="" {;local separator ", ";};
if `"`lseparator'"'=="" {;local lseparator `"`separator'"';};

*
 Create by-note
*;
local nvar: word count `varlist';
local varcur: word `nvar' of `varlist';
local labcur: var lab `varcur';
if `"`labcur'"'=="" {;local labcur "varcur";};
local bynote `"`labcur'`suffix'"';
local i1=`nvar'-1;
while `i1'>0 {;
  local varcur: word `i1' of `varlist';
  local labcur: var lab `varcur';
  if `"`labcur'"'=="" {;local labcur "`varcur'";};
  if `i1'==`nvar'-1 {;
    local bynote `"`labcur'`lseparator'`bynote'"';
  };
  else {;
    local bynote `"`labcur'`separator'`bynote'"';
  };
  local i1=`i1'-1;
};
local bynote `"`prefix'`bynote'"';

*
 Return and list results
*;
return local bynote `"`bynote'"';
if "`local'"!="" {;
  c_local `local' `"`bynote'"';
};
disp as result `"`bynote'"';

end;
