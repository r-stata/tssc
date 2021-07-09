#delim ;
prog def keyby;
version 10.0;
/*
  Sort and key dataset by a varlist,
  failing unless the varlist uniquely identifies observations.
*! Author: Roger Newson
*! Date: 13 April 2008
*/

syntax varlist [, noOrder Missing FAST ];
/*
  noorder denotes that the variables in varlist are not reordered to the front.
  missing denotes that missing values in key variables are allowed.
  fast denotes that keyby will take no action to restore existing dataset
    in the event of failure.
*/

* Check that key variables are nonmissing *;
if "`missing'"=="" {;
  foreach X of var `varlist' {;
    cap assert !missing(`X');
    if _rc!=0 {;
      disp as text "Missing value(s) in key variable: " as result "`X'";
      error 498;
    };
  };
};

if "`fast'"=="" {;preserve;};

* Sort variables, ordering unless otherwise specified *;
if "`order'"!="noorder" {;
  order `varlist';
};
sort `varlist', stable;

* Check that dataset is keyed *;
cap by `varlist': assert _N==1;
if _rc!=0 {;
  disp as text "Repeated values for key variable list: " as result "`varlist'";
  error 498;
};

if "`fast'"=="" {;restore, not;};

end;
