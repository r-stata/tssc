#delim ;
prog def jformat;
version 10.0;
/*
 Justify display formats for a list of variables.
*! Author: Roger Newson
*! Date: 04 November 2018
*/


syntax [varlist] [, Justify(string) ];
/*
justify() specifies whether the justification is leftt, right or center.
*/


*
 Unabbreviate the justify option,
 setting default if necessary.
*;
local justify=trim(`"`justify'"');
if `"`justify'"'=="" {;
  local justify="left";
};
foreach X in left right center {;
  if strpos("`X'",`"`justify'"')==1 {;
    local justify="`X'";
  };
};
if strpos("centre",`"`justify'"')==1 {;
  local justify="center";
};
if !inlist(`"`justify'"',"left","right","center") {;
  disp as error `"Illegal justify(`justify')"'
    _n "justify() option must be left, right or center";
  error 498;
};


*
 Set new format prefix according to justify() option
*;
if "`justify'"=="left" {;
  local newpref="%-";
};
else if "`justify'"=="right" {;
  local newpref="%";
};
else if "`justify'"=="center" {;
  local newpref="%~";
};


*
 Loop over varlist, justifying formats
*;
foreach X of var `varlist' {;
  local Xformat: format `X';
  if strpos("`Xformat'","%-")==1 {;
    local oldpref="%-";
  };
  else if strpos("`Xformat'","%~")==1 {;
    local oldpref="%~";
  };
  else {;
    local oldpref="%";
  };
  local Xformat=subinstr("`Xformat'","`oldpref'","`newpref'",1);
  cap format `X' `Xformat';
  if _rc {;
    disp as text "Illegal format requested and ignored - `Xformat'";
  };
};


end;
