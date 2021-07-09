#delim ;
prog def bygap,rclass;
version 7.0;
/*
  Insert by-gap observations at the start of each by-group
  defined by by-variables in -varlist-,
  each with the same value of the by-variables as in the following by-group
  and missing values for all other variables.
*! Author: Roger Newson
*! Date: 21 May 2003
*/

syntax [ varlist(default=none) ] [if] [in] [ , Gapindicator(string) RString(string) ];
/*
  -gapindicator- is a generated gap indicator variable,
  equal to 1 if the observation is a gap and 0 otherwise.
*/

*
 Create local macro -gindlab-
 (containing label for variable -gapindicator-)
*;
local gindlab `"bygap `varlist' `if' `in'"';

* Create list of existing variables *;
unab existvar: *;

* Mark sample for use *;
marksample touse,novarlist strok;

*
 Save original order in temporary variable -seqord-
*;
tempvar seqord;
qui gene long `seqord'=_n;

*
 Create varlist of single temporary by-variable
 if no varlist is provided
*;
if `"`varlist'"'=="" {;
  tempvar varlist;
  qui gene byte `varlist'=1;
};

sort `touse' `varlist' `seqord';

*
 Indicate observations to duplicate
 (so one duplicate can be converted to a by-gap observation)
 and duplicate them
*;
tempvar todup;
qui by `touse' `varlist':gene byte `todup'=`touse'&(_n==1);
qui expand 2*`todup';
drop `todup';
sort `touse' `varlist' `seqord';

*
 Indicate by-gap observations in variable -gapindicator-
 and move them to top of their by-groups
*;
if `"`gapindicator'"'=="" {;tempvar gapindicator;};
else {;
  confirm new var `gapindicator';
  local ngapi:word count `gapindicator';
  if `ngapi'>1 {;
    disp as error "Invalid multiple gap indicator variables: `gapindicator'";
    error 498;
  };
};
by `touse' `varlist' `seqord':gene byte `gapindicator'=_n==2;
lab var `gapindicator' `"`gindlab'"';
gsort `touse' `varlist' `seqord' -`gapindicator';

*
 Check that -rstring- is valid
 and reset it to missing otherwise
*;
if !inlist(`"`rstring'"',"name","label","labname","") {;
  disp as text `"Note: invalid rstring(`rstring') ignored"';
  local rstring "";
};


* Set non-by-variables to missing *;
foreach X of var `existvar' {;
  local nonbyvar=1;
  foreach Y of var `varlist' {;
    if "`X'"=="`Y'" {;local nonbyvar=0;};
  };
  if `nonbyvar' {;
    cap confirm string variable `X';
    if _rc==0 {;
      * String variable *;
      if `"`rstring'"'=="name" {;
        qui replace `X'=`"`X'"' if `gapindicator';
      };
      else if `"`rstring'"'=="label" {;
        local Xlab:var lab `X';
        qui replace `X'=`"`Xlab'"' if `gapindicator';
      };
      else if `"`rstring'"'=="labname" {;
        local Xlab:var lab `X';
        if `"`Xlab'"'!="" {;qui replace `X'=`"`Xlab'"' if `gapindicator';};
        else {;qui replace `X'=`"`X'"' if `gapindicator';};
      };
      else {;
        qui replace `X'="" if `gapindicator';
      };
    };
    else {;
      * Numeric variable *;
      qui replace `X'=. if `gapindicator';
    };
  };
};

* Sort to original order *;
gsort `seqord' -`gapindicator';

end;
