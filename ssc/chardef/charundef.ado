#delim ;
prog def charundef, rclass;
version 11.0;
/*
 Clear a list of characteristics for an evarlist
 of variable names or the name _dta.
%!Author: Roger Newson
*!Date: 09 May 2012
*/

syntax [ anything(name=evarlist) ] [ , Charlist(string) ];
/*
 charlist() specifies the list of characteristics
   (namelist or "*" for all characteristics).
*/

*
 Unabbreviate evarlist
*;
if `"`evarlist'"'=="" {;
  unab evarlist: *;
};
else {;
  local newevarlist "";
  foreach Y in `evarlist' {;
    if "`Y'"=="_dta" {;
      local newevars "`Y'";
    };
    else {;
      unab newevars: `Y';
    };
    local newevarlist `"`newevarlist' `newevars'"';
  };
  local evarlist `"`newevarlist'"';
};

*
 Set default charlist if required
 and check that charlist() is valid.
*;
if inlist(`"`charlist'"',"","*") {;
  local charlist "";
  foreach X in `evarlist' {;
    local charcur: char `X'[];
    local charlist "`charlist' `charcur'";
  };
  local charlist: list uniq charlist;
};
local charlist: list sort charlist;
if "`charlist'"!="" {;
  cap confirm names `charlist';
  if _rc!=0 {;
    disp as error "charlist() must be either a namelist or *";
    error 498;
  };
};

*
 Undefine characteristics.
*;
foreach X in `evarlist' {;
  foreach C in `charlist' {;
    char `X'[`C'] "";
  };
};

*
 Save results
*;
return local charlist "`charlist'";

end;
