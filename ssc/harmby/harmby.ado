#delim ;
prog def harmby, sortpreserve;
version 7.0;
syntax varlist [ , by(varlist) ];
/*
 Check that all variables in -varlist-
 have no more than one non-standard-missing value
 for each by-group defined by -by()-
 (or in the data set if -by()- is not specified),
 and, if so, recode all standard missing values in each by-group to that value.
*/
preserve;
if "`by'"=="" {;
  tempvar by;
  qui gene byte `by'=1;
};
foreach X of var `varlist' {;
  local T: type `X';
  if substr("`T'",1,3)=="str" {;
    * String variable *;
    sort `by' `X';
    cap by `by': assert `X'==`X'[_N] if `X'!="";
    if _rc!=0 {;
      disp as error "Multiple values not standard missing for variable `X'";
      error 498;
    };
    qui by `by': replace `X'=`X'[_N] if `X'=="";
  };
  else {;
    * Numeric variable *;
    gsort `by' -`X', mfirst;
    cap by `by': assert `X'==`X'[_N] if `X'!=.;
    if _rc!=0 {;
      disp as error "Multiple values not standard missing for variable `X'";
      error 498;
    };
    qui by `by': replace `X'=`X'[_N] if `X'==.;
  };
};
restore, not;
end;
