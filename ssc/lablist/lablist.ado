#delim ;
prog def lablist, rclass;
version 10.0;
/*
 List value labels (if possible) for variables in a varlist.
*!Author: Roger Newson
*!Date: 13 January 2018
*/

syntax [varlist] [, VARlabel noUNlabelled LOcal(name) ];
*
 varlabel specifies that variable labels will be listed.
 nounlabelled specifies that variables without value labels will not be listed.
 local specifies the name of a local macro to contain a list of value label names.
*;

*
 List labels for each variable with a value label
 accumulating label names in a local macro
*;
local names "";
foreach X of var `varlist' {;
  local Xlab: value label `X';
  if "`Xlab'"!="" | "`unlabelled'"!="nounlabelled" {;
    disp _n as text "Variable: " as result "`X'";
    if "`varlabel'"!="" {;
      local Xvarlab: variable label `X';
      if `"`Xvarlab'"'=="" {;
        disp as text "No variable label present";      
      };
      else {;
        disp as text "Variable label: " as result `"`Xvarlab'"';
      };
    };
    if `"`Xlab'"'=="" {;
      disp as text "No value label present";
    };
    else {;
      disp as text "Value label: " as result "`Xlab'";
      local names "`names' `Xlab'";
      retu clear;
      lab list `Xlab';
      retu add;
    };
  };
};
local names: list uniq names;
local names: list sort names;

*
 Set local option if necassary
 to contain an alphanumeric list of label names
*;
if "`local'"!="" {;
  c_local `local' "`names'";
};

*
 Add variable names to returned results
*;
return local names "`names'";

end;
