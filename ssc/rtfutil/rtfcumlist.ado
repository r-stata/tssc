#delim ;
prog def rtfcumlist, rclass;
version 11.0;
/*
 Input a numlist
 and output the corresponding numlist of cumulative sums
*!Author: Roger Newson
*!Date: 04 October 2009
*/

syntax anything [, LOcal(name) ];
/*
 local() specifies the name of a local macro
   to contain the numlist of cumulative sums.
*/

* Extract input numlist *;
numlist `"`anything'"';
local nums "`r(numlist)'";

* Define output cumulative sum list *;
local cumcur=0;
local cumlist "";
foreach X of num `nums' {;
  local cumcur=`cumcur'+`X';
  local cumlist "`cumlist' `cumcur'";
};
local cumlist: subinstr local cumlist " " "";

* Return output cumulative sum list *;
if "`local'"!="" {;
  c_local `local' "`cumlist'";
};
return local cumlist "`cumlist'";

end;
